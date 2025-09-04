const express = require('express');
const { body, validationResult } = require('express-validator');
const Community = require('../models/Community');
const Tweet = require('../models/Tweet');
const { authMiddleware, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/communities
// @desc    Create a community
// @access  Private
router.post('/', authMiddleware, [
  body('name')
    .isLength({ min: 2, max: 50 })
    .withMessage('Community name must be between 2 and 50 characters')
    .matches(/^[a-zA-Z0-9\s_-]+$/)
    .withMessage('Community name can only contain letters, numbers, spaces, hyphens, and underscores'),
  body('description')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Description must be less than 500 characters'),
  body('category')
    .isIn([
      'Technology', 'Sports', 'Entertainment', 'News', 'Gaming', 
      'Business', 'Science', 'Education', 'Health', 'Politics', 
      'Art', 'Music', 'Travel', 'Food', 'Fashion', 'Other'
    ])
    .withMessage('Invalid category')
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

    const { name, description, category, tags, rules, isPrivate, requireApproval } = req.body;
    const userId = req.user._id;

    // Check if community name already exists
    const existingCommunity = await Community.findOne({ name });
    if (existingCommunity) {
      return res.status(400).json({
        success: false,
        message: 'Community name already exists'
      });
    }

    const community = new Community({
      name,
      description,
      category,
      tags: tags || [],
      rules: rules || [],
      creator: userId,
      isPrivate: isPrivate || false,
      requireApproval: requireApproval || false,
      members: [{
        user: userId,
        role: 'admin'
      }]
    });

    await community.save();
    await community.populate([
      {
        path: 'creator',
        select: 'username displayName avatar isVerified'
      },
      {
        path: 'members.user',
        select: 'username displayName avatar isVerified'
      }
    ]);

    res.status(201).json({
      success: true,
      message: 'Community created successfully',
      community
    });
  } catch (error) {
    console.error('Create community error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/communities
// @desc    Get communities with filters
// @access  Public
router.get('/', optionalAuth, async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      category, 
      search, 
      sort = 'memberCount' 
    } = req.query;

    const query = { isActive: true };

    // Category filter
    if (category && category !== 'All') {
      query.category = category;
    }

    // Search filter
    if (search) {
      const searchRegex = new RegExp(search.trim(), 'i');
      query.$or = [
        { name: searchRegex },
        { description: searchRegex },
        { tags: { $in: [searchRegex] } }
      ];
    }

    // Sort options
    let sortQuery = {};
    switch (sort) {
      case 'newest':
        sortQuery = { createdAt: -1 };
        break;
      case 'oldest':
        sortQuery = { createdAt: 1 };
        break;
      case 'memberCount':
      default:
        sortQuery = { 'stats.totalPosts': -1 };
        break;
    }

    const communities = await Community.find(query)
      .populate([
        {
          path: 'creator',
          select: 'username displayName avatar isVerified'
        }
      ])
      .sort(sortQuery)
      .limit(limit * 1)
      .skip((page - 1) * limit);

    // Add user membership status if authenticated
    const communitiesWithStatus = communities.map(community => ({
      ...community.toObject(),
      isMember: req.user ? community.isMember(req.user._id) : false,
      isModerator: req.user ? community.isModerator(req.user._id) : false
    }));

    res.json({
      success: true,
      communities: communitiesWithStatus,
      pagination: {
        currentPage: parseInt(page),
        hasMore: communities.length === parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Get communities error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/communities/:communityId
// @desc    Get single community
// @access  Public
router.get('/:communityId', optionalAuth, async (req, res) => {
  try {
    const { communityId } = req.params;

    const community = await Community.findOne({
      _id: communityId,
      isActive: true
    }).populate([
      {
        path: 'creator',
        select: 'username displayName avatar isVerified'
      },
      {
        path: 'moderators',
        select: 'username displayName avatar isVerified'
      },
      {
        path: 'members.user',
        select: 'username displayName avatar isVerified',
        options: { limit: 10 }
      }
    ]);

    if (!community) {
      return res.status(404).json({
        success: false,
        message: 'Community not found'
      });
    }

    const communityWithStatus = {
      ...community.toObject(),
      isMember: req.user ? community.isMember(req.user._id) : false,
      isModerator: req.user ? community.isModerator(req.user._id) : false
    };

    res.json({
      success: true,
      community: communityWithStatus
    });
  } catch (error) {
    console.error('Get community error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/communities/:communityId/join
// @desc    Join a community
// @access  Private
router.post('/:communityId/join', authMiddleware, async (req, res) => {
  try {
    const { communityId } = req.params;
    const userId = req.user._id;

    const community = await Community.findOne({
      _id: communityId,
      isActive: true
    });

    if (!community) {
      return res.status(404).json({
        success: false,
        message: 'Community not found'
      });
    }

    if (community.isMember(userId)) {
      return res.status(400).json({
        success: false,
        message: 'Already a member of this community'
      });
    }

    community.addMember(userId);
    await community.save();

    // Emit real-time notification to community moderators
    community.moderators.forEach(modId => {
      req.io.to(`user-${modId}`).emit('new-community-member', {
        type: 'community-join',
        community: {
          id: community._id,
          name: community.name
        },
        user: {
          id: req.user._id,
          username: req.user.username,
          displayName: req.user.displayName,
          avatar: req.user.avatar
        },
        timestamp: new Date()
      });
    });

    res.json({
      success: true,
      message: 'Joined community successfully'
    });
  } catch (error) {
    console.error('Join community error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   DELETE /api/communities/:communityId/leave
// @desc    Leave a community
// @access  Private
router.delete('/:communityId/leave', authMiddleware, async (req, res) => {
  try {
    const { communityId } = req.params;
    const userId = req.user._id;

    const community = await Community.findById(communityId);
    if (!community) {
      return res.status(404).json({
        success: false,
        message: 'Community not found'
      });
    }

    if (!community.isMember(userId)) {
      return res.status(400).json({
        success: false,
        message: 'Not a member of this community'
      });
    }

    if (community.creator.equals(userId)) {
      return res.status(400).json({
        success: false,
        message: 'Community creator cannot leave. Transfer ownership first.'
      });
    }

    community.removeMember(userId);
    await community.save();

    res.json({
      success: true,
      message: 'Left community successfully'
    });
  } catch (error) {
    console.error('Leave community error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/communities/:communityId/posts
// @desc    Get community posts
// @access  Public
router.get('/:communityId/posts', optionalAuth, async (req, res) => {
  try {
    const { communityId } = req.params;
    const { page = 1, limit = 20, sort = 'newest' } = req.query;

    const community = await Community.findOne({
      _id: communityId,
      isActive: true
    });

    if (!community) {
      return res.status(404).json({
        success: false,
        message: 'Community not found'
      });
    }

    // Check if user can view posts (for private communities)
    if (community.isPrivate && (!req.user || !community.isMember(req.user._id))) {
      return res.status(403).json({
        success: false,
        message: 'Private community - membership required'
      });
    }

    let sortQuery = {};
    switch (sort) {
      case 'popular':
        sortQuery = { likeCount: -1, retweetCount: -1 };
        break;
      case 'newest':
      default:
        sortQuery = { createdAt: -1 };
        break;
    }

    const posts = await Tweet.find({
      community: communityId,
      isDeleted: false
    })
    .populate([
      {
        path: 'author',
        select: 'username displayName avatar isVerified'
      },
      {
        path: 'quoteTweet',
        populate: {
          path: 'author',
          select: 'username displayName avatar isVerified'
        }
      }
    ])
    .sort(sortQuery)
    .limit(limit * 1)
    .skip((page - 1) * limit);

    // Add user interaction status if authenticated
    const postsWithUserStatus = posts.map(post => ({
      ...post.toObject(),
      isLiked: req.user ? post.isLikedBy(req.user._id) : false,
      isRetweeted: req.user ? post.isRetweetedBy(req.user._id) : false
    }));

    res.json({
      success: true,
      posts: postsWithUserStatus,
      pagination: {
        currentPage: parseInt(page),
        hasMore: posts.length === parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Get community posts error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/communities/my-communities
// @desc    Get user's communities
// @access  Private
router.get('/my-communities', authMiddleware, async (req, res) => {
  try {
    const userId = req.user._id;

    const communities = await Community.find({
      'members.user': userId,
      isActive: true
    })
    .populate([
      {
        path: 'creator',
        select: 'username displayName avatar isVerified'
      }
    ])
    .sort({ 'members.joinedAt': -1 });

    const communitiesWithStatus = communities.map(community => {
      const member = community.members.find(m => m.user.equals(userId));
      return {
        ...community.toObject(),
        memberRole: member ? member.role : null,
        joinedAt: member ? member.joinedAt : null
      };
    });

    res.json({
      success: true,
      communities: communitiesWithStatus
    });
  } catch (error) {
    console.error('Get my communities error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/communities/discover
// @desc    Get recommended communities
// @access  Private
router.get('/discover', authMiddleware, async (req, res) => {
  try {
    const userId = req.user._id;
    const { limit = 10 } = req.query;

    // Get communities user is not part of
    const userCommunities = await Community.find({
      'members.user': userId
    }).select('_id');

    const userCommunityIds = userCommunities.map(c => c._id);

    const recommendedCommunities = await Community.find({
      _id: { $nin: userCommunityIds },
      isActive: true,
      isPrivate: false
    })
    .populate([
      {
        path: 'creator',
        select: 'username displayName avatar isVerified'
      }
    ])
    .sort({ memberCount: -1, 'stats.totalPosts': -1 })
    .limit(parseInt(limit));

    res.json({
      success: true,
      communities: recommendedCommunities
    });
  } catch (error) {
    console.error('Get discover communities error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/communities/categories
// @desc    Get community categories with counts
// @access  Public
router.get('/categories', async (req, res) => {
  try {
    const categories = await Community.aggregate([
      { $match: { isActive: true } },
      { 
        $group: { 
          _id: '$category', 
          count: { $sum: 1 },
          totalMembers: { $sum: { $size: '$members' } }
        } 
      },
      { $sort: { count: -1 } }
    ]);

    const formattedCategories = categories.map(cat => ({
      name: cat._id,
      communityCount: cat.count,
      totalMembers: cat.totalMembers
    }));

    res.json({
      success: true,
      categories: formattedCategories
    });
  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;