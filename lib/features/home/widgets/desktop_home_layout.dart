// lib/features/home/widgets/desktop_home_layout.dart
import 'package:flutter/material.dart';
import 'package:project_x/features/home/widgets/side_navigation_bar.dart';
import 'package:project_x/features/home/widgets/tweet_card.dart';
import 'package:project_x/features/home/widgets/tweet_composer.dart';
import 'package:project_x/features/home/widgets/trends_section.dart';
import 'package:project_x/features/search/search_screen.dart';
import 'package:project_x/features/notifications/notifications_screen.dart';
import 'package:project_x/features/messages/messages_screen.dart';
import 'package:project_x/features/profile/widgets/profile_content.dart';

class DesktopHomeLayout extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const DesktopHomeLayout({
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
          // Left navigation sidebar
          SizedBox(
            width: 280,
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
                  right: BorderSide(color: Colors.grey[800]!, width: 0.5),
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
                  // const TweetComposer(onTweet: null),
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

          // Right sidebar with trends
          SizedBox(
            width: 350,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TrendsSection(),
                ],
              ),
            ),
          ),
        ],
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
            imageUrl:
                'https://media.istockphoto.com/id/1280385511/photo/colorful-background.jpg?s=612x612&w=0&k=20&c=kj0PRQlgvWLzA1-1me6iZp5mlwsZhC4QlcvIEb1J1bs=',
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
            content:
                "New Flutter update brings exciting features for developers",
            time: "6h",
            likes: 128,
            retweets: 45,
            replies: 23,
          ),
          TweetCard(
            username: "Tech Jobs",
            handle: "technews",
            content:
                "New Flutter update brings exciting features for developers",
            time: "6h",
            likes: 128,
            retweets: 45,
            replies: 23,
            imageUrl:
                'https://images.pexels.com/photos/214574/pexels-photo-214574.jpeg?cs=srgb&dl=pexels-sebastian-214574.jpg&fm=jpg',
          ),
        ],
      ),
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
      case 4:
        return 'Profile';
      default:
        return 'Home';
    }
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
}
