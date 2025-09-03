// lib/features/home/widgets/mobile_home_layout.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/features/home/widgets/tweet_card.dart';
import 'package:project_x/features/home/widgets/tweet_composer.dart';
import 'package:project_x/features/home/widgets/app_drawer.dart';
import 'package:project_x/features/search/search_screen.dart';
import 'package:project_x/features/notifications/notifications_screen.dart';
import 'package:project_x/features/messages/messages_screen.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/providers/theme_provider.dart';

class MobileHomeLayout extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const MobileHomeLayout({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          drawer: const AppDrawer(),
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor(isDark),
            elevation: 0,
            leading: Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://via.placeholder.com/32'),
                  ),
                ),
              ),
            ),
            title: Text(
              _getAppBarTitle(),
              style: TextStyle(
                color: AppColors.textPrimary(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
          ),
          body: _buildCurrentScreen(isDark),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => TweetComposer(
                  onTweet: (text) {
                    print("Tweeted: $text");
                  },
                ),
              );
            },
            backgroundColor: AppColors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.backgroundColor(isDark),
            selectedItemColor: AppColors.textPrimary(isDark),
            unselectedItemColor: AppColors.textSecondary(isDark),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            iconSize: 24,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mail_outline),
                activeIcon: Icon(Icons.mail),
                label: 'Messages',
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'Notifications';
      case 3:
        return 'Messages';
      default:
        return 'Home';
    }
  }

  Widget _buildCurrentScreen(bool isDark) {
    switch (currentIndex) {
      case 0:
        return _buildHomeFeed(isDark);
      case 1:
        return _buildSearchScreen(isDark);
      case 2:
        return _buildNotificationsScreen(isDark);
      case 3:
        return _buildMessagesScreen(isDark);
      default:
        return _buildHomeFeed(isDark);
    }
  }

  Widget _buildHomeFeed(bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.blue,
      backgroundColor: AppColors.cardColor(isDark),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          TweetCard(
            username: "John Doe",
            handle: "johndoe",
            content:
                "Just built a Flutter app with a responsive layout! #FlutterDev",
            time: "2h",
            likes: 24,
            retweets: 5,
            replies: 3,
            imageUrl: "https://via.placeholder.com/500x300",
          ),
          TweetCard(
            username: "Jane Smith",
            handle: "janesmith",
            content: "Beautiful day for coding outside! ☀️",
            time: "4h",
            likes: 42,
            retweets: 12,
            replies: 7,
          ),
          TweetCard(
            username: "Tech News",
            handle: "technews",
            content: "New Flutter update brings exciting features for developers",
            time: "6h",
            likes: 128,
            retweets: 45,
            replies: 23,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchScreen(bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.blue,
      backgroundColor: AppColors.cardColor(isDark),
      child: const SearchScreen(),
    );
  }

  Widget _buildNotificationsScreen(bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.blue,
      backgroundColor: AppColors.cardColor(isDark),
      child: const NotificationsScreen(),
    );
  }

  Widget _buildMessagesScreen(bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.blue,
      backgroundColor: AppColors.cardColor(isDark),
      child: const MessagesScreen(),
    );
  }
}