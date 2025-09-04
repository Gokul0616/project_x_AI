const express = require('express');
const { body, query, validationResult } = require('express-validator');
const User = require('../models/User');
const Tweet = require('../models/Tweet');
const Notification = require('../models/Notification');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Get user profile
router.get('/profile/:username?', async (req, res) => {
  try {
    const username = req.params.username;
    
    if (!username) {
      return res.status(400).json({ error: 'Username is required' });
    }

    const user = await User.findOne({ username }).select('-password');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user: user.getPublicProfile() });
  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
});

// Update user profile
router.put('/profile', auth, [
  body('displayName')
    .optional()
    .isLength({ min: 1, max: 50 })
    .withMessage('Display name must be between 1 and 50 characters'),
  body('bio')
    .optional()
    .isLength({ max: 160 })
    .withMessage('Bio must be less than 160 characters'),
  body('location')
    .optional()
    .isLength({ max: 50 })
    .withMessage('Location must be less than 50 characters'),
  body('website')
    .optional()
    .isURL()
    .isLength({ max: 100 })
    .withMessage('Website must be a valid URL less than 100 characters')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const allowedUpdates = ['displayName', 'bio', 'location', 'website', 'profileImageUrl', 'bannerImageUrl'];
    const updates = {};

    // Only include allowed fields that are present in request
    allowedUpdates.forEach(field => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ error: 'No valid fields to update' });
    }

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updates,
      { new: true, runValidators: true }
    ).select('-password');

    res.json({
      message: 'Profile updated successfully',
      user: user.getPublicProfile()
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

// Follow/Unfollow user
router.post('/follow/:username', auth, async (req, res) => {
  try {
    const targetUser = await User.findOne({ username: req.params.username });
    if (!targetUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (targetUser._id.toString() === req.user._id.toString()) {
      return res.status(400).json({ error: 'You cannot follow yourself' });
    }

    const currentUser = await User.findById(req.user._id);
    const isFollowing = currentUser.following.includes(targetUser._id);

    if (isFollowing) {
      // Unfollow
      currentUser.following = currentUser.following.filter(
        id => id.toString() !== targetUser._id.toString()
      );
      targetUser.followers = targetUser.followers.filter(
        id => id.toString() !== currentUser._id.toString()
      );
    } else {
      // Follow
      currentUser.following.push(targetUser._id);
      targetUser.followers.push(currentUser._id);

      // Create notification for follow
      await Notification.createNotification({
        recipient: targetUser._id,
        sender: currentUser._id,
        type: 'follow'
      });
    }

    await currentUser.save();
    await targetUser.save();

    res.json({
      message: isFollowing ? 'User unfollowed' : 'User followed',
      isFollowing: !isFollowing,
      followerCount: targetUser.followerCount,
      followingCount: currentUser.followingCount
    });
  } catch (error) {
    console.error('Follow/unfollow error:', error);
    res.status(500).json({ error: 'Failed to follow/unfollow user' });
  }
});

// Get user's followers
router.get('/:username/followers', [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const user = await User.findOne({ username: req.params.username });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const followers = await User.find({
      _id: { $in: user.followers }
    })
    .select('username displayName profileImageUrl isVerified bio followerCount')
    .skip(skip)
    .limit(limit);

    res.json({
      followers,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(user.followerCount / limit),
        totalFollowers: user.followerCount,
        hasNext: page * limit < user.followerCount,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    console.error('Get followers error:', error);
    res.status(500).json({ error: 'Failed to fetch followers' });
  }
});

// Get user's following
router.get('/:username/following', [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const user = await User.findOne({ username: req.params.username });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const following = await User.find({
      _id: { $in: user.following }
    })
    .select('username displayName profileImageUrl isVerified bio followerCount')
    .skip(skip)
    .limit(limit);

    res.json({
      following,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(user.followingCount / limit),
        totalFollowing: user.followingCount,
        hasNext: page * limit < user.followingCount,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    console.error('Get following error:', error);
    res.status(500).json({ error: 'Failed to fetch following' });
  }
});

// Search users
router.get('/search', [
  query('q')
    .notEmpty()
    .withMessage('Search query is required')
    .isLength({ min: 1, max: 100 })
    .withMessage('Search query must be between 1 and 100 characters'),
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const query = req.query.q;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Search users by displayName, username, or bio
    const users = await User.find({
      $or: [
        { displayName: { $regex: query, $options: 'i' } },
        { username: { $regex: query, $options: 'i' } },
        { bio: { $regex: query, $options: 'i' } }
      ]
    })
    .select('username displayName profileImageUrl isVerified bio followerCount')
    .sort({ followerCount: -1 }) // Sort by popularity
    .skip(skip)
    .limit(limit);

    const totalUsers = await User.countDocuments({
      $or: [
        { displayName: { $regex: query, $options: 'i' } },
        { username: { $regex: query, $options: 'i' } },
        { bio: { $regex: query, $options: 'i' } }
      ]
    });

    res.json({
      users,
      query,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(totalUsers / limit),
        totalUsers,
        hasNext: page * limit < totalUsers,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    console.error('Search users error:', error);
    res.status(500).json({ error: 'Failed to search users' });
  }
});

// Get suggested users to follow
router.get('/suggestions', auth, [
  query('limit').optional().isInt({ min: 1, max: 20 }).withMessage('Limit must be between 1 and 20')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const limit = parseInt(req.query.limit) || 5;
    const currentUser = await User.findById(req.user._id);

    // Find users that the current user is not following
    const suggestions = await User.find({
      _id: { 
        $nin: [...currentUser.following, currentUser._id] 
      }
    })
    .select('username displayName profileImageUrl isVerified bio followerCount')
    .sort({ followerCount: -1 }) // Suggest popular users
    .limit(limit);

    res.json({ suggestions });
  } catch (error) {
    console.error('Get suggestions error:', error);
    res.status(500).json({ error: 'Failed to fetch suggestions' });
  }
});

module.exports = router;