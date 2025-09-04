const mongoose = require('mongoose');

const tweetSchema = new mongoose.Schema({
  content: {
    type: String,
    required: true,
    maxlength: 280
  },
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  media: [{
    type: {
      type: String,
      enum: ['image', 'video', 'gif'],
      required: true
    },
    url: {
      type: String,
      required: true
    },
    alt: String,
    width: Number,
    height: Number
  }],
  mentions: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  hashtags: [String],
  likes: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  retweets: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  replies: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Tweet'
  }],
  replyTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Tweet'
  },
  quoteTweet: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Tweet'
  },
  community: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Community'
  },
  isThread: {
    type: Boolean,
    default: false
  },
  threadId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Tweet'
  },
  visibility: {
    type: String,
    enum: ['public', 'followers', 'community'],
    default: 'public'
  },
  location: {
    type: String,
    maxlength: 100
  },
  analytics: {
    views: {
      type: Number,
      default: 0
    },
    clicks: {
      type: Number,
      default: 0
    },
    profileClicks: {
      type: Number,
      default: 0
    }
  },
  isPinned: {
    type: Boolean,
    default: false
  },
  isDeleted: {
    type: Boolean,
    default: false
  },
  deletedAt: Date
}, {
  timestamps: true
});

// Virtual for like count
tweetSchema.virtual('likeCount').get(function() {
  return this.likes.length;
});

// Virtual for retweet count
tweetSchema.virtual('retweetCount').get(function() {
  return this.retweets.length;
});

// Virtual for reply count
tweetSchema.virtual('replyCount').get(function() {
  return this.replies.length;
});

// Ensure virtual fields are serialized
tweetSchema.set('toJSON', { virtuals: true });

// Pre-save middleware to extract hashtags and mentions
tweetSchema.pre('save', function(next) {
  if (this.isModified('content')) {
    // Extract hashtags
    const hashtagRegex = /#\w+/g;
    const hashtags = this.content.match(hashtagRegex);
    if (hashtags) {
      this.hashtags = hashtags.map(tag => tag.toLowerCase());
    }
    
    // Extract mentions (will be populated by the route handler)
    const mentionRegex = /@\w+/g;
    const mentions = this.content.match(mentionRegex);
    if (mentions) {
      this.mentionUsernames = mentions.map(mention => mention.substring(1));
    }
  }
  next();
});

// Method to check if user liked the tweet
tweetSchema.methods.isLikedBy = function(userId) {
  return this.likes.includes(userId);
};

// Method to check if user retweeted the tweet
tweetSchema.methods.isRetweetedBy = function(userId) {
  return this.retweets.some(retweet => retweet.user.equals(userId));
};

// Method to like tweet
tweetSchema.methods.like = function(userId) {
  if (!this.isLikedBy(userId)) {
    this.likes.push(userId);
  }
};

// Method to unlike tweet
tweetSchema.methods.unlike = function(userId) {
  this.likes.pull(userId);
};

// Method to retweet
tweetSchema.methods.retweet = function(userId) {
  if (!this.isRetweetedBy(userId)) {
    this.retweets.push({ user: userId });
  }
};

// Method to unretweet
tweetSchema.methods.unretweet = function(userId) {
  this.retweets = this.retweets.filter(retweet => !retweet.user.equals(userId));
};

// Index for better query performance
tweetSchema.index({ author: 1, createdAt: -1 });
tweetSchema.index({ hashtags: 1 });
tweetSchema.index({ mentions: 1 });
tweetSchema.index({ replyTo: 1 });
tweetSchema.index({ community: 1 });
tweetSchema.index({ isDeleted: 1 });

module.exports = mongoose.model('Tweet', tweetSchema);