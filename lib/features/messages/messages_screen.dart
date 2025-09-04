import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyles.titleMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.white),
            onPressed: () {
              // Handle settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.white),
            onPressed: () {
              // Handle new message
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMessageItem(
            'Jane Smith',
            '@janesmith',
            'Hey! Saw your latest Flutter project. Really impressive work! 👏',
            '2h',
            'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=150&h=150&fit=crop&crop=face',
            true,
          ),
          _buildMessageItem(
            'Tech News',
            '@technews',
            'Thanks for sharing our article!',
            '4h',
            'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=150&h=150&fit=crop&crop=center',
            false,
          ),
          _buildMessageItem(
            'Sarah Wilson',
            '@sarahwilson',
            'Would love to collaborate on a design project!',
            '1d',
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
            false,
          ),
          _buildMessageItem(
            'Elon Musk',
            '@elonmusk',
            'Mars update: Looking good for 2029! 🚀',
            '2d',
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
            true,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle new message
        },
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildMessageItem(
    String name,
    String handle,
    String lastMessage,
    String time,
    String avatarUrl,
    bool hasUnreadMessage,
  ) {
    return InkWell(
      onTap: () {
        // Navigate to conversation
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasUnreadMessage 
              ? AppColors.blue.withOpacity(0.05)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasUnreadMessage 
                ? AppColors.blue.withOpacity(0.3)
                : AppColors.borderColor, 
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                if (hasUnreadMessage)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.backgroundColor,
                          width: 2,
                        ),
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
                    children: [
                      Text(
                        name,
                        style: TextStyles.titleSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: hasUnreadMessage 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        handle,
                        style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: TextStyles.caption.copyWith(color: AppColors.midGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyles.bodySmall.copyWith(
                      color: hasUnreadMessage 
                          ? AppColors.white 
                          : AppColors.midGray,
                      fontWeight: hasUnreadMessage 
                          ? FontWeight.w500 
                          : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}