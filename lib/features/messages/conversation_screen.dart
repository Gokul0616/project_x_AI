import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/theme_provider.dart';

class ConversationScreen extends StatefulWidget {
  final String userName;
  final String userHandle;
  final String avatarUrl;
  final String conversationId;

  const ConversationScreen({
    super.key,
    required this.userName,
    required this.userHandle,
    required this.avatarUrl,
    required this.conversationId,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'content': 'Hey! How are you doing?',
      'sender': 'other',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'read',
    },
    {
      'id': '2', 
      'content': 'I\'m good! Just working on some Flutter projects. How about you?',
      'sender': 'me',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      'status': 'read',
    },
    {
      'id': '3',
      'content': 'That sounds awesome! I\'d love to see what you\'re building. Any interesting features?',
      'sender': 'other',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      'status': 'read',
    },
    {
      'id': '4',
      'content': 'Yeah! I\'m working on a social media app with real-time messaging, theme switching, and smooth animations. Pretty excited about it! 🚀',
      'sender': 'me',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'status': 'delivered',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    // Simulate loading more messages
    Future.delayed(const Duration(seconds: 1), () {
      _refreshController.refreshCompleted();
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': _messageController.text.trim(),
        'sender': 'me',
        'timestamp': DateTime.now(),
        'status': 'sending',
      });
    });

    _messageController.clear();
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate message sent
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.last['status'] = 'delivered';
        });
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
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor(isDark),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary(isDark),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: TextStyles.titleSmall.copyWith(
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      Text(
                        widget.userHandle,
                        style: TextStyles.caption.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.phone,
                  color: AppColors.textSecondary(isDark),
                ),
                onPressed: () {
                  // Handle call
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.videocam,
                  color: AppColors.textSecondary(isDark),
                ),
                onPressed: () {
                  // Handle video call
                },
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary(isDark),
                ),
                color: AppColors.surfaceColor(isDark),
                onSelected: (value) {
                  // Handle menu selection
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mute',
                    child: Text(
                      'Mute conversation',
                      style: TextStyle(color: AppColors.textPrimary(isDark)),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete conversation',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  header: WaterDropHeader(
                    waterDropColor: AppColors.blue,
                    complete: Icon(
                      Icons.check,
                      color: AppColors.blue,
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message, isDark);
                    },
                  ),
                ),
              ),
              _buildMessageInput(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isDark) {
    final isMe = message['sender'] == 'me';
    final timestamp = message['timestamp'] as DateTime;
    final status = message['status'] as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(widget.avatarUrl),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? AppColors.blue 
                        : AppColors.surfaceColor(isDark),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    border: !isMe ? Border.all(
                      color: AppColors.borderColor(isDark),
                      width: 0.5,
                    ) : null,
                  ),
                  child: Text(
                    message['content'],
                    style: TextStyles.bodyMedium.copyWith(
                      color: isMe 
                          ? AppColors.white 
                          : AppColors.textPrimary(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(timestamp),
                      style: TextStyles.caption.copyWith(
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        _getStatusIcon(status),
                        size: 12,
                        color: _getStatusColor(status),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(isDark),
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor(isDark),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.add,
                color: AppColors.blue,
              ),
              onPressed: () {
                // Handle attachments
              },
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor(isDark),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppColors.borderColor(isDark),
                    width: 0.5,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Start a new message',
                    hintStyle: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  size: 20,
                  color: AppColors.white,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'sending':
        return Icons.access_time;
      case 'delivered':
        return Icons.check;
      case 'read':
        return Icons.done_all;
      default:
        return Icons.access_time;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'sending':
        return AppColors.midGray;
      case 'delivered':
        return AppColors.midGray;
      case 'read':
        return AppColors.blue;
      default:
        return AppColors.midGray;
    }
  }
}