# Twitter Clone - Complete Setup Guide

## 🚀 What You've Built

This is a **complete Twitter clone** with:

### ✅ **Backend Features (Node.js + MongoDB)**
- **Authentication**: Email/password login with JWT tokens
- **Tweet System**: Create, like, retweet, reply with nested threading
- **Communities**: Create and join communities, community-specific posts
- **Direct Messages**: Real-time messaging with Socket.IO
- **User Management**: Follow/unfollow, user profiles, search
- **File Upload**: Local image storage with image processing
- **Real-time Features**: Live notifications, typing indicators

### ✅ **Frontend Features (Flutter)**
- **Mobile-First Design**: Twitter-like UI with drawer navigation
- **Account Switching**: Multi-account support with account switcher
- **Communities**: Browse, join, create communities
- **Real-time Updates**: Live tweets, notifications, messages
- **Advanced Tweet Features**: Nested replies, quote tweets, media support
- **Profile Management**: Edit profiles, follow/unfollow users

## 🛠️ Setup Instructions

### 1. **Backend Setup**

1. **Install Dependencies** (if not done):
   ```bash
   cd backend
   npm install
   ```

2. **Set up MongoDB**:
   - Install MongoDB locally OR use MongoDB Atlas (cloud)
   - Update the `MONGODB_URI` in `backend/.env` file
   - Example: `MONGODB_URI=mongodb://localhost:27017/twitter_clone`

3. **Start Backend**:
   ```bash
   cd backend
   npm run dev
   ```
   
   Or use the convenience script:
   ```bash
   chmod +x start_backend.sh
   ./start_backend.sh
   ```

4. **Verify Backend**: Visit http://localhost:5000/api/health

### 2. **Flutter Setup**

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Update API URL** (if needed):
   - In `lib/core/services/api_service.dart`, update `baseUrl` if your backend isn't on localhost:5000

3. **Run Flutter App**:
   ```bash
   flutter run
   ```

## 🔧 Key Configuration

### Backend Environment Variables (.env)
```env
MONGODB_URI=mongodb://localhost:27017/twitter_clone  # ⚠️ Update this!
JWT_SECRET=your_super_secret_jwt_key_here_make_it_long_and_random_12345
PORT=5000
NODE_ENV=development
```

### API Endpoints Available
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user  
- `GET /api/tweets/feed` - Get user timeline
- `POST /api/tweets` - Create tweet
- `GET /api/communities` - Get communities
- `GET /api/messages/conversations` - Get conversations
- And many more...

## 🎯 How to Test

### 1. **Create Test Accounts**
1. Register multiple accounts using different emails
2. Test account switching in the mobile drawer

### 2. **Test Core Features**
- ✅ Register/Login with email
- ✅ Create tweets with text and images
- ✅ Like, retweet, reply to tweets
- ✅ Follow/unfollow users
- ✅ Join communities
- ✅ Send direct messages
- ✅ Real-time notifications

### 3. **Test Advanced Features**
- ✅ Nested tweet replies (multi-level threading)
- ✅ Account switching in drawer
- ✅ Community discovery and joining
- ✅ Real-time message delivery
- ✅ Image upload and display

## 📱 Flutter App Features

### **Main Screens**
- **Home Feed**: Timeline with tweets from followed users
- **Search/Explore**: Trending tweets and user search
- **Communities**: Browse and join communities
- **Notifications**: Real-time activity feed
- **Messages**: Direct messaging with real-time updates
- **Profile**: User profiles with tweets, replies, media

### **Drawer Navigation**
- Account switcher with multi-account support
- Quick access to profile, communities, settings
- Sign out functionality

### **Account Management**
- Switch between multiple logged-in accounts
- Add new accounts without losing current session
- Remove accounts from switcher

## 🔐 Authentication Flow

1. **Registration**: Email + password → JWT token
2. **Login**: Email/username + password → JWT token  
3. **Token Storage**: Secure local storage
4. **Auto-login**: Persistent sessions
5. **Multi-account**: Multiple JWT tokens managed

## 🌐 Real-time Features

### **Socket.IO Events**
- `new-message`: Real-time message delivery
- `new-follower`: Follow notifications
- `new-like`: Tweet like notifications
- `new-retweet`: Retweet notifications
- `typing`: Typing indicators in DMs

## 📊 Database Schema

### **Collections**
- `users`: User accounts and profiles
- `tweets`: Tweets with nested replies
- `communities`: Community information
- `conversations`: DM conversations
- `messages`: Direct messages

## 🚀 Production Deployment

### **Backend**
1. Set `NODE_ENV=production`
2. Use production MongoDB (Atlas recommended)
3. Set strong JWT secret
4. Configure CORS for your domain
5. Set up SSL/HTTPS

### **Flutter**
1. Update API base URL to production server
2. Build release APK: `flutter build apk --release`
3. Test on real devices

## 🐛 Troubleshooting

### **Common Issues**

1. **Backend won't start**:
   - Check MongoDB is running
   - Verify .env file configuration
   - Check port 5000 isn't in use

2. **Flutter API calls fail**:
   - Verify backend is running on correct port
   - Check API base URL in api_service.dart
   - Ensure CORS is configured

3. **Real-time features not working**:
   - Check Socket.IO connection
   - Verify websocket support
   - Check firewall settings

4. **Image upload fails**:
   - Check uploads directory exists
   - Verify file permissions
   - Check MAX_FILE_SIZE setting

## 🎉 You're All Set!

Your **complete Twitter clone** is ready with:
- ✅ Full backend API with authentication
- ✅ Real-time messaging and notifications  
- ✅ Communities and social features
- ✅ Mobile-first Flutter UI
- ✅ Account switching and management
- ✅ Image upload and media support

**Next Steps**:
1. Start the backend: `./start_backend.sh`
2. Run Flutter: `flutter run`
3. Create test accounts and explore!

Enjoy your fully functional Twitter clone! 🐦✨