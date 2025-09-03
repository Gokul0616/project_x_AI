// lib/features/home/widgets/tablet_home_layout.dart
import 'package:flutter/material.dart';
import 'package:project_x/features/home/widgets/side_navigation_bar.dart';
import 'package:project_x/features/home/widgets/tweet_card.dart';
import 'package:project_x/features/home/widgets/tweet_composer.dart';
import 'package:project_x/features/search/search_screen.dart';
import 'package:project_x/features/notifications/notifications_screen.dart';
import 'package:project_x/features/messages/messages_screen.dart';
import 'package:project_x/features/profile/widgets/profile_content.dart';

class TabletHomeLayout extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const TabletHomeLayout({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left navigation sidebar (similar to desktop but narrower)
          SizedBox(
            width: 200, // Reduced width for tablet
            child: SideNavigationBar(
              currentIndex: currentIndex,
              onItemSelected: onItemSelected,
            ),
          ),
          // Main content area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[800]!, width: 0.5),
                ),
              ),
              child: Column(
                children: [
                  AppBar(
                    title: Text(
                      _getAppBarTitle(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    centerTitle: false,
                    automaticallyImplyLeading: false,
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  TweetComposer(
                    onTweet: (text) {
                      print("Tweeted: $text");
                    },
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  Expanded(child: _buildCurrentScreen()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => TweetComposer(
              onTweet: (text) {
                print("Tweeted: $text");
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (currentIndex) {
      case 0:
        return _buildHomeFeed();
      case 1:
        return _buildSearchScreen();
      case 2:
        return _buildNotificationsScreen();
      case 3:
        return _buildMessagesScreen();
      case 4:
        return _buildProfileScreen();
      default:
        return _buildHomeFeed();
    }
  }

  Widget _buildHomeFeed() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
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

  Widget _buildSearchScreen() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: const SearchScreen(),
    );
  }

  Widget _buildNotificationsScreen() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: const NotificationsScreen(),
    );
  }

  Widget _buildMessagesScreen() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: const MessagesScreen(),
    );
  }

  Widget _buildProfileScreen() {
    return const ProfileContent();
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
      case 4:
        return 'Profile';
      default:
        return 'Home';
    }
  }
}
