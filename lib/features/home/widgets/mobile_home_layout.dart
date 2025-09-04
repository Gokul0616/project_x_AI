// lib/features/home/widgets/mobile_home_layout.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/features/home/widgets/enhanced_tweet_card.dart';
import 'package:project_x/features/home/widgets/enhanced_tweet_composer.dart';
import 'package:project_x/features/home/viewmodels/tweet_viewmodel.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/features/search/search_screen.dart';
import 'package:project_x/features/notifications/notifications_screen.dart';
import 'package:project_x/features/messages/messages_screen.dart';
import 'package:project_x/features/home/widgets/app_drawer.dart';

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
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.autorenew), onPressed: () {}),
        ],
      ),
      body: _buildCurrentScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => EnhancedTweetComposer(
              onTweet: (content) {
                Provider.of<TweetViewModel>(context, listen: false)
                    .addTweet(content);
              },
            ),
          );
        },
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (currentIndex) {
      case 0:
        return _buildHomeFeed();
      case 1:
        return _buildExploreScreen();
      case 2:
        return _buildNotificationsScreen();
      case 3:
        return _buildMessagesScreen();
      default:
        return _buildHomeFeed();
    }
  }

  Widget _buildHomeFeed() {
    return Consumer<TweetViewModel>(
      builder: (context, tweetViewModel, child) {
        if (tweetViewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.blue),
          );
        }

        if (tweetViewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  tweetViewModel.error!,
                  style: TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: tweetViewModel.refreshTweets,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: tweetViewModel.refreshTweets,
          color: AppColors.blue,
          backgroundColor: AppColors.surfaceColor,
          child: ListView.separated(
            itemCount: tweetViewModel.tweets.length,
            separatorBuilder: (context, index) => Container(
              height: 0.5,
              color: AppColors.borderColor,
            ),
            itemBuilder: (context, index) {
              final tweet = tweetViewModel.tweets[index];
              return EnhancedTweetCard(
                tweet: tweet,
                onLike: () => tweetViewModel.likeTweet(tweet.id),
                onRetweet: () => tweetViewModel.retweetTweet(tweet.id),
                onReply: () => tweetViewModel.addReply(tweet.id, "Sample reply"),
                onShare: () {
                  // Handle share functionality
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildExploreScreen() {
    return const SearchScreen();
  }

  Widget _buildNotificationsScreen() {
    return const NotificationsScreen();
  }

  Widget _buildMessagesScreen() {
    return const MessagesScreen();
  }
}
