// lib/features/home/widgets/mobile_home_layout.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/features/home/widgets/enhanced_tweet_card.dart';
import 'package:project_x/features/home/widgets/enhanced_tweet_composer.dart';
import 'package:project_x/features/home/viewmodels/tweet_viewmodel.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/theme_provider.dart';
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: Text(
              _getAppBarTitle(),
              style: TextStyle(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.backgroundColor(isDark),
            elevation: 0,
            centerTitle: false,
            iconTheme: IconThemeData(color: AppColors.textPrimary(isDark)),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.autorenew,
                  color: AppColors.textSecondary(isDark),
                ),
                onPressed: () {
                  if (currentIndex == 0) {
                    // Refresh home feed
                    context.read<TweetViewModel>().refreshTweets();
                  }
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: currentIndex,
            children: [
              _buildHomeFeed(isDark),
              _buildExploreScreen(),
              _buildNotificationsScreen(),
              _buildMessagesScreen(),
            ],
          ),
          floatingActionButton: currentIndex == 0
              ? FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => EnhancedTweetComposer(
                        onTweet:
                            (content, {List<String>? mediaUrls, quoteTweet}) {
                              final tweetViewModel = context
                                  .read<TweetViewModel>();

                              if (quoteTweet != null) {
                                tweetViewModel.addQuoteTweet(
                                  content,
                                  quoteTweet,
                                  mediaUrls: mediaUrls ?? [],
                                );
                              } else {
                                tweetViewModel.addTweet(
                                  content,
                                  mediaUrls: mediaUrls ?? [],
                                );
                              }
                            },
                      ),
                    );
                  },
                  backgroundColor: AppColors.blue,
                  child: const Icon(Icons.add, color: AppColors.white),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: AppColors.backgroundColor(isDark),
            currentIndex: currentIndex,
            onTap: onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.blue,
            unselectedItemColor: AppColors.textSecondary(isDark),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mail_outlined),
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
        return 'Explore';
      case 2:
        return 'Notifications';
      case 3:
        return 'Messages';
      default:
        return 'Home';
    }
  }

  Widget _buildHomeFeed(bool isDark) {
    return Consumer<TweetViewModel>(
      builder: (context, tweetViewModel, child) {
        if (tweetViewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.blue),
          );
        }

        if (tweetViewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    tweetViewModel.error!,
                    style: TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
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
          backgroundColor: AppColors.surfaceColor(isDark),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tweetViewModel.tweets.length,
            separatorBuilder: (context, index) =>
                Container(height: 0.5, color: AppColors.borderColor(isDark)),
            itemBuilder: (context, index) {
              final tweet = tweetViewModel.tweets[index];
              return EnhancedTweetCard(
                tweet: tweet,
                onLike: () => tweetViewModel.likeTweet(tweet.id),
                onRetweet: () => tweetViewModel.retweetTweet(tweet.id),
                onReply: () =>
                    tweetViewModel.addReply(tweet.id, "Sample reply"),
                onShare: () {
                  _showShareBottomSheet(context, tweet, isDark);
                },
                onQuoteTweet: (content, {List<String>? mediaUrls, quoteTweet}) {
                  if (quoteTweet != null) {
                    tweetViewModel.addQuoteTweet(
                      content,
                      quoteTweet,
                      mediaUrls: mediaUrls ?? [],
                    );
                  }
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

  void _showShareBottomSheet(BuildContext context, tweet, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.link, color: AppColors.blue, size: 20),
              ),
              title: Text(
                'Copy link to Tweet',
                style: TextStyle(color: AppColors.textPrimary(isDark)),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Link copied to clipboard'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.share, color: AppColors.info, size: 20),
              ),
              title: Text(
                'Share Tweet via...',
                style: TextStyle(color: AppColors.textPrimary(isDark)),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Share functionality coming soon!'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_add,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              title: Text(
                'Bookmark Tweet',
                style: TextStyle(color: AppColors.textPrimary(isDark)),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<TweetViewModel>().bookmarkTweet(tweet.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tweet bookmarked'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
