import 'package:project_x/core/models/user_model.dart';

class TweetModel {
  final String id;
  final String content;
  final UserModel author;
  final DateTime createdAt;
  final List<String> mediaUrls;
  final int likes;
  final int retweets;
  final int replies;
  final bool isLiked;
  final bool isRetweeted;
  final String? quotedTweetId;
  final TweetModel? quotedTweet;
  final String? replyToTweetId;
  final TweetModel? replyToTweet;
  final List<String> mentions;
  final List<String> hashtags;

  const TweetModel({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
    this.mediaUrls = const [],
    this.likes = 0,
    this.retweets = 0,
    this.replies = 0,
    this.isLiked = false,
    this.isRetweeted = false,
    this.quotedTweetId,
    this.quotedTweet,
    this.replyToTweetId,
    this.replyToTweet,
    this.mentions = const [],
    this.hashtags = const [],
  });

  factory TweetModel.fromJson(Map<String, dynamic> json) {
    return TweetModel(
      id: json['id'],
      content: json['content'],
      author: UserModel.fromJson(json['author']),
      createdAt: DateTime.parse(json['createdAt']),
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      likes: json['likes'] ?? 0,
      retweets: json['retweets'] ?? 0,
      replies: json['replies'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isRetweeted: json['isRetweeted'] ?? false,
      quotedTweetId: json['quotedTweetId'],
      quotedTweet: json['quotedTweet'] != null
          ? TweetModel.fromJson(json['quotedTweet'])
          : null,
      replyToTweetId: json['replyToTweetId'],
      replyToTweet: json['replyToTweet'] != null
          ? TweetModel.fromJson(json['replyToTweet'])
          : null,
      mentions: List<String>.from(json['mentions'] ?? []),
      hashtags: List<String>.from(json['hashtags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'mediaUrls': mediaUrls,
      'likes': likes,
      'retweets': retweets,
      'replies': replies,
      'isLiked': isLiked,
      'isRetweeted': isRetweeted,
      'quotedTweetId': quotedTweetId,
      'quotedTweet': quotedTweet?.toJson(),
      'replyToTweetId': replyToTweetId,
      'replyToTweet': replyToTweet?.toJson(),
      'mentions': mentions,
      'hashtags': hashtags,
    };
  }

  TweetModel copyWith({
    String? id,
    String? content,
    UserModel? author,
    DateTime? createdAt,
    List<String>? mediaUrls,
    int? likes,
    int? retweets,
    int? replies,
    bool? isLiked,
    bool? isRetweeted,
    String? quotedTweetId,
    TweetModel? quotedTweet,
    String? replyToTweetId,
    TweetModel? replyToTweet,
    List<String>? mentions,
    List<String>? hashtags,
  }) {
    return TweetModel(
      id: id ?? this.id,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      likes: likes ?? this.likes,
      retweets: retweets ?? this.retweets,
      replies: replies ?? this.replies,
      isLiked: isLiked ?? this.isLiked,
      isRetweeted: isRetweeted ?? this.isRetweeted,
      quotedTweetId: quotedTweetId ?? this.quotedTweetId,
      quotedTweet: quotedTweet ?? this.quotedTweet,
      replyToTweetId: replyToTweetId ?? this.replyToTweetId,
      replyToTweet: replyToTweet ?? this.replyToTweet,
      mentions: mentions ?? this.mentions,
      hashtags: hashtags ?? this.hashtags,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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