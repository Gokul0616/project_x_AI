const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const tweetRoutes = require('./routes/tweets');
const notificationRoutes = require('./routes/notifications');
const messageRoutes = require('./routes/messages');

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(helmet());
app.use(compression());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// CORS configuration
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging middleware
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Static file serving
app.use('/uploads', express.static('uploads'));

// Database connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('✅ Connected to MongoDB');
})
.catch((error) => {
  console.error('❌ MongoDB connection error:', error);
  process.exit(1);
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/tweets', tweetRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/messages', messageRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    version: '1.0.0'
  });
});

// Default route
app.get('/', (req, res) => {
  res.json({ 
    message: 'Project X API is running!',
    version: '1.0.0',
    endpoints: [
      'GET /api/health - Health check',
      'POST /api/auth/register - User registration',
      'POST /api/auth/login - User login',
      'GET /api/tweets - Get all tweets',
      'POST /api/tweets - Create a tweet',
      'GET /api/users/profile - Get user profile',
      'GET /api/notifications - Get notifications',
      'GET /api/messages - Get messages'
    ]
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Route not found',
    message: `Cannot ${req.method} ${req.originalUrl}`
  });
});

// Global error handler
app.use((error, req, res, next) => {
  console.error('Global error handler:', error);
  
  if (error.name === 'ValidationError') {
    return res.status(400).json({
      error: 'Validation Error',
      details: Object.values(error.errors).map(err => err.message)
    });
  }
  
  if (error.name === 'CastError') {
    return res.status(400).json({
      error: 'Invalid ID format'
    });
  }
  
  if (error.code === 11000) {
    return res.status(400).json({
      error: 'Duplicate field value',
      field: Object.keys(error.keyValue)[0]
    });
  }
  
  res.status(error.status || 500).json({
    error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
    mongoose.connection.close();
  });
});

const server = app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT} in ${process.env.NODE_ENV} mode`);
  console.log(`📝 API documentation available at http://localhost:${PORT}/`);
});

module.exports = app;