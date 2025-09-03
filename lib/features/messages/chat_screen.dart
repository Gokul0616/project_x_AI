// lib/features/messages/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/models/user_model.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/core/models/message_model.dart';
import 'package:project_x/features/messages/widgets/message_composer.dart';
import 'package:project_x/features/messages/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<MessageModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    // Mock messages - replace with actual data loading
    _messages = widget.conversation.messages;
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final currentUser = UserModel(
      id: 'current_user_id',
      username: 'currentuser',
      displayName: 'Current User',
      email: 'current@example.com',
      joinedDate: DateTime.now(),
    );

    final otherUser = widget.conversation.participants.first;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user_id',
      sender: currentUser,
      receiver: otherUser,
      content: text.trim(),
      createdAt: DateTime.now(),
      conversationId: widget.conversation.id,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final otherUser = widget.conversation.participants.first;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor(isDark),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(isDark)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: otherUser.profileImageUrl != null
                      ? NetworkImage(otherUser.profileImageUrl!)
                      : null,
                  backgroundColor: Colors.grey,
                  child: otherUser.profileImageUrl == null
                      ? Icon(Icons.person, color: AppColors.textPrimary(isDark))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherUser.displayName,
                        style: TextStyle(
                          color: AppColors.textPrimary(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '@${otherUser.username}',
                        style: TextStyle(
                          color: AppColors.textSecondary(isDark), 
                          fontSize: 13
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.call, color: AppColors.textPrimary(isDark)),
                onPressed: () {
                  // Handle call
                },
              ),
              IconButton(
                icon: Icon(Icons.info_outline, color: AppColors.textPrimary(isDark)),
                onPressed: () {
                  // Handle info
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    _loadMessages();
                  },
                  color: AppColors.blue,
                  backgroundColor: AppColors.cardColor(isDark),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isCurrentUser = message.senderId == 'current_user_id';

                      return MessageBubble(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        showAvatar: !isCurrentUser,
                        user: isCurrentUser ? null : otherUser,
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderColor(isDark), width: 0.5),
                  ),
                ),
                child: MessageComposer(
                  controller: _messageController,
                  onSendMessage: _sendMessage,
                  hintText: 'Start a new message',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}