const mongoose = require('mongoose');

const communitySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 2,
    maxlength: 50
  },
  description: {
    type: String,
    maxlength: 500,
    default: ''
  },
  avatar: {
    type: String,
    default: ''
  },
  banner: {
    type: String,
    default: ''
  },
  creator: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  moderators: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  members: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    joinedAt: {
      type: Date,
      default: Date.now
    },
    role: {
      type: String,
      enum: ['member', 'moderator', 'admin'],
      default: 'member'
    }
  }],
  category: {
    type: String,
    required: true,
    enum: [
      'Technology',
      'Sports',
      'Entertainment',
      'News',
      'Gaming',
      'Business',
      'Science',
      'Education',
      'Health',
      'Politics',
      'Art',
      'Music',
      'Travel',
      'Food',
      'Fashion',
      'Other'
    ]
  },
  tags: [String],
  rules: [{
    title: {
      type: String,
      required: true,
      maxlength: 100
    },
    description: {
      type: String,
      required: true,
      maxlength: 500
    }
  }],
  isPrivate: {
    type: Boolean,
    default: false
  },
  requireApproval: {
    type: Boolean,
    default: false
  },
  allowedPostTypes: [{
    type: String,
    enum: ['text', 'image', 'video', 'poll', 'link'],
    default: ['text', 'image', 'video', 'poll', 'link']
  }],
  settings: {
    allowMemberInvites: {
      type: Boolean,
      default: true
    },
    allowExternalSharing: {
      type: Boolean,
      default: true
    },
    moderationLevel: {
      type: String,
      enum: ['low', 'medium', 'high'],
      default: 'medium'
    }
  },
  stats: {
    totalPosts: {
      type: Number,
      default: 0
    },
    totalViews: {
      type: Number,
      default: 0
    },
    weeklyGrowth: {
      type: Number,
      default: 0
    }
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Virtual for member count
communitySchema.virtual('memberCount').get(function() {
  return this.members.length;
});

// Ensure virtual fields are serialized
communitySchema.set('toJSON', { virtuals: true });

// Method to check if user is member
communitySchema.methods.isMember = function(userId) {
  return this.members.some(member => member.user.equals(userId));
};

// Method to check if user is moderator
communitySchema.methods.isModerator = function(userId) {
  const member = this.members.find(member => member.user.equals(userId));
  return member && (member.role === 'moderator' || member.role === 'admin');
};

// Method to add member
communitySchema.methods.addMember = function(userId, role = 'member') {
  if (!this.isMember(userId)) {
    this.members.push({ user: userId, role });
  }
};

// Method to remove member
communitySchema.methods.removeMember = function(userId) {
  this.members = this.members.filter(member => !member.user.equals(userId));
};

// Method to update member role
communitySchema.methods.updateMemberRole = function(userId, newRole) {
  const member = this.members.find(member => member.user.equals(userId));
  if (member) {
    member.role = newRole;
  }
};

// Index for better query performance
communitySchema.index({ name: 1 });
communitySchema.index({ category: 1 });
communitySchema.index({ tags: 1 });
communitySchema.index({ 'members.user': 1 });
communitySchema.index({ isActive: 1 });

module.exports = mongoose.model('Community', communitySchema);