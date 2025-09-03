import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/utils/responsive_utils.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/features/notifications/widgets/notification_item.dart';
import 'package:project_x/core/models/notification_model.dart';
import 'package:project_x/core/models/user_model.dart';
import 'package:project_x/core/models/tweet_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          body: Column(
            children: [
              _buildTabBar(isDark),
              Expanded(
                child: ResponsiveUtils.isLargeScreen(context)
                    ? _buildLargeScreenLayout(isDark)
                    : _buildMobileLayout(isDark),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor(isDark), width: 0.5),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.blue,
        indicatorWeight: 2,
        labelColor: AppColors.blue,
        unselectedLabelColor: AppColors.textSecondary(isDark),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Mentions'),
        ],
      ),
    );
  }

  Widget _buildLargeScreenLayout(bool isDark) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildMainContent(isDark)),
        if (ResponsiveUtils.isDesktop(context))
          Expanded(flex: 1, child: _buildRightSidebar(isDark)),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return _buildMainContent(isDark);
  }

  Widget _buildMainContent(bool isDark) {
    return TabBarView(
      controller: _tabController,
      children: [_buildAllNotifications(isDark), _buildMentionsNotifications(isDark)],
    );
  }

  Widget _buildAllNotifications(bool isDark) {
    final notifications = _getMockNotifications();

    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        color: AppColors.blue,
        backgroundColor: AppColors.cardColor(isDark),
        child: _buildEmptyState(
          icon: Icons.notifications_none,
          title: 'No notifications yet',
          subtitle:
              'When someone likes, retweets, or follows you, you\'ll see it here.',
          isDark: isDark,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.blue,
      backgroundColor: AppColors.cardColor(isDark),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotificationItem(
            notification: notifications[index],
            onTap: () => _handleNotificationTap(notifications[index]),
          );
        },
      ),
    );
  }

  Widget _buildMentionsNotifications(bool isDark) {
    final mentionNotifications = _getMockNotifications()
        .where((n) => n.type == NotificationType.mention)
        .toList();

    if (mentionNotifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        color: AppColors.blue,
        backgroundColor: AppColors.cardColor(isDark),
        child: _buildEmptyState(
          icon: Icons.alternate_email,
          title: 'No mentions yet',
          subtitle:
              'When someone mentions you in a tweet, you\'ll see it here.',
          isDark: isDark,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.blue,
      backgroundColor: AppColors.cardColor(isDark),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: mentionNotifications.length,
        itemBuilder: (context, index) {
          return NotificationItem(
            notification: mentionNotifications[index],
            onTap: () => _handleNotificationTap(mentionNotifications[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 64, color: AppColors.textSecondary(isDark)),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary(isDark), 
                      fontSize: 15
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightSidebar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notification settings', style: TextStyles.titleMedium),
          const SizedBox(height: 16),
          _buildSettingItem('Push notifications', true, isDark),
          _buildSettingItem('Email notifications', false, isDark),
          _buildSettingItem('SMS notifications', false, isDark),
          const SizedBox(height: 24),
          Text('Filter notifications', style: TextStyles.titleMedium),
          const SizedBox(height: 16),
          _buildSettingItem('Quality filter', true, isDark),
          _buildSettingItem('Advanced filters', false, isDark),
          _buildSettingItem('Muted notifications', false, isDark),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, bool isEnabled, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyles.bodyMedium),
          Switch(
            value: isEnabled,
            onChanged: (value) {},
            activeThumbColor: AppColors.blue,
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle notification tap - navigate to relevant screen
    print('Tapped notification: ${notification.message}');
  }

  List<NotificationModel> _getMockNotifications() {
    final now = DateTime.now();
    final mockUser = UserModel(
      id: '1',
      username: 'johndoe',
      displayName: 'John Doe',
      email: 'john@example.com',
      joinedDate: DateTime.now().subtract(const Duration(days: 365)),
      followers: 150,
      following: 200,
    );

    final mockTweet = TweetModel(
      id: '1',
      content: 'Just built an amazing Flutter app!',
      author: mockUser,
      createdAt: now.subtract(const Duration(hours: 2)),
      likes: 25,
      retweets: 5,
      replies: 3,
    );

    return [
      NotificationModel(
        id: '1',
        type: NotificationType.like,
        fromUser: mockUser,
        toUser: mockUser,
        tweet: mockTweet,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      NotificationModel(
        id: '2',
        type: NotificationType.follow,
        fromUser: mockUser.copyWith(
          id: '2',
          username: 'janesmith',
          displayName: 'Jane Smith',
        ),
        toUser: mockUser,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '3',
        type: NotificationType.retweet,
        fromUser: mockUser.copyWith(
          id: '3',
          username: 'techuser',
          displayName: 'Tech User',
        ),
        toUser: mockUser,
        tweet: mockTweet,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: '4',
        type: NotificationType.mention,
        fromUser: mockUser.copyWith(
          id: '4',
          username: 'mention_user',
          displayName: 'Mention User',
        ),
        toUser: mockUser,
        tweet: mockTweet.copyWith(
          content: '@johndoe check out this amazing feature!',
        ),
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: '5',
        type: NotificationType.reply,
        fromUser: mockUser.copyWith(
          id: '5',
          username: 'reply_user',
          displayName: 'Reply User',
        ),
        toUser: mockUser,
        tweet: mockTweet,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
    ];
  }
}