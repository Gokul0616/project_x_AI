import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    // Simulate refreshing notifications
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          body: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            header: WaterDropHeader(
              waterDropColor: AppColors.blue,
              complete: Icon(
                Icons.check,
                color: AppColors.blue,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNotificationItem(
                  Icons.favorite,
                  AppColors.error,
                  'Jane Smith liked your tweet',
                  '"Just shipped a new Flutter feature! The hot reload..."',
                  '2h',
                  isDark,
                ),
                _buildNotificationItem(
                  Icons.repeat,
                  AppColors.success,
                  'Tech News retweeted your tweet',
                  '"Mars needs memes 🚀 Working on Starship orbital..."',
                  '4h',
                  isDark,
                ),
                _buildNotificationItem(
                  Icons.person_add,
                  AppColors.blue,
                  'Sarah Wilson started following you',
                  '',
                  '6h',
                  isDark,
                ),
                _buildNotificationItem(
                  Icons.chat_bubble,
                  AppColors.blue,
                  'Elon Musk replied to your tweet',
                  '"Probably 2029 if all goes well! 🚀"',
                  '8h',
                  isDark,
                ),
                _buildNotificationItem(
                  Icons.favorite,
                  AppColors.error,
                  '25 people liked your tweet',
                  '"Beautiful sunset from my office today 🌅"',
                  '1d',
                  isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
    IconData icon,
    Color iconColor,
    String title,
    String content,
    String time,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor(isDark), 
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}