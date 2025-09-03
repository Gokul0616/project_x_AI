import 'package:flutter/material.dart';
import 'package:project_x/core/constants/asset_constants.dart';
import 'package:project_x/core/constants/route_constants.dart';
import 'package:project_x/core/theme/app_theme.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/features/authentication/auth_viewmodel.dart';
import 'package:project_x/features/authentication/forgot_password_screen.dart';
import 'package:project_x/features/authentication/login_screen.dart';
import 'package:project_x/features/authentication/signup_screen.dart';
import 'package:project_x/features/home/home_screen.dart';
import 'package:project_x/features/home/home_viewmodel.dart';
import 'package:project_x/features/onboarding/onboarding_screen.dart';
import 'package:project_x/features/onboarding/onboarding_viewmodel.dart';
import 'package:project_x/features/search/search_screen.dart';
import 'package:project_x/features/notifications/notifications_screen.dart';
import 'package:project_x/features/messages/messages_screen.dart';
import 'package:project_x/features/profile/profile_screen.dart';
import 'package:project_x/shared/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_x/core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding =
        prefs.getBool(AppConstants.hasSeenOnboardingKey) ?? false;
    final isLoggedIn = prefs.getString(AppConstants.authTokenKey) != null;

    if (!hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, RouteConstants.onboarding);
    } else if (!isLoggedIn) {
      Navigator.pushReplacementNamed(context, RouteConstants.login);
    } else {
      Navigator.pushReplacementNamed(context, RouteConstants.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AssetConstants.logo, width: 80, height: 80),
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: AppColors.blue),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('The requested page could not be found.')),
    );
  }
}

class XApp extends StatelessWidget {
  const XApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'X Clone',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(context, false),
            darkTheme: AppTheme.getTheme(context, true),
            themeMode: themeProvider.themeMode,
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: RouteConstants.splash,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case RouteConstants.splash:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
                case RouteConstants.onboarding:
                  return MaterialPageRoute(
                    builder: (_) => const OnboardingScreen(),
                  );
                case RouteConstants.login:
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case RouteConstants.signup:
                  return MaterialPageRoute(builder: (_) => const SignupScreen());
                case RouteConstants.home:
                  return MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  );
                case RouteConstants.search:
                  return MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  );
                case RouteConstants.notifications:
                  return MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  );
                case RouteConstants.messages:
                  return MaterialPageRoute(
                    builder: (_) => const MessagesScreen(),
                  );
                case RouteConstants.profile:
                  return MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: settings.arguments as String?),
                  );
                case RouteConstants.forgotPassword:
                  return MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  );
                default:
                  return MaterialPageRoute(builder: (_) => const NotFoundScreen());
              }
            },
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
