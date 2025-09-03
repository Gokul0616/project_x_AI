import 'package:project_x/core/models/user_model.dart';

enum MessageType {
  text,
  image,
  video,
  gif,
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final UserModel sender;
  final UserModel receiver;
  final String content;
  final MessageType type;
  final String? mediaUrl;
  final DateTime createdAt;
  final DateTime timestamp;
  final bool isRead;
  final bool isDelivered;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sender,
    required this.receiver,
    required this.content,
    this.type = MessageType.text,
    this.mediaUrl,
    required this.createdAt,
    DateTime? timestamp,
    this.isRead = false,
    this.isDelivered = false,
  }) : timestamp = timestamp ?? createdAt;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      sender: UserModel.fromJson(json['sender']),
      receiver: UserModel.fromJson(json['receiver']),
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
      ),
      mediaUrl: json['mediaUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      isRead: json['isRead'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'content': content,
      'type': type.toString().split('.').last,
      'mediaUrl': mediaUrl,
      'createdAt': createdAt.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isDelivered': isDelivered,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    UserModel? sender,
    UserModel? receiver,
    String? content,
    MessageType? type,
    String? mediaUrl,
    DateTime? createdAt,
    DateTime? timestamp,
    bool? isRead,
    bool? isDelivered,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }
}

class ConversationModel {
  final String id;
  final List<UserModel> participants;
  final List<MessageModel> messages;
  final MessageModel? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.participants,
    this.messages = const [],
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      participants: (json['participants'] as List)
          .map((participant) => UserModel.fromJson(participant))
          .toList(),
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((message) => MessageModel.fromJson(message))
              .toList()
          : [],
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((p) => p.toJson()).toList(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}