import 'package:flutter/material.dart';
import 'package:project_x/core/utils/responsive_utils.dart';
import 'package:project_x/features/messages/widgets/conversation_item.dart';
import 'package:project_x/features/messages/widgets/message_composer.dart';
import 'package:project_x/features/messages/chat_screen.dart';
import 'package:project_x/core/models/message_model.dart';
import 'package:project_x/core/models/user_model.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  ConversationModel? _selectedConversation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ResponsiveUtils.isLargeScreen(context)
          ? _buildLargeScreenLayout()
          : _buildMobileLayout(),
      floatingActionButton: ResponsiveUtils.isMobile(context)
          ? FloatingActionButton(
              onPressed: _startNewConversation,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : null,
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Messages',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }


  Widget _buildLargeScreenLayout() {
    return Row(
      children: [
        // Conversations list
        SizedBox(width: 350, child: _buildConversationsList()),
        // Chat area
        Expanded(
          child: _selectedConversation != null
              ? _buildChatArea()
              : _buildEmptyChatState(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    if (_selectedConversation != null) {
      return _buildChatArea();
    }
    return Column(
      children: [
        _buildAppBar(),
        Expanded(child: _buildConversationsList()),
      ],
    );
  }

  Widget _buildConversationsList() {
    return Container(
      decoration: ResponsiveUtils.isLargeScreen(context)
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.5,
                ),
              ),
            )
          : null,
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildConversations()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search for people and groups',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildConversations() {
    final conversations = _getMockConversations();
    final filteredConversations = _searchQuery.isEmpty
        ? conversations
        : conversations.where((conv) {
            final otherUser = conv.participants.first;
            return otherUser.displayName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                otherUser.username.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();

    if (filteredConversations.isEmpty) {
      return _buildEmptyConversationsState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredConversations.length,
        itemBuilder: (context, index) {
          final conversation = filteredConversations[index];
          return ConversationItem(
            conversation: conversation,
            isSelected: _selectedConversation?.id == conversation.id,
            onTap: () {
              if (ResponsiveUtils.isMobile(context)) {
                // Navigate to separate chat screen for mobile
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(conversation: conversation),
                  ),
                );
              } else {
                // For tablet/desktop, show in same layout
                setState(() {
                  _selectedConversation = conversation;
                });
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyConversationsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No conversations found',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start a new conversation by tapping the compose button.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    if (_selectedConversation == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: ResponsiveUtils.isMobile(context)
          ? _buildChatAppBar(_selectedConversation!)
          : null,
      body: Column(
        children: [
          if (ResponsiveUtils.isLargeScreen(context))
            _buildChatHeader(_selectedConversation!),
          Expanded(child: _buildMessagesList(_selectedConversation!)),
          MessageComposer(
            onSendMessage: (message) {
              _sendMessage(message);
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildChatAppBar(ConversationModel conversation) {
    final otherUser = conversation.participants.first;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _selectedConversation = null;
          });
        },
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            child: Text(
              otherUser.displayName[0].toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUser.displayName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${otherUser.username}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
      ],
    );
  }

  Widget _buildChatHeader(ConversationModel conversation) {
    final otherUser = conversation.participants.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              otherUser.displayName[0].toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUser.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${otherUser.username}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ConversationModel conversation) {
    final messages = _getMockMessages(conversation.id);

    if (messages.isEmpty) {
      return const Center(child: Text('No messages yet'));
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isFromCurrentUser = message.sender.id == 'current_user';

        return _buildMessageBubble(message, isFromCurrentUser);
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isFromCurrentUser) {
    return Align(
      alignment: isFromCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isFromCurrentUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isFromCurrentUser
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.createdAt.timeAgo,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isFromCurrentUser
                    ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'Select a conversation',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a conversation from the sidebar to start messaging.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _startNewConversation() {
    // TODO: Implement new conversation functionality
    print('Start new conversation');
  }

  void _sendMessage(String message) {
    // TODO: Implement send message functionality
    print('Send message: $message');
  }

  List<ConversationModel> _getMockConversations() {
    final now = DateTime.now();
    final currentUser = UserModel(
      id: 'current_user',
      username: 'currentuser',
      displayName: 'Current User',
      email: 'current@example.com',
      joinedDate: DateTime.now(),
    );

    return [
      ConversationModel(
        id: '1',
        participants: [
          UserModel(
            id: '1',
            username: 'johndoe',
            displayName: 'John Doe',
            email: 'john@example.com',
            joinedDate: DateTime.now(),
          ),
          currentUser,
        ],
        lastMessage: MessageModel(
          id: '1',
          conversationId: '1',
          senderId: currentUser.id,
          sender: currentUser,
          receiver: UserModel(
            id: '1',
            username: 'johndoe',
            displayName: 'John Doe',
            email: 'john@example.com',
            joinedDate: DateTime.now(),
          ),
          content: 'Hey! How are you doing?',
          createdAt: now.subtract(const Duration(minutes: 30)),
        ),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
        unreadCount: 2,
      ),
      ConversationModel(
        id: '2',
        participants: [
          UserModel(
            id: '2',
            username: 'janesmith',
            displayName: 'Jane Smith',
            email: 'jane@example.com',
            joinedDate: DateTime.now(),
          ),
          currentUser,
        ],
        lastMessage: MessageModel(
          id: '2',
          conversationId: '2',
          sender: UserModel(
            id: '2',
            username: 'janesmith',
            displayName: 'Jane Smith',
            email: 'jane@example.com',
            joinedDate: DateTime.now(),
          ),
          senderId: '2',
          receiver: currentUser,
          content: 'Thanks for the help with the Flutter project!',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        unreadCount: 0,
      ),
    ];
  }

  List<MessageModel> _getMockMessages(String conversationId) {
    final now = DateTime.now();
    final currentUser = UserModel(
      id: 'current_user',
      username: 'currentuser',
      displayName: 'Current User',
      email: 'current@example.com',
      joinedDate: DateTime.now(),
    );

    final otherUser = UserModel(
      id: '1',
      username: 'johndoe',
      displayName: 'John Doe',
      email: 'john@example.com',
      joinedDate: DateTime.now(),
    );

    return [
      MessageModel(
        id: '1',
        conversationId: conversationId,
        senderId: currentUser.id,
        sender: otherUser,
        receiver: currentUser,
        content: 'Hey! How are you doing?',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      MessageModel(
        id: '2',
        conversationId: conversationId,
        senderId: currentUser.id,
        sender: currentUser,
        receiver: otherUser,
        content: 'Hi! I\'m doing great, thanks for asking!',
        createdAt: now.subtract(const Duration(minutes: 55)),
      ),
      MessageModel(
        id: '3',
        conversationId: conversationId,
        senderId: currentUser.id,
        sender: otherUser,
        receiver: currentUser,
        content:
            'That\'s awesome! Are you working on any interesting projects?',
        createdAt: now.subtract(const Duration(minutes: 50)),
      ),
      MessageModel(
        id: '4',
        conversationId: conversationId,
        senderId: currentUser.id,
        sender: currentUser,
        receiver: otherUser,
        content:
            'Yes! I\'m building a Flutter app similar to Twitter. It\'s been really fun!',
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }
}

extension on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}
