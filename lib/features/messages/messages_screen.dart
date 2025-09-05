import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/theme_provider.dart';
import 'package:project_x/features/messages/conversation_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final RefreshController _refreshController = RefreshController();
  
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'Jane Smith',
      'handle': '@janesmith',
      'lastMessage': 'Hey! Saw your latest Flutter project. Really impressive work! 👏',
      'time': '2h',
      'avatarUrl': 'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=150&h=150&fit=crop&crop=face',
      'hasUnreadMessage': true,
    },
    {
      'id': '2',
      'name': 'Tech News',
      'handle': '@technews',
      'lastMessage': 'Thanks for sharing our article!',
      'time': '4h',
      'avatarUrl': 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=150&h=150&fit=crop&crop=center',
      'hasUnreadMessage': false,
    },
    {
      'id': '3',
      'name': 'Sarah Wilson',
      'handle': '@sarahwilson',
      'lastMessage': 'Would love to collaborate on a design project!',
      'time': '1d',
      'avatarUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
      'hasUnreadMessage': false,
    },
    {
      'id': '4',
      'name': 'Elon Musk',
      'handle': '@elonmusk',
      'lastMessage': 'Mars update: Looking good for 2029! 🚀',
      'time': '2d',
      'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      'hasUnreadMessage': true,
    },
  ];

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    // Simulate refreshing conversations
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _refreshController.refreshCompleted();
      }
    });
  }

  void _navigateToConversation(Map<String, dynamic> conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(
          userName: conversation['name'],
          userHandle: conversation['handle'],
          avatarUrl: conversation['avatarUrl'],
          conversationId: conversation['id'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          appBar: AppBar(
            title: Text(
              'Messages',
              style: TextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
            ),
            backgroundColor: AppColors.backgroundColor(isDark),
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: AppColors.textSecondary(isDark),
                ),
                onPressed: () {
                  // Handle settings
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColors.textSecondary(isDark),
                ),
                onPressed: () {
                  // Handle new message
                },
              ),
            ],
          ),
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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _conversations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return _buildMessageItem(
                  conversation['name'],
                  conversation['handle'],
                  conversation['lastMessage'],
                  conversation['time'],
                  conversation['avatarUrl'],
                  conversation['hasUnreadMessage'],
                  conversation,
                  isDark,
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Handle new message
            },
            backgroundColor: AppColors.blue,
            child: const Icon(Icons.add, color: AppColors.white),
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(
    String name,
    String handle,
    String lastMessage,
    String time,
    String avatarUrl,
    bool hasUnreadMessage,
    Map<String, dynamic> conversation,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => _navigateToConversation(conversation),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasUnreadMessage 
              ? AppColors.blue.withOpacity(0.05)
              : AppColors.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasUnreadMessage 
                ? AppColors.blue.withOpacity(0.3)
                : AppColors.borderColor(isDark), 
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
                          color: AppColors.backgroundColor(isDark),
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
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyles.titleSmall.copyWith(
                            color: AppColors.textPrimary(isDark),
                            fontWeight: hasUnreadMessage 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          handle,
                          style: TextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyles.caption.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyles.bodySmall.copyWith(
                      color: hasUnreadMessage 
                          ? AppColors.textPrimary(isDark)
                          : AppColors.textSecondary(isDark),
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