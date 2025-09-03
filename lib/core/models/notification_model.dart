import 'package:project_x/core/models/user_model.dart';
import 'package:project_x/core/models/tweet_model.dart';

enum NotificationType {
  like,
  retweet,
  follow,
  mention,
  reply,
  quote,
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final UserModel fromUser;
  final UserModel toUser;
  final TweetModel? tweet;
  final String? content;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.fromUser,
    required this.toUser,
    this.tweet,
    this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
      ),
      fromUser: UserModel.fromJson(json['fromUser']),
      toUser: UserModel.fromJson(json['toUser']),
      tweet: json['tweet'] != null ? TweetModel.fromJson(json['tweet']) : null,
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'fromUser': fromUser.toJson(),
      'toUser': toUser.toJson(),
      'tweet': tweet?.toJson(),
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    UserModel? fromUser,
    UserModel? toUser,
    TweetModel? tweet,
    String? content,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
      tweet: tweet ?? this.tweet,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  String get message {
    switch (type) {
      case NotificationType.like:
        return '${fromUser.displayName} liked your tweet';
      case NotificationType.retweet:
        return '${fromUser.displayName} retweeted your tweet';
      case NotificationType.follow:
        return '${fromUser.displayName} started following you';
      case NotificationType.mention:
        return '${fromUser.displayName} mentioned you in a tweet';
      case NotificationType.reply:
        return '${fromUser.displayName} replied to your tweet';
      case NotificationType.quote:
        return '${fromUser.displayName} quoted your tweet';
    }
  }
}