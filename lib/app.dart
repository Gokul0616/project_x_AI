// import 'package:flutter/material.dart';
// import 'package:project_x/core/constants/asset_constants.dart';
// import 'package:project_x/core/theme/color_palette.dart';
// import 'package:project_x/features/home/home_screen.dart';
// import 'package:project_x/shared/services/navigation_service.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:project_x/core/constants/app_constants.dart';
// import 'package:project_x/core/constants/route_constants.dart';
// import 'package:project_x/core/theme/app_theme.dart';
// import 'package:project_x/features/authentication/auth_viewmodel.dart';
// import 'package:project_x/features/onboarding/onboarding_viewmodel.dart';
// import 'package:project_x/features/authentication/forgot_password_screen.dart';
// import 'package:project_x/features/authentication/login_screen.dart';
// import 'package:project_x/features/authentication/signup_screen.dart';
// import 'package:project_x/features/onboarding/onboarding_screen.dart';

// // Updated SplashScreen with navigation logic
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _navigateToNextScreen();
//   }

//   Future<void> _navigateToNextScreen() async {
//     await Future.delayed(const Duration(seconds: 2)); // Simulate loading time

//     final prefs = await SharedPreferences.getInstance();
//     final hasSeenOnboarding =
//         prefs.getBool(AppConstants.hasSeenOnboardingKey) ?? false;
//     final isLoggedIn = prefs.getString(AppConstants.authTokenKey) != null;

//     // ignore: use_build_context_synchronously
//     if (!hasSeenOnboarding) {
//       Navigator.pushReplacementNamed(context, RouteConstants.onboarding);
//     } else if (!isLoggedIn) {
//       Navigator.pushReplacementNamed(context, RouteConstants.login);
//     } else {
//       Navigator.pushReplacementNamed(context, RouteConstants.home);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor1,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // App logo
//             Image.asset(AssetConstants.logo, width: 80, height: 80),
//             const SizedBox(height: 20),
//             // Loading indicator
//             const CircularProgressIndicator(color: AppColors.blue),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Placeholder HomeScreen
// // class HomeScreen extends StatelessWidget {
// //   const HomeScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Home'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.logout),
// //             onPressed: () async {
// //               final prefs = await SharedPreferences.getInstance();
// //               await prefs.remove(AppConstants.authTokenKey);
// //               Navigator.pushReplacementNamed(context, RouteConstants.login);
// //             },
// //           ),
// //         ],
// //       ),
// //       body: const Center(child: Text('Welcome to X Clone!')),
// //     );
// //   }
// // }

// class NotFoundScreen extends StatelessWidget {
//   const NotFoundScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Page Not Found')),
//       body: const Center(child: Text('The requested page could not be found.')),
//     );
//   }
// }

// class XApp extends StatelessWidget {
//   const XApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthViewModel()),
//         ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
//       ],
//       child: MaterialApp(
//         title: 'X Clone',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.darkTheme,
//         navigatorKey: NavigationService.navigatorKey,
//         initialRoute: RouteConstants.splash,
//         onGenerateRoute: (settings) {
//           switch (settings.name) {
//             case RouteConstants.splash:
//               return MaterialPageRoute(builder: (_) => const SplashScreen());
//             case RouteConstants.onboarding:
//               return MaterialPageRoute(
//                 builder: (_) => const OnboardingScreen(),
//               );
//             case RouteConstants.login:
//               return MaterialPageRoute(builder: (_) => const LoginScreen());
//             case RouteConstants.signup:
//               return MaterialPageRoute(builder: (_) => const SignupScreen());
//             case RouteConstants.home:
//               return MaterialPageRoute(builder: (_) => const HomeScreen());
//             case RouteConstants.forgotPassword:
//               return MaterialPageRoute(
//                 builder: (_) => const ForgotPasswordScreen(),
//               );
//             default:
//               return MaterialPageRoute(builder: (_) => const NotFoundScreen());
//           }
//         },
//         builder: (context, child) {
//           return MediaQuery(
//             data: MediaQuery.of(context).copyWith(
//               textScaler: TextScaler.linear(
//                 MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
//               ),
//             ),
//             child: child!,
//           );
//         },
//       ),
//     );
//   }
// }

// lib/app.dart
import 'package:flutter/material.dart';
import 'package:project_x/core/constants/asset_constants.dart';
import 'package:project_x/core/constants/route_constants.dart';
import 'package:project_x/core/theme/app_theme.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/theme_provider.dart';
import 'package:project_x/features/authentication/auth_viewmodel.dart';
import 'package:project_x/features/authentication/forgot_password_screen.dart';
import 'package:project_x/features/authentication/login_screen.dart';
import 'package:project_x/features/authentication/signup_screen.dart';
import 'package:project_x/features/home/home_screen.dart';
import 'package:project_x/features/home/home_viewmodel.dart';
import 'package:project_x/features/home/viewmodels/tweet_viewmodel.dart';
import 'package:project_x/features/search/search_screen.dart';
import 'package:project_x/core/services/auth_service.dart';
import 'package:project_x/core/services/socket_service.dart';
import 'package:project_x/features/communities/viewmodels/communities_viewmodel.dart';
import 'package:project_x/features/onboarding/onboarding_screen.dart';
import 'package:project_x/features/onboarding/onboarding_viewmodel.dart';
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
    // Wait for theme provider to initialize
    await context.read<ThemeProvider>().initialize();
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          appBar: AppBar(
            title: Text(
              'Page Not Found',
              style: TextStyle(color: AppColors.textPrimary(isDark)),
            ),
            backgroundColor: AppColors.backgroundColor(isDark),
            iconTheme: IconThemeData(color: AppColors.textPrimary(isDark)),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.textSecondary(isDark),
                ),
                const SizedBox(height: 16),
                Text(
                  'Page Not Found',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The requested page could not be found.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    RouteConstants.home,
                  ),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class XApp extends StatefulWidget {
  const XApp({super.key});

  @override
  State<XApp> createState() => _XAppState();
}

class _XAppState extends State<XApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize auth service and socket service
      final authService = context.read<AuthService>();
      final socketService = context.read<SocketService>();

      authService.initialize().then((_) {
        if (authService.isAuthenticated) {
          socketService.connect();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => TweetViewModel()),
        ChangeNotifierProvider(create: (_) => CommunitiesViewModel()),
        ChangeNotifierProxyProvider<AuthService, SocketService>(
          create: (context) => SocketService(context.read<AuthService>()),
          update: (context, authService, socketService) =>
              socketService ?? SocketService(authService),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'X Clone',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: RouteConstants.splash,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case RouteConstants.splash:
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                  );
                case RouteConstants.onboarding:
                  return MaterialPageRoute(
                    builder: (_) => const OnboardingScreen(),
                  );
                case RouteConstants.login:
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case RouteConstants.signup:
                  return MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                  );
                case RouteConstants.home:
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                case RouteConstants.search:
                  return MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  );
                case RouteConstants.forgotPassword:
                  return MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const NotFoundScreen(),
                  );
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
