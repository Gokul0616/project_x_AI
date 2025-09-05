import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/theme/theme_provider.dart';
import 'package:project_x/core/models/tweet_model.dart';
import 'package:project_x/features/home/widgets/enhanced_tweet_composer.dart';
import 'package:project_x/features/home/widgets/tweet_card_detailed.dart';
import 'package:project_x/features/home/widgets/comment_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

class TweetCommentsScreen extends StatefulWidget {
  final Tweet tweet;
  final Function(String, Tweet) onReply;
  final VoidCallback onLike;
  final VoidCallback onRetweet;
  final VoidCallback onShare;

  const TweetCommentsScreen({
    super.key,
    required this.tweet,
    required this.onReply,
    required this.onLike,
    required this.onRetweet,
    required this.onShare,
  });

  @override
  State<TweetCommentsScreen> createState() => _TweetCommentsScreenState();
}

class _TweetCommentsScreenState extends State<TweetCommentsScreen> {
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  List<Tweet> _comments = [];
  bool _isLoading = false;
  String _sortBy = 'newest'; // newest, oldest, popular

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadComments() {
    setState(() {
      _isLoading = true;
    });

    // Mock comments data - in real app, fetch from API
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _comments = _generateMockComments();
          _isLoading = false;
        });
      }
    });
  }

  void _onRefresh() {
    _loadComments();
    _refreshController.refreshCompleted();
  }

  void _onLoadMore() {
    // Load more comments
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _comments.addAll(_generateMockComments(startIndex: _comments.length));
        });
        _refreshController.loadComplete();
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
          appBar: _buildAppBar(isDark),
          body: Column(
            children: [
              Expanded(
                child: SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoadMore,
                  enablePullUp: true,
                  header: WaterDropHeader(
                    waterDropColor: AppColors.blue,
                    complete: Icon(Icons.check, color: AppColors.blue),
                  ),
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus? mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Text(
                          "Pull up to load more",
                          style: TextStyle(
                            color: AppColors.textSecondary(isDark),
                          ),
                        );
                      } else if (mode == LoadStatus.loading) {
                        body = CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.blue),
                        );
                      } else if (mode == LoadStatus.failed) {
                        body = Text(
                          "Load Failed! Click retry!",
                          style: TextStyle(color: AppColors.error),
                        );
                      } else if (mode == LoadStatus.canLoading) {
                        body = Text(
                          "Release to load more",
                          style: TextStyle(
                            color: AppColors.textSecondary(isDark),
                          ),
                        );
                      } else {
                        body = Text(
                          "No more comments",
                          style: TextStyle(
                            color: AppColors.textSecondary(isDark),
                          ),
                        );
                      }
                      return Container(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Original Tweet
                      SliverToBoxAdapter(
                        child: TweetCardDetailed(
                          tweet: widget.tweet,
                          onLike: widget.onLike,
                          onRetweet: widget.onRetweet,
                          onReply: () => _showReplyComposer(),
                          onShare: widget.onShare,
                        ),
                      ),

                      // Comments Header
                      SliverToBoxAdapter(child: _buildCommentsHeader(isDark)),

                      // Loading State
                      if (_isLoading)
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Comments List
                      if (!_isLoading)
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final comment = _comments[index];
                            return CommentCard(
                              comment: comment,
                              onLike: () => _likeComment(comment.id),
                              onReply: () => _replyToComment(comment),
                              onRetweet: () => _retweetComment(comment.id),
                              onShare: () => _shareComment(comment.id),
                            );
                          }, childCount: _comments.length),
                        ),
                    ],
                  ),
                ),
              ),
              _buildReplyBar(isDark),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor(isDark),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(isDark)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Tweet',
        style: TextStyles.titleMedium.copyWith(
          color: AppColors.textPrimary(isDark),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.textPrimary(isDark)),
          color: AppColors.surfaceColor(isDark),
          onSelected: (value) {
            switch (value) {
              case 'share':
                widget.onShare();
                break;
              case 'copy':
                _copyTweetLink();
                break;
              case 'report':
                _reportTweet();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(
                    Icons.share,
                    color: AppColors.textPrimary(isDark),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Share Tweet',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'copy',
              child: Row(
                children: [
                  Icon(
                    Icons.copy,
                    color: AppColors.textPrimary(isDark),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Copy link',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag, color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Report Tweet',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor(isDark), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Comments',
            style: TextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            initialValue: _sortBy,
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort,
                  size: 16,
                  color: AppColors.textSecondary(isDark),
                ),
                const SizedBox(width: 4),
                Text(
                  _getSortLabel(_sortBy),
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
              ],
            ),
            color: AppColors.surfaceColor(isDark),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _loadComments(); // Reload with new sort
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'newest',
                child: Text(
                  'Newest first',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'oldest',
                child: Text(
                  'Oldest first',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'popular',
                child: Text(
                  'Most popular',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(isDark),
        border: Border(
          top: BorderSide(color: AppColors.borderColor(isDark), width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _showReplyComposer,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor(isDark),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderColor(isDark),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'Tweet your reply',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReplyComposer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedTweetComposer(
        replyToTweet: widget.tweet,
        onTweet: (content, {List<String>? mediaUrls, quoteTweet}) {
          widget.onReply(content, widget.tweet);
          _addNewComment(content);
        },
      ),
    );
  }

  void _replyToComment(Tweet comment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedTweetComposer(
        replyToTweet: comment,
        onTweet: (content, {List<String>? mediaUrls, quoteTweet}) {
          // Add reply to the comment
          _addReplyToComment(comment.id, content);
        },
      ),
    );
  }

  void _addNewComment(String content) {
    final newComment = Tweet(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      username: 'You',
      handle: 'you',
      avatarUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      content: content,
      createdAt: DateTime.now(),
      parentTweetId: widget.tweet.id,
    );

    setState(() {
      _comments.insert(0, newComment);
    });
  }

  void _addReplyToComment(String commentId, String content) {
    final reply = Tweet(
      id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      username: 'You',
      handle: 'you',
      avatarUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      content: content,
      createdAt: DateTime.now(),
      parentTweetId: commentId,
    );

    // Find the comment and add the reply
    setState(() {
      final commentIndex = _comments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1) {
        final comment = _comments[commentIndex];
        final updatedReplies = List<Tweet>.from(comment.replies)..add(reply);
        _comments[commentIndex] = comment.copyWith(
          replies: updatedReplies,
          repliesCount: comment.repliesCount + 1,
        );
      }
    });
  }

  void _likeComment(String commentId) {
    setState(() {
      final commentIndex = _comments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1) {
        final comment = _comments[commentIndex];
        _comments[commentIndex] = comment.copyWith(
          isLiked: !comment.isLiked,
          likesCount: comment.isLiked
              ? comment.likesCount - 1
              : comment.likesCount + 1,
        );
      }
    });
  }

  void _retweetComment(String commentId) {
    setState(() {
      final commentIndex = _comments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1) {
        final comment = _comments[commentIndex];
        _comments[commentIndex] = comment.copyWith(
          isRetweeted: !comment.isRetweeted,
          retweetsCount: comment.isRetweeted
              ? comment.retweetsCount - 1
              : comment.retweetsCount + 1,
        );
      }
    });
  }

  void _shareComment(String commentId) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _copyTweetLink() {
    // Implement copy link functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copied to clipboard'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _reportTweet() {
    // Implement report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for your report'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'newest':
        return 'Newest';
      case 'oldest':
        return 'Oldest';
      case 'popular':
        return 'Popular';
      default:
        return 'Newest';
    }
  }

  List<Tweet> _generateMockComments({int startIndex = 0}) {
    final mockUsers = [
      {
        'name': 'Sarah Johnson',
        'handle': 'sarahj',
        'avatar': 'photo-1494790108755-2616b612b5bc',
      },
      {
        'name': 'Mike Chen',
        'handle': 'mikechen',
        'avatar': 'photo-1507003211169-0a1dd7228f2d',
      },
      {
        'name': 'Emily Davis',
        'handle': 'emilyd',
        'avatar': 'photo-1438761681033-6461ffad8d80',
      },
      {
        'name': 'Alex Rodriguez',
        'handle': 'alexr',
        'avatar': 'photo-1472099645785-5658abf4ff4e',
      },
      {
        'name': 'Lisa Wang',
        'handle': 'lisawang',
        'avatar': 'photo-1494790108755-2616b612b5bc',
      },
    ];

    final mockComments = [
      "Great point! I totally agree with this perspective.",
      "This is exactly what I've been thinking lately. Thanks for sharing!",
      "Interesting take. I have a slightly different view on this...",
      "Love this! Can't wait to see more content like this.",
      "This made me think about the broader implications. Fascinating stuff!",
      "Thanks for the insight! This really opened my eyes.",
      "I disagree with some points, but overall a good discussion starter.",
      "This is why I love this platform. Great conversations happen here!",
      "Adding this to my bookmarks. Such valuable information!",
      "Could you elaborate more on this point? I'd love to learn more.",
    ];

    return List.generate(5, (index) {
      final actualIndex = startIndex + index;
      final user = mockUsers[actualIndex % mockUsers.length];
      final comment = mockComments[actualIndex % mockComments.length];

      return Tweet(
        id: 'comment_${actualIndex}',
        userId: 'user_${actualIndex}',
        username: user['name']!,
        handle: user['handle']!,
        avatarUrl:
            'https://images.unsplash.com/${user['avatar']}?w=150&h=150&fit=crop&crop=face',
        content: comment,
        createdAt: DateTime.now().subtract(Duration(hours: index + 1)),
        parentTweetId: widget.tweet.id,
        likesCount: (index * 3) + 2,
        retweetsCount: index + 1,
        repliesCount: index,
        isLiked: index % 3 == 0,
        isRetweeted: index % 4 == 0,
      );
    });
  }
}
