const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: [true, 'Username is required'],
    unique: true,
    trim: true,
    minlength: [3, 'Username must be at least 3 characters long'],
    maxlength: [20, 'Username must be less than 20 characters'],
    match: [/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers, and underscores']
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    trim: true,
    lowercase: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [6, 'Password must be at least 6 characters long'],
    select: false // Don't include password in queries by default
  },
  displayName: {
    type: String,
    required: [true, 'Display name is required'],
    trim: true,
    maxlength: [50, 'Display name must be less than 50 characters']
  },
  bio: {
    type: String,
    maxlength: [160, 'Bio must be less than 160 characters'],
    default: ''
  },
  location: {
    type: String,
    maxlength: [50, 'Location must be less than 50 characters'],
    default: ''
  },
  website: {
    type: String,
    maxlength: [100, 'Website URL must be less than 100 characters'],
    default: ''
  },
  profileImageUrl: {
    type: String,
    default: ''
  },
  bannerImageUrl: {
    type: String,
    default: ''
  },
  followers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  following: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  followerCount: {
    type: Number,
    default: 0
  },
  followingCount: {
    type: Number,
    default: 0
  },
  tweetsCount: {
    type: Number,
    default: 0
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  isPrivate: {
    type: Boolean,
    default: false
  },
  joinedDate: {
    type: Date,
    default: Date.now
  },
  lastActive: {
    type: Date,
    default: Date.now
  },
  isOnline: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better performance
userSchema.index({ username: 1 });
userSchema.index({ email: 1 });
userSchema.index({ displayName: 'text', bio: 'text' });

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Update follower/following counts
userSchema.pre('save', function(next) {
  this.followerCount = this.followers.length;
  this.followingCount = this.following.length;
  next();
});

// Instance method to check password
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Instance method to get public profile
userSchema.methods.getPublicProfile = function() {
  const user = this.toObject();
  delete user.password;
  delete user.email;
  return user;
};

// Static method to find by username or email
userSchema.statics.findByCredentials = async function(identifier) {
  const user = await this.findOne({
    $or: [
      { username: identifier },
      { email: identifier }
    ]
  }).select('+password');
  
  return user;
};

module.exports = mongoose.model('User', userSchema);