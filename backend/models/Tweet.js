const mongoose = require('mongoose');

const tweetSchema = new mongoose.Schema({
  content: {
    type: String,
    required: [true, 'Tweet content is required'],
    maxlength: [280, 'Tweet must be less than 280 characters'],
    trim: true
  },
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  mediaUrls: [{
    type: String
  }],
  mediaType: {
    type: String,
    enum: ['image', 'video', 'gif'],
    default: null
  },
  likes: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
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
    ref: 'Tweet',
    default: null
  },
  quoteTweet: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Tweet',
    default: null
  },
  hashtags: [{
    type: String,
    lowercase: true
  }],
  mentions: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  likesCount: {
    type: Number,
    default: 0
  },
  retweetsCount: {
    type: Number,
    default: 0
  },
  repliesCount: {
    type: Number,
    default: 0
  },
  isRetweet: {
    type: Boolean,
    default: false
  },
  originalTweet: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Tweet',
    default: null
  },
  isDeleted: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better performance
tweetSchema.index({ author: 1, createdAt: -1 });
tweetSchema.index({ hashtags: 1 });
tweetSchema.index({ mentions: 1 });
tweetSchema.index({ replyTo: 1 });
tweetSchema.index({ createdAt: -1 });

// Virtual for time ago
tweetSchema.virtual('timeAgo').get(function() {
  const now = new Date();
  const diff = now - this.createdAt;
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(diff / 3600000);
  const days = Math.floor(diff / 86400000);

  if (minutes < 1) return 'now';
  if (minutes < 60) return `${minutes}m`;
  if (hours < 24) return `${hours}h`;
  return `${days}d`;
});

// Update counts before saving
tweetSchema.pre('save', function(next) {
  this.likesCount = this.likes.length;
  this.retweetsCount = this.retweets.length;
  this.repliesCount = this.replies.length;
  next();
});

// Extract hashtags and mentions from content
tweetSchema.pre('save', function(next) {
  if (this.isModified('content')) {
    // Extract hashtags
    const hashtagRegex = /#(\w+)/g;
    const hashtags = [];
    let match;
    while ((match = hashtagRegex.exec(this.content)) !== null) {
      hashtags.push(match[1].toLowerCase());
    }
    this.hashtags = [...new Set(hashtags)]; // Remove duplicates

    // Note: Mentions extraction would require user lookup, 
    // which is better handled in the route handler
  }
  next();
});

// Instance method to check if user liked this tweet
tweetSchema.methods.isLikedBy = function(userId) {
  return this.likes.some(like => like.user.toString() === userId.toString());
};

// Instance method to check if user retweeted this tweet
tweetSchema.methods.isRetweetedBy = function(userId) {
  return this.retweets.some(retweet => retweet.user.toString() === userId.toString());
};

// Static method to get tweet with full author info
tweetSchema.statics.findWithAuthor = function(query = {}) {
  return this.find({ isDeleted: false, ...query })
    .populate('author', 'username displayName profileImageUrl isVerified')
    .populate('quoteTweet')
    .sort({ createdAt: -1 });
};

module.exports = mongoose.model('Tweet', tweetSchema);