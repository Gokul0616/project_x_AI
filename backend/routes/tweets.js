const express = require('express');
const { body, validationResult } = require('express-validator');
const Tweet = require('../models/Tweet');
const User = require('../models/User');
const { authMiddleware, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/tweets
// @desc    Create a tweet
// @access  Private
router.post('/', authMiddleware, [
  body('content')
    .isLength({ min: 1, max: 280 })
    .withMessage('Tweet content must be between 1 and 280 characters'),
  body('replyTo')
    .optional()
    .isMongoId()
    .withMessage('Invalid reply tweet ID'),
  body('quoteTweet')
    .optional()
    .isMongoId()
    .withMessage('Invalid quote tweet ID')
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

    const { content, media, replyTo, quoteTweet, community, location } = req.body;
    const userId = req.user._id;

    const tweet = new Tweet({
      content,
      author: userId,
      media: media || [],
      replyTo,
      quoteTweet,
      community,
      location
    });

    // Extract mentions and populate them
    if (tweet.mentionUsernames) {
      const mentionedUsers = await User.find({
        username: { $in: tweet.mentionUsernames }
      }).select('_id');
      tweet.mentions = mentionedUsers.map(user => user._id);
    }

    await tweet.save();
    await tweet.populate([
      {
        path: 'author',
        select: 'username displayName avatar isVerified'
      },
      {
        path: 'mentions',
        select: 'username displayName'
      },
      {
        path: 'quoteTweet',
        populate: {
          path: 'author',
          select: 'username displayName avatar isVerified'
        }
      }
    ]);

    // If it's a reply, add to parent tweet's replies
    if (replyTo) {
      const parentTweet = await Tweet.findById(replyTo);
      if (parentTweet) {
        parentTweet.replies.push(tweet._id);
        await parentTweet.save();

        // Emit real-time notification to parent tweet author
        req.io.to(`user-${parentTweet.author}`).emit('new-reply', {
          type: 'reply',
          tweet: tweet,
          parentTweet: parentTweet,
          timestamp: new Date()
        });
      }
    }

    // Emit real-time notification to mentioned users
    if (tweet.mentions.length > 0) {
      tweet.mentions.forEach(mentionedUser => {
        req.io.to(`user-${mentionedUser._id}`).emit('new-mention', {
          type: 'mention',
          tweet: tweet,
          timestamp: new Date()
        });
      });
    }

    // Emit to community if tweet is in a community
    if (community) {
      req.io.to(`community-${community}`).emit('new-community-tweet', {
        tweet: tweet,
        timestamp: new Date()
      });
    }

    res.status(201).json({
      success: true,
      message: 'Tweet created successfully',
      tweet
    });
  } catch (error) {
    console.error('Create tweet error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/tweets/feed
// @desc    Get user timeline/feed
// @access  Private
router.get('/feed', authMiddleware, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const userId = req.user._id;

    // Get tweets from users that current user follows + own tweets
    const followingIds = [...req.user.following, userId];

    const tweets = await Tweet.find({
      author: { $in: followingIds },
      isDeleted: false,
      replyTo: null // Don't include replies in main feed
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
      },
      {
        path: 'replies',
        populate: {
          path: 'author',
          select: 'username displayName avatar isVerified'
        },
        options: { limit: 3, sort: { createdAt: -1 } }
      }
    ])
    .sort({ createdAt: -1 })
    .limit(limit * 1)
    .skip((page - 1) * limit);

    // Add user interaction status
    const tweetsWithUserStatus = tweets.map(tweet => ({
      ...tweet.toObject(),
      isLiked: tweet.isLikedBy(userId),
      isRetweeted: tweet.isRetweetedBy(userId)
    }));

    res.json({
      success: true,
      tweets: tweetsWithUserStatus,
      pagination: {
        currentPage: parseInt(page),
        hasMore: tweets.length === parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Get feed error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/tweets/explore
// @desc    Get explore/trending tweets
// @access  Public
router.get('/explore', optionalAuth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;

    // Get popular tweets from last 24 hours
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

    const tweets = await Tweet.find({
      isDeleted: false,
      createdAt: { $gte: oneDayAgo },
      replyTo: null
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
    .sort({ 
      likeCount: -1, 
      retweetCount: -1, 
      createdAt: -1 
    })
    .limit(limit * 1)
    .skip((page - 1) * limit);

    // Add user interaction status if authenticated
    const tweetsWithUserStatus = tweets.map(tweet => ({
      ...tweet.toObject(),
      isLiked: req.user ? tweet.isLikedBy(req.user._id) : false,
      isRetweeted: req.user ? tweet.isRetweetedBy(req.user._id) : false
    }));

    res.json({
      success: true,
      tweets: tweetsWithUserStatus,
      pagination: {
        currentPage: parseInt(page),
        hasMore: tweets.length === parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Get explore tweets error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/tweets/:tweetId
// @desc    Get single tweet with replies
// @access  Public
router.get('/:tweetId', optionalAuth, async (req, res) => {
  try {
    const { tweetId } = req.params;

    const tweet = await Tweet.findById(tweetId)
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
        },
        {
          path: 'replies',
          populate: [
            {
              path: 'author',
              select: 'username displayName avatar isVerified'
            },
            {
              path: 'replies',
              populate: {
                path: 'author',
                select: 'username displayName avatar isVerified'
              }
            }
          ],
          options: { sort: { createdAt: 1 } }
        }
      ]);

    if (!tweet || tweet.isDeleted) {
      return res.status(404).json({
        success: false,
        message: 'Tweet not found'
      });
    }

    // Increment view count
    tweet.analytics.views += 1;
    await tweet.save();

    const tweetWithUserStatus = {
      ...tweet.toObject(),
      isLiked: req.user ? tweet.isLikedBy(req.user._id) : false,
      isRetweeted: req.user ? tweet.isRetweetedBy(req.user._id) : false
    };

    res.json({
      success: true,
      tweet: tweetWithUserStatus
    });
  } catch (error) {
    console.error('Get tweet error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/tweets/:tweetId/like
// @desc    Like/unlike a tweet
// @access  Private
router.post('/:tweetId/like', authMiddleware, async (req, res) => {
  try {
    const { tweetId } = req.params;
    const userId = req.user._id;

    const tweet = await Tweet.findById(tweetId);
    if (!tweet || tweet.isDeleted) {
      return res.status(404).json({
        success: false,
        message: 'Tweet not found'
      });
    }

    const isLiked = tweet.isLikedBy(userId);

    if (isLiked) {
      tweet.unlike(userId);
    } else {
      tweet.like(userId);
      
      // Emit real-time notification to tweet author
      if (!tweet.author.equals(userId)) {
        req.io.to(`user-${tweet.author}`).emit('new-like', {
          type: 'like',
          user: {
            id: req.user._id,
            username: req.user.username,
            displayName: req.user.displayName,
            avatar: req.user.avatar
          },
          tweet: {
            id: tweet._id,
            content: tweet.content.substring(0, 50) + '...'
          },
          timestamp: new Date()
        });
      }
    }

    await tweet.save();

    res.json({
      success: true,
      message: isLiked ? 'Tweet unliked' : 'Tweet liked',
      isLiked: !isLiked,
      likeCount: tweet.likeCount
    });
  } catch (error) {
    console.error('Like tweet error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/tweets/:tweetId/retweet
// @desc    Retweet/unretweet a tweet
// @access  Private
router.post('/:tweetId/retweet', authMiddleware, async (req, res) => {
  try {
    const { tweetId } = req.params;
    const userId = req.user._id;

    const tweet = await Tweet.findById(tweetId);
    if (!tweet || tweet.isDeleted) {
      return res.status(404).json({
        success: false,
        message: 'Tweet not found'
      });
    }

    const isRetweeted = tweet.isRetweetedBy(userId);

    if (isRetweeted) {
      tweet.unretweet(userId);
    } else {
      tweet.retweet(userId);
      
      // Emit real-time notification to tweet author
      if (!tweet.author.equals(userId)) {
        req.io.to(`user-${tweet.author}`).emit('new-retweet', {
          type: 'retweet',
          user: {
            id: req.user._id,
            username: req.user.username,
            displayName: req.user.displayName,
            avatar: req.user.avatar
          },
          tweet: {
            id: tweet._id,
            content: tweet.content.substring(0, 50) + '...'
          },
          timestamp: new Date()
        });
      }
    }

    await tweet.save();

    res.json({
      success: true,
      message: isRetweeted ? 'Tweet unretweeted' : 'Tweet retweeted',
      isRetweeted: !isRetweeted,
      retweetCount: tweet.retweetCount
    });
  } catch (error) {
    console.error('Retweet error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   DELETE /api/tweets/:tweetId
// @desc    Delete a tweet
// @access  Private
router.delete('/:tweetId', authMiddleware, async (req, res) => {
  try {
    const { tweetId } = req.params;
    const userId = req.user._id;

    const tweet = await Tweet.findById(tweetId);
    if (!tweet || tweet.isDeleted) {
      return res.status(404).json({
        success: false,
        message: 'Tweet not found'
      });
    }

    if (!tweet.author.equals(userId)) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this tweet'
      });
    }

    tweet.isDeleted = true;
    tweet.deletedAt = new Date();
    await tweet.save();

    res.json({
      success: true,
      message: 'Tweet deleted successfully'
    });
  } catch (error) {
    console.error('Delete tweet error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/tweets/user/:username
// @desc    Get user's tweets
// @access  Public
router.get('/user/:username', optionalAuth, async (req, res) => {
  try {
    const { username } = req.params;
    const { page = 1, limit = 20, include_replies = false } = req.query;

    const user = await User.findOne({ username });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const query = {
      author: user._id,
      isDeleted: false
    };

    // Exclude replies unless specifically requested
    if (include_replies !== 'true') {
      query.replyTo = null;
    }

    const tweets = await Tweet.find(query)
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
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    // Add user interaction status if authenticated
    const tweetsWithUserStatus = tweets.map(tweet => ({
      ...tweet.toObject(),
      isLiked: req.user ? tweet.isLikedBy(req.user._id) : false,
      isRetweeted: req.user ? tweet.isRetweetedBy(req.user._id) : false
    }));

    res.json({
      success: true,
      tweets: tweetsWithUserStatus,
      pagination: {
        currentPage: parseInt(page),
        hasMore: tweets.length === parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Get user tweets error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/tweets/search
// @desc    Search tweets
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
    
    const tweets = await Tweet.find({
      $or: [
        { content: searchRegex },
        { hashtags: { $in: [q.trim().toLowerCase()] } }
      ],
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
    .sort({ createdAt: -1 })
    .limit(limit * 1)
    .skip((page - 1) * limit);

    // Add user interaction status if authenticated
    const tweetsWithUserStatus = tweets.map(tweet => ({
      ...tweet.toObject(),
      isLiked: req.user ? tweet.isLikedBy(req.user._id) : false,
      isRetweeted: req.user ? tweet.isRetweetedBy(req.user._id) : false
    }));

    res.json({
      success: true,
      tweets: tweetsWithUserStatus,
      pagination: {
        currentPage: parseInt(page),
        hasMore: tweets.length === parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Search tweets error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;