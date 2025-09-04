const express = require('express');
const { body, query, validationResult } = require('express-validator');
const Tweet = require('../models/Tweet');
const User = require('../models/User');
const Notification = require('../models/Notification');
const { auth, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// Get all tweets (public timeline)
router.get('/', optionalAuth, [
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

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const tweets = await Tweet.findWithAuthor()
      .skip(skip)
      .limit(limit)
      .lean();

    // Add user-specific data if authenticated
    if (req.user) {
      tweets.forEach(tweet => {
        tweet.isLiked = tweet.likes.some(like => like.user.toString() === req.user._id.toString());
        tweet.isRetweeted = tweet.retweets.some(retweet => retweet.user.toString() === req.user._id.toString());
      });
    }

    const totalTweets = await Tweet.countDocuments({ isDeleted: false });

    res.json({
      tweets,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(totalTweets / limit),
        totalTweets,
        hasNext: page * limit < totalTweets,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    console.error('Get tweets error:', error);
    res.status(500).json({ error: 'Failed to fetch tweets' });
  }
});

// Get single tweet by ID
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const tweet = await Tweet.findById(req.params.id)
      .populate('author', 'username displayName profileImageUrl isVerified')
      .populate('quoteTweet')
      .populate({
        path: 'replies',
        populate: {
          path: 'author',
          select: 'username displayName profileImageUrl isVerified'
        }
      });

    if (!tweet || tweet.isDeleted) {
      return res.status(404).json({ error: 'Tweet not found' });
    }

    // Add user-specific data if authenticated
    if (req.user) {
      tweet.isLiked = tweet.isLikedBy(req.user._id);
      tweet.isRetweeted = tweet.isRetweetedBy(req.user._id);
    }

    res.json({ tweet });
  } catch (error) {
    console.error('Get tweet error:', error);
    res.status(500).json({ error: 'Failed to fetch tweet' });
  }
});

// Create new tweet
router.post('/', auth, [
  body('content')
    .isLength({ min: 1, max: 280 })
    .withMessage('Tweet content must be between 1 and 280 characters'),
  body('mediaUrls')
    .optional()
    .isArray({ max: 4 })
    .withMessage('Maximum 4 media files allowed'),
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
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { content, mediaUrls = [], replyTo, quoteTweet } = req.body;

    // Validate reply tweet exists
    if (replyTo) {
      const parentTweet = await Tweet.findById(replyTo);
      if (!parentTweet || parentTweet.isDeleted) {
        return res.status(400).json({ error: 'Reply tweet not found' });
      }
    }

    // Validate quote tweet exists
    if (quoteTweet) {
      const quotedTweet = await Tweet.findById(quoteTweet);
      if (!quotedTweet || quotedTweet.isDeleted) {
        return res.status(400).json({ error: 'Quoted tweet not found' });
      }
    }

    // Create tweet
    const tweet = new Tweet({
      content,
      author: req.user._id,
      mediaUrls,
      replyTo,
      quoteTweet
    });

    await tweet.save();

    // Update reply count if this is a reply
    if (replyTo) {
      await Tweet.findByIdAndUpdate(replyTo, {
        $push: { replies: tweet._id }
      });
      
      // Create notification for reply
      const parentTweet = await Tweet.findById(replyTo);
      await Notification.createNotification({
        recipient: parentTweet.author,
        sender: req.user._id,
        type: 'reply',
        tweet: tweet._id
      });
    }

    // Create notification for quote tweet
    if (quoteTweet) {
      const quotedTweet = await Tweet.findById(quoteTweet);
      await Notification.createNotification({
        recipient: quotedTweet.author,
        sender: req.user._id,
        type: 'quote',
        tweet: tweet._id
      });
    }

    // Update user tweet count
    await User.findByIdAndUpdate(req.user._id, {
      $inc: { tweetsCount: 1 }
    });

    // Populate and return the created tweet
    const populatedTweet = await Tweet.findById(tweet._id)
      .populate('author', 'username displayName profileImageUrl isVerified');

    res.status(201).json({
      message: 'Tweet created successfully',
      tweet: populatedTweet
    });
  } catch (error) {
    console.error('Create tweet error:', error);
    res.status(500).json({ error: 'Failed to create tweet' });
  }
});

// Like/Unlike tweet
router.post('/:id/like', auth, async (req, res) => {
  try {
    const tweet = await Tweet.findById(req.params.id);
    if (!tweet || tweet.isDeleted) {
      return res.status(404).json({ error: 'Tweet not found' });
    }

    const isLiked = tweet.isLikedBy(req.user._id);

    if (isLiked) {
      // Unlike
      tweet.likes = tweet.likes.filter(like => like.user.toString() !== req.user._id.toString());
    } else {
      // Like
      tweet.likes.push({ user: req.user._id });
      
      // Create notification for like
      await Notification.createNotification({
        recipient: tweet.author,
        sender: req.user._id,
        type: 'like',
        tweet: tweet._id
      });
    }

    await tweet.save();

    res.json({
      message: isLiked ? 'Tweet unliked' : 'Tweet liked',
      isLiked: !isLiked,
      likesCount: tweet.likesCount
    });
  } catch (error) {
    console.error('Like tweet error:', error);
    res.status(500).json({ error: 'Failed to like tweet' });
  }
});

// Retweet/Unretweet
router.post('/:id/retweet', auth, async (req, res) => {
  try {
    const tweet = await Tweet.findById(req.params.id);
    if (!tweet || tweet.isDeleted) {
      return res.status(404).json({ error: 'Tweet not found' });
    }

    const isRetweeted = tweet.isRetweetedBy(req.user._id);

    if (isRetweeted) {
      // Unretweet
      tweet.retweets = tweet.retweets.filter(retweet => retweet.user.toString() !== req.user._id.toString());
    } else {
      // Retweet
      tweet.retweets.push({ user: req.user._id });
      
      // Create notification for retweet
      await Notification.createNotification({
        recipient: tweet.author,
        sender: req.user._id,
        type: 'retweet',
        tweet: tweet._id
      });
    }

    await tweet.save();

    res.json({
      message: isRetweeted ? 'Tweet unretweeted' : 'Tweet retweeted',
      isRetweeted: !isRetweeted,
      retweetsCount: tweet.retweetsCount
    });
  } catch (error) {
    console.error('Retweet error:', error);
    res.status(500).json({ error: 'Failed to retweet' });
  }
});

// Delete tweet
router.delete('/:id', auth, async (req, res) => {
  try {
    const tweet = await Tweet.findById(req.params.id);
    if (!tweet || tweet.isDeleted) {
      return res.status(404).json({ error: 'Tweet not found' });
    }

    // Check if user owns the tweet
    if (tweet.author.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Not authorized to delete this tweet' });
    }

    // Soft delete
    tweet.isDeleted = true;
    await tweet.save();

    // Update user tweet count
    await User.findByIdAndUpdate(req.user._id, {
      $inc: { tweetsCount: -1 }
    });

    res.json({ message: 'Tweet deleted successfully' });
  } catch (error) {
    console.error('Delete tweet error:', error);
    res.status(500).json({ error: 'Failed to delete tweet' });
  }
});

// Get user's tweets
router.get('/user/:username', optionalAuth, [
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

    const tweets = await Tweet.findWithAuthor({ author: user._id })
      .skip(skip)
      .limit(limit)
      .lean();

    // Add user-specific data if authenticated
    if (req.user) {
      tweets.forEach(tweet => {
        tweet.isLiked = tweet.likes.some(like => like.user.toString() === req.user._id.toString());
        tweet.isRetweeted = tweet.retweets.some(retweet => retweet.user.toString() === req.user._id.toString());
      });
    }

    const totalTweets = await Tweet.countDocuments({ author: user._id, isDeleted: false });

    res.json({
      tweets,
      user: user.getPublicProfile(),
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(totalTweets / limit),
        totalTweets,
        hasNext: page * limit < totalTweets,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    console.error('Get user tweets error:', error);
    res.status(500).json({ error: 'Failed to fetch user tweets' });
  }
});

module.exports = router;