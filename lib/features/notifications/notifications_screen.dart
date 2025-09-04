import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyles.titleMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationItem(
            Icons.favorite,
            AppColors.error,
            'Jane Smith liked your tweet',
            '"Just shipped a new Flutter feature! The hot reload..."',
            '2h',
          ),
          _buildNotificationItem(
            Icons.repeat,
            AppColors.success,
            'Tech News retweeted your tweet',
            '"Mars needs memes 🚀 Working on Starship orbital..."',
            '4h',
          ),
          _buildNotificationItem(
            Icons.person_add,
            AppColors.blue,
            'Sarah Wilson started following you',
            '',
            '6h',
          ),
          _buildNotificationItem(
            Icons.chat_bubble,
            AppColors.blue,
            'Elon Musk replied to your tweet',
            '"Probably 2029 if all goes well! 🚀"',
            '8h',
          ),
          _buildNotificationItem(
            Icons.favorite,
            AppColors.error,
            '25 people liked your tweet',
            '"Beautiful sunset from my office today 🌅"',
            '1d',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    IconData icon,
    Color iconColor,
    String title,
    String content,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
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
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyles.caption.copyWith(color: AppColors.midGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}