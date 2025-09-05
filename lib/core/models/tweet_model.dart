class Tweet {
  final String id;
  final String userId;
  final String username;
  final String handle;
  final String avatarUrl;
  final String content;
  final DateTime createdAt;
  final List<String> imageUrls;
  final int likesCount;
  final int retweetsCount;
  final int repliesCount;
  final bool isLiked;
  final bool isRetweeted;
  final bool isBookmarked;
  final bool isFollowing;
  final String? parentTweetId; // For nested replies
  final List<Tweet> replies; // Nested replies
  final bool isRetweet;
  final Tweet? retweetedTweet; // Original tweet if this is a retweet
  final String? retweetedBy; // User who retweeted
  final Tweet? quotedTweet; // For quote tweets
  final bool isQuoteTweet;
  final int quoteTweetCount;
  final List<String> videoUrls; // For video content
  final String? pollId; // For polls
  final String? locationName; // For location data

  const Tweet({
    required this.id,
    required this.userId,
    required this.username,
    required this.handle,
    required this.avatarUrl,
    required this.content,
    required this.createdAt,
    this.imageUrls = const [],
    this.likesCount = 0,
    this.retweetsCount = 0,
    this.repliesCount = 0,
    this.isLiked = false,
    this.isRetweeted = false,
    this.isBookmarked = false,
    this.isFollowing = false,
    this.parentTweetId,
    this.replies = const [],
    this.isRetweet = false,
    this.retweetedTweet,
    this.retweetedBy,
    this.quotedTweet,
    this.isQuoteTweet = false,
    this.quoteTweetCount = 0,
    this.videoUrls = const [],
    this.pollId,
    this.locationName,
  });

  Tweet copyWith({
    String? id,
    String? userId,
    String? username,
    String? handle,
    String? avatarUrl,
    String? content,
    DateTime? createdAt,
    List<String>? imageUrls,
    int? likesCount,
    int? retweetsCount,
    int? repliesCount,
    bool? isLiked,
    bool? isRetweeted,
    bool? isBookmarked,
    bool? isFollowing,
    String? parentTweetId,
    List<Tweet>? replies,
    bool? isRetweet,
    Tweet? retweetedTweet,
    String? retweetedBy,
    Tweet? quotedTweet,
    bool? isQuoteTweet,
    int? quoteTweetCount,
    List<String>? videoUrls,
    String? pollId,
    String? locationName,
  }) {
    return Tweet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      handle: handle ?? this.handle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
      likesCount: likesCount ?? this.likesCount,
      retweetsCount: retweetsCount ?? this.retweetsCount,
      repliesCount: repliesCount ?? this.repliesCount,
      isLiked: isLiked ?? this.isLiked,
      isRetweeted: isRetweeted ?? this.isRetweeted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFollowing: isFollowing ?? this.isFollowing,
      parentTweetId: parentTweetId ?? this.parentTweetId,
      replies: replies ?? this.replies,
      isRetweet: isRetweet ?? this.isRetweet,
      retweetedTweet: retweetedTweet ?? this.retweetedTweet,
      retweetedBy: retweetedBy ?? this.retweetedBy,
      quotedTweet: quotedTweet ?? this.quotedTweet,
      isQuoteTweet: isQuoteTweet ?? this.isQuoteTweet,
      quoteTweetCount: quoteTweetCount ?? this.quoteTweetCount,
      videoUrls: videoUrls ?? this.videoUrls,
      pollId: pollId ?? this.pollId,
      locationName: locationName ?? this.locationName,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  bool get hasMedia => imageUrls.isNotEmpty || videoUrls.isNotEmpty;
  
  bool get isThread => replies.isNotEmpty;
  
  String get mediaType {
    if (videoUrls.isNotEmpty) return 'video';
    if (imageUrls.isNotEmpty) return 'image';
    return 'text';
  }
}