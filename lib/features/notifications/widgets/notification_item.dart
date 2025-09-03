import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/core/models/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.transparent
                  : AppColors.blue.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: AppColors.borderColor(isDark), width: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.midGray,
                  child: Text(
                    notification.fromUser.displayName[0].toUpperCase(),
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNotificationContent(isDark),
                      const SizedBox(height: 4),
                      Text(
                        notification.createdAt.timeAgo,
                        style: TextStyles.caption.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                      if (notification.tweet != null) ...[
                        const SizedBox(height: 12),
                        _buildTweetPreview(isDark),
                      ],
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.like:
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case NotificationType.retweet:
        icon = Icons.repeat;
        color = Colors.green;
        break;
      case NotificationType.follow:
        icon = Icons.person_add;
        color = AppColors.blue;
        break;
      case NotificationType.mention:
        icon = Icons.alternate_email;
        color = AppColors.blue;
        break;
      case NotificationType.reply:
        icon = Icons.reply;
        color = AppColors.blue;
        break;
      case NotificationType.quote:
        icon = Icons.format_quote;
        color = AppColors.blue;
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 16,
      ),
    );
  }

  Widget _buildNotificationContent(bool isDark) {
    return RichText(
      text: TextSpan(
        style: TextStyles.bodyMedium.copyWith(color: AppColors.textPrimary(isDark)),
        children: [
          TextSpan(
            text: notification.fromUser.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ' ${_getActionText()}',
            style: TextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getActionText() {
    switch (notification.type) {
      case NotificationType.like:
        return 'liked your tweet';
      case NotificationType.retweet:
        return 'retweeted your tweet';
      case NotificationType.follow:
        return 'started following you';
      case NotificationType.mention:
        return 'mentioned you in a tweet';
      case NotificationType.reply:
        return 'replied to your tweet';
      case NotificationType.quote:
        return 'quoted your tweet';
    }
  }

  Widget _buildTweetPreview(bool isDark) {
    if (notification.tweet == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor(isDark), width: 0.5),
      ),
      child: Text(
        notification.tweet!.content,
        style: TextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary(isDark),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

extension on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}