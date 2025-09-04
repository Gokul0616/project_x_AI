const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const Tweet = require('../models/Tweet');
const { authMiddleware, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/users/profile/:username
// @desc    Get user profile
// @access  Public
router.get('/profile/:username', optionalAuth, async (req, res) => {
  try {
    const { username } = req.params;
    const currentUser = req.user;

    const user = await User.findOne({ username })
      .select('-password -emailVerificationToken -passwordResetToken')
      .populate('tweetCount');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if current user is following this user
    let isFollowing = false;
    let isFollowedBy = false;
    
    if (currentUser) {
      isFollowing = currentUser.isFollowing(user._id);
      isFollowedBy = user.isFollowing(currentUser._id);
    }

    res.json({
      success: true,
      user: {
        id: user._id,
        username: user.username,
        displayName: user.displayName,
        avatar: user.avatar,
        banner: user.banner,
        bio: user.bio,
        location: user.location,
        website: user.website,
        isVerified: user.isVerified,
        isPrivate: user.isPrivate,
        followerCount: user.followerCount,
        followingCount: user.followingCount,
        tweetCount: user.tweetCount,
        joinedAt: user.createdAt,
        isFollowing,
        isFollowedBy
      }
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/users/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', authMiddleware, [
  body('displayName')
    .optional()
    .isLength({ min: 1, max: 100 })
    .withMessage('Display name must be between 1 and 100 characters'),
  body('bio')
    .optional()
    .isLength({ max: 160 })
    .withMessage('Bio must be less than 160 characters'),
  body('location')
    .optional()
    .isLength({ max: 100 })
    .withMessage('Location must be less than 100 characters'),
  body('website')
    .optional()
    .isURL()
    .withMessage('Please provide a valid URL')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { displayName, bio, location, website, birthDate } = req.body;
    const userId = req.user._id;

    const updateData = {};
    if (displayName !== undefined) updateData.displayName = displayName;
    if (bio !== undefined) updateData.bio = bio;
    if (location !== undefined) updateData.location = location;
    if (website !== undefined) updateData.website = website;
    if (birthDate !== undefined) updateData.birthDate = birthDate;

    const user = await User.findByIdAndUpdate(
      userId,
      updateData,
      { new: true }
    ).select('-password');

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user: {
        id: user._id,
        username: user.username,
        displayName: user.displayName,
        avatar: user.avatar,
        banner: user.banner,
        bio: user.bio,
        location: user.location,
        website: user.website,
        isVerified: user.isVerified,
        followerCount: user.followerCount,
        followingCount: user.followingCount
      }
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/users/follow/:userId
// @desc    Follow a user
// @access  Private
router.post('/follow/:userId', authMiddleware, async (req, res) => {
  try {
    const { userId } = req.params;
    const currentUser = req.user;

    if (currentUser._id.toString() === userId) {
      return res.status(400).json({
        success: false,
        message: 'You cannot follow yourself'
      });
    }

    const userToFollow = await User.findById(userId);
    if (!userToFollow) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    if (currentUser.isFollowing(userId)) {
      return res.status(400).json({
        success: false,
        message: 'Already following this user'
      });
    }

    await currentUser.follow(userId);

    // Emit real-time notification
    req.io.to(`user-${userId}`).emit('new-follower', {
      type: 'follow',
      user: {
        id: currentUser._id,
        username: currentUser.username,
        displayName: currentUser.displayName,
        avatar: currentUser.avatar
      },
      timestamp: new Date()
    });

    res.json({
      success: true,
      message: 'User followed successfully'
    });
  } catch (error) {
    console.error('Follow user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   DELETE /api/users/follow/:userId
// @desc    Unfollow a user
// @access  Private
router.delete('/follow/:userId', authMiddleware, async (req, res) => {
  try {
    const { userId } = req.params;
    const currentUser = req.user;

    if (currentUser._id.toString() === userId) {
      return res.status(400).json({
        success: false,
        message: 'You cannot unfollow yourself'
      });
    }

    if (!currentUser.isFollowing(userId)) {
      return res.status(400).json({
        success: false,
        message: 'Not following this user'
      });
    }

    await currentUser.unfollow(userId);

    res.json({
      success: true,
      message: 'User unfollowed successfully'
    });
  } catch (error) {
    console.error('Unfollow user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/users/:userId/followers
// @desc    Get user followers
// @access  Public
router.get('/:userId/followers', optionalAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    const { page = 1, limit = 20 } = req.query;

    const user = await User.findById(userId)
      .populate({
        path: 'followers',
        select: 'username displayName avatar isVerified bio',
        options: {
          limit: limit * 1,
          skip: (page - 1) * limit
        }
      });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Add isFollowing info if current user is authenticated
    const followersWithInfo = user.followers.map(follower => ({
      ...follower.toObject(),
      isFollowing: req.user ? req.user.isFollowing(follower._id) : false
    }));

    res.json({
      success: true,
      followers: followersWithInfo,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(user.followerCount / limit),
        totalCount: user.followerCount
      }
    });
  } catch (error) {
    console.error('Get followers error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/users/:userId/following
// @desc    Get users that this user is following
// @access  Public
router.get('/:userId/following', optionalAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    const { page = 1, limit = 20 } = req.query;

    const user = await User.findById(userId)
      .populate({
        path: 'following',
        select: 'username displayName avatar isVerified bio',
        options: {
          limit: limit * 1,
          skip: (page - 1) * limit
        }
      });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Add isFollowing info if current user is authenticated
    const followingWithInfo = user.following.map(following => ({
      ...following.toObject(),
      isFollowing: req.user ? req.user.isFollowing(following._id) : false
    }));

    res.json({
      success: true,
      following: followingWithInfo,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(user.followingCount / limit),
        totalCount: user.followingCount
      }
    });
  } catch (error) {
    console.error('Get following error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/users/search
// @desc    Search users
// @access  Public
router.get('/search', optionalAuth, async (req, res) => {
  try {
    const { q, page = 1, limit = 20 } = req.query;

    if (!q || q.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }

    const searchRegex = new RegExp(q.trim(), 'i');
    
    const users = await User.find({
      $or: [
        { username: searchRegex },
        { displayName: searchRegex },
        { bio: searchRegex }
      ]
    })
    .select('username displayName avatar isVerified bio followerCount')
    .limit(limit * 1)
    .skip((page - 1) * limit)
    .sort({ followerCount: -1 });

    // Add isFollowing info if current user is authenticated
    const usersWithInfo = users.map(user => ({
      ...user.toObject(),
      isFollowing: req.user ? req.user.isFollowing(user._id) : false
    }));

    res.json({
      success: true,
      users: usersWithInfo,
      pagination: {
        currentPage: parseInt(page),
        hasMore: users.length === parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Search users error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/users/suggestions
// @desc    Get user suggestions (who to follow)
// @access  Private
router.get('/suggestions', authMiddleware, async (req, res) => {
  try {
    const currentUser = req.user;
    const { limit = 5 } = req.query;

    // Get users that current user doesn't follow
    // Prioritize verified users and users with more followers
    const suggestions = await User.find({
      _id: { 
        $nin: [...currentUser.following, currentUser._id] 
      }
    })
    .select('username displayName avatar isVerified bio followerCount')
    .sort({ isVerified: -1, followerCount: -1 })
    .limit(parseInt(limit));

    res.json({
      success: true,
      suggestions
    });
  } catch (error) {
    console.error('Get suggestions error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/users/preferences
// @desc    Update user preferences
// @access  Private
router.put('/preferences', authMiddleware, async (req, res) => {
  try {
    const { theme, language, notifications } = req.body;
    const userId = req.user._id;

    const updateData = {};
    if (theme) updateData['preferences.theme'] = theme;
    if (language) updateData['preferences.language'] = language;
    if (notifications) {
      Object.keys(notifications).forEach(key => {
        updateData[`preferences.notifications.${key}`] = notifications[key];
      });
    }

    const user = await User.findByIdAndUpdate(
      userId,
      updateData,
      { new: true }
    ).select('preferences');

    res.json({
      success: true,
      message: 'Preferences updated successfully',
      preferences: user.preferences
    });
  } catch (error) {
    console.error('Update preferences error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;