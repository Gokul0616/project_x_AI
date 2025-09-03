import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/core/models/message_model.dart';

class ConversationItem extends StatelessWidget {
  final ConversationModel conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final otherUser = conversation.participants.first;
        final hasUnread = conversation.unreadCount > 0;

        return InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.blue.withOpacity(0.1)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(color: AppColors.borderColor(isDark), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.midGray,
                      child: Text(
                        otherUser.displayName[0].toUpperCase(),
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            otherUser.displayName,
                            style: TextStyles.bodyMedium.copyWith(
                              fontWeight: hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (conversation.lastMessage != null)
                            Text(
                              conversation.lastMessage!.createdAt.timeAgo,
                              style: TextStyles.caption.copyWith(
                                color: hasUnread
                                    ? AppColors.blue
                                    : AppColors.textSecondary(isDark),
                                fontWeight: hasUnread
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '@${otherUser.username}',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                          if (conversation.lastMessage != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '·',
                              style: TextStyle(color: AppColors.textSecondary(isDark)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                conversation.lastMessage!.content,
                                style: TextStyles.bodySmall.copyWith(
                                  color: hasUnread
                                      ? AppColors.textPrimary(isDark)
                                      : AppColors.textSecondary(isDark),
                                  fontWeight: hasUnread
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      conversation.unreadCount.toString(),
                      style: TextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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