# Flutter Twitter/X Clone

A comprehensive, responsive Flutter application that replicates Twitter/X functionality with modern UI design and cross-platform support.

## ✨ Features

### 🎯 Core Functionality
- **Multi-screen Navigation**: Home, Search, Notifications, Messages, Profile
- **Tweet System**: Create, like, retweet, reply to tweets
- **User Profiles**: Complete profile management with bio, stats, and media
- **Real-time Notifications**: Like, follow, mention, and reply notifications
- **Direct Messaging**: Private conversations with rich messaging interface
- **Advanced Search**: Search tweets, users, and media with filters

### 📱 Responsive Design
- **Mobile First**: Optimized bottom navigation and touch interactions
- **Tablet Layout**: Split-screen design with side navigation
- **Desktop Experience**: Three-column layout with full feature set
- **Web Compatible**: Works seamlessly across all modern browsers

### 🎨 UI/UX Excellence
- **Dark Theme**: Twitter/X-inspired dark mode design
- **Smooth Animations**: Interactive elements with fluid transitions
- **Cached Images**: Optimized image loading and caching
- **Typography**: Responsive text scaling with Google Fonts
- **Accessibility**: Proper contrast ratios and touch targets

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.9.0)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd project_x
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # Mobile/Desktop
   flutter run
   
   # Web
   flutter run -d chrome
   ```

## 📱 Platform Support

### Mobile (iOS & Android)
- Native navigation patterns
- Bottom tab navigation
- Touch-optimized interactions
- Platform-specific UI elements

### Web Browsers
- Responsive design for all screen sizes
- Mouse and keyboard support
- URL-based navigation
- Cross-browser compatibility

### Desktop (Windows, macOS, Linux)
- Desktop-optimized layouts
- Window management
- Keyboard shortcuts
- Native context menus

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants and configuration
│   ├── models/         # Data models (User, Tweet, Message, etc.)
│   ├── theme/          # Theme configuration and styling
│   └── utils/          # Utility classes and helpers
├── features/
│   ├── authentication/ # Login, signup, forgot password
│   ├── home/           # Main timeline and tweet display
│   ├── search/         # Search functionality and results
│   ├── notifications/  # Notification management
│   ├── messages/       # Direct messaging system
│   ├── profile/        # User profile management
│   └── onboarding/     # App introduction screens
├── shared/
│   ├── services/       # Navigation and other services
│   └── widgets/        # Reusable UI components
├── app.dart           # Main app configuration
└── main.dart          # App entry point
```

## 🎨 Design System

### Color Palette
- **Primary**: Blue (#1D9BF0) - Twitter/X brand color
- **Background**: Black (#000000) - Dark theme base
- **Surface**: Dark Gray (#15181C) - Card backgrounds
- **Text**: White/Gray variations for hierarchy

### Typography
- **Font Family**: Google Fonts (Poppins)
- **Responsive Scaling**: Adapts to screen size
- **Weight Hierarchy**: Bold for emphasis, regular for body text

### Components
- **Buttons**: Primary, secondary, outline, and text variants
- **Cards**: Tweet cards, user cards, notification items
- **Forms**: Custom text fields with validation
- **Navigation**: Bottom tabs, side navigation, app bars

## 📐 Responsive Breakpoints

| Device Type | Screen Width | Layout Features |
|-------------|--------------|-----------------|
| Mobile      | < 900px      | Bottom navigation, single column |
| Tablet      | 900-1200px   | Side navigation, two columns |
| Desktop     | > 1200px     | Full sidebar, three columns |

## 🛠️ Key Dependencies

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.5+1          # State management
  google_fonts: ^6.1.0        # Typography
  cached_network_image: ^3.4.1 # Image caching
  shared_preferences: ^2.5.3   # Local storage
  dio: ^5.9.0                  # HTTP client
  image_picker: ^1.1.2         # Media selection
  url_launcher: ^6.3.1         # External links
  intl: ^0.19.0               # Internationalization
```

## 🎮 User Interface Guide

### Navigation
- **Mobile**: Use bottom tabs to switch between main sections
- **Tablet/Desktop**: Use side navigation panel for quick access
- **All Platforms**: Tap profile images to view user profiles

### Tweet Interaction
- **Like**: Tap heart icon (animated feedback)
- **Retweet**: Tap repeat icon (green when active)
- **Reply**: Tap comment bubble to respond
- **Share**: Tap share icon for sharing options

### Creating Content
- **Mobile**: Tap floating action button or use tweet composer
- **Desktop**: Use inline tweet composer at top of timeline
- **Character Limit**: Visual indicator shows remaining characters

### Search & Discovery
- **Search Bar**: Located at top of search screen
- **Filters**: Use tabs to filter by content type
- **Trending**: View trending topics and hashtags
- **People**: Discover new users to follow

## 🔧 Customization

### Theme Modification
Edit `lib/core/theme/color_palette.dart` to customize colors:
```dart
class AppColors {
  static const Color blue = Color(0xFF1D9BF0); // Primary brand color
  static const Color backgroundColor = Color(0xFF000000); // Dark background
  // ... other colors
}
```

### Adding Features
1. Create feature folder in `lib/features/`
2. Add screen widgets and view models
3. Update routing in `lib/app.dart`
4. Add navigation items if needed

### Responsive Behavior
Modify breakpoints in `lib/core/utils/responsive_utils.dart`:
```dart
static const double tabletBreakpoint = 900;
static const double desktopBreakpoint = 1200;
```

## 🧪 Testing

### Manual Testing
1. **Cross-Platform**: Test on mobile, web, and desktop
2. **Responsive Design**: Resize browser window to test breakpoints
3. **Interactions**: Verify all buttons and gestures work
4. **Navigation**: Test all screen transitions

### Automated Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 🚀 Deployment

### Web Deployment
```bash
flutter build web
# Deploy contents of build/web/ to your web server
```

### Mobile Deployment
```bash
# Android
flutter build apk --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

### Desktop Deployment
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](../../issues) section
2. Review the documentation above
3. Create a new issue with detailed information about the problem

## 🎉 Acknowledgments

- Flutter team for the amazing framework
- Twitter/X for design inspiration
- Google Fonts for typography
- Material Design for UI guidelines

---

**Happy Coding!** 🚀✨
