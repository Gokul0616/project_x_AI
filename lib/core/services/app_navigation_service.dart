// lib/core/services/app_navigation_service.dart
import 'package:flutter/material.dart';
import 'package:project_x/core/constants/route_constants.dart';
import 'package:project_x/shared/services/navigation_service.dart';

class AppNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = NavigationService.navigatorKey;

  // Navigate to full screen (separate routes)
  static Future<void> navigateToProfile({String? userId}) {
    return NavigationService.navigateTo(RouteConstants.profile, arguments: userId);
  }

  static Future<void> navigateToTweetDetail(String tweetId) {
    return NavigationService.navigateTo('/tweet/$tweetId');
  }

  static Future<void> navigateToChat(String conversationId) {
    return NavigationService.navigateTo('/chat/$conversationId');
  }

  static Future<void> navigateToSettings() {
    return NavigationService.navigateTo('/settings');
  }

  // Show modal screens
  static Future<void> showTweetComposer(BuildContext context, {String? replyToTweetId, String? quoteTweetId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Tweet composer content here
              const Expanded(
                child: Center(
                  child: Text('Enhanced Tweet Composer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showRetweetOptions(BuildContext context, String tweetId) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Repost'),
              onTap: () {
                Navigator.pop(context);
                // Handle regular repost
                print('Regular repost: $tweetId');
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_quote),
              title: const Text('Quote'),
              onTap: () {
                Navigator.pop(context);
                // Handle quote repost
                showTweetComposer(context, quoteTweetId: tweetId);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Go back
  static void goBack() {
    NavigationService.goBack();
  }
}