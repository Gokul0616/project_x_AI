const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  recipient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    required: true,
    enum: ['like', 'retweet', 'reply', 'follow', 'mention', 'quote']
  },
  message: {
    type: String,
    required: true
  },
  tweet: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Tweet',
    default: null
  },
  isRead: {
    type: Boolean,
    default: false
  },
  readAt: {
    type: Date,
    default: null
  }
}, {
  timestamps: true
});

// Indexes
notificationSchema.index({ recipient: 1, createdAt: -1 });
notificationSchema.index({ sender: 1 });
notificationSchema.index({ isRead: 1 });

// Virtual for time ago
notificationSchema.virtual('timeAgo').get(function() {
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

// Static method to create notification
notificationSchema.statics.createNotification = async function(data) {
  const { recipient, sender, type, tweet } = data;
  
  // Don't create notification if user is notifying themselves
  if (recipient.toString() === sender.toString()) {
    return null;
  }

  // Generate message based on type
  let message = '';
  switch (type) {
    case 'like':
      message = 'liked your tweet';
      break;
    case 'retweet':
      message = 'retweeted your tweet';
      break;
    case 'reply':
      message = 'replied to your tweet';
      break;
    case 'follow':
      message = 'started following you';
      break;
    case 'mention':
      message = 'mentioned you in a tweet';
      break;
    case 'quote':
      message = 'quoted your tweet';
      break;
    default:
      message = 'interacted with your content';
  }

  // Check if similar notification already exists (to avoid spam)
  const existingNotification = await this.findOne({
    recipient,
    sender,
    type,
    tweet,
    createdAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) } // Within last 24 hours
  });

  if (existingNotification) {
    return existingNotification;
  }

  // Create new notification
  const notification = new this({
    recipient,
    sender,
    type,
    message,
    tweet
  });

  return await notification.save();
};

module.exports = mongoose.model('Notification', notificationSchema);