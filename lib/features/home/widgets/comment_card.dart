import 'package:flutter/material.dart';
import 'package:project_x/core/models/tweet_model.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final Tweet comment;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onRetweet;
  final VoidCallback? onShare;
  final int level;

  const CommentCard({
    super.key,
    required this.comment,
    this.onLike,
    this.onReply,
    this.onRetweet,
    this.onShare,
    this.level = 0,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _likeScaleAnimation;
  bool _showAllReplies = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Column(
          children: [
            _buildCommentContent(isDark),
            if (widget.comment.replies.isNotEmpty)
              _buildReplies(isDark),
          ],
        );
      },
    );
  }

  Widget _buildCommentContent(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16 + (widget.level * 32.0),
        12,
        16,
        12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thread line for nested comments
          if (widget.level > 0)
            Container(
              width: 2,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          
          // Avatar
          CircleAvatar(
            radius: widget.level > 0 ? 16 : 20,
            backgroundImage: NetworkImage(widget.comment.avatarUrl),
            backgroundColor: AppColors.surfaceColor(isDark),
          ),
          const SizedBox(width: 12),
          
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCommentHeader(isDark),
                const SizedBox(height: 4),
                _buildCommentText(isDark),
                if (widget.comment.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildCommentImages(isDark),
                ],
                const SizedBox(height: 8),
                _buildCommentActions(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentHeader(bool isDark) {
    return Row(
      children: [
        Flexible(
          child: Text(
            widget.comment.username,
            style: TextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary(isDark),
              fontSize: widget.level > 0 ? 13 : 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.comment.username == 'Elon Musk' || 
            widget.comment.username == 'Tech News') ...[
          const SizedBox(width: 4),
          Icon(
            Icons.verified,
            size: widget.level > 0 ? 12 : 14,
            color: AppColors.blue,
          ),
        ],
        const SizedBox(width: 4),
        Text(
          '@${widget.comment.handle}',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary(isDark),
            fontSize: widget.level > 0 ? 11 : 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '·',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary(isDark),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          widget.comment.timeAgo,
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary(isDark),
            fontSize: widget.level > 0 ? 11 : 12,
          ),
        ),
        const Spacer(),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_horiz,
            size: 16,
            color: AppColors.textSecondary(isDark),
          ),
          color: AppColors.surfaceColor(isDark),
          onSelected: (value) {
            _handleMenuAction(value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'copy',
              child: Row(
                children: [
                  Icon(
                    Icons.copy,
                    size: 16,
                    color: AppColors.textPrimary(isDark),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Copy comment',
                    style: TextStyles.bodySmall.copyWith(
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
                  Icon(
                    Icons.flag,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Report comment',
                    style: TextStyles.bodySmall.copyWith(
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

  Widget _buildCommentText(bool isDark) {
    return Text(
      widget.comment.content,
      style: TextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary(isDark),
        fontSize: widget.level > 0 ? 13 : 14,
        height: 1.4,
      ),
    );
  }

  Widget _buildCommentImages(bool isDark) {
    if (widget.comment.imageUrls.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: widget.comment.imageUrls.length == 1
          ? Image.network(
              widget.comment.imageUrls.first,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: AppColors.surfaceColor(isDark),
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
              ),
            )
          : SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.comment.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    margin: EdgeInsets.only(
                      right: index < widget.comment.imageUrls.length - 1 ? 4 : 0,
                    ),
                    child: Image.network(
                      widget.comment.imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceColor(isDark),
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 16,
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCommentActions(bool isDark) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          count: widget.comment.repliesCount,
          color: AppColors.textSecondary(isDark),
          onPressed: widget.onReply,
          isDark: isDark,
        ),
        const SizedBox(width: 32),
        _buildActionButton(
          icon: widget.comment.isRetweeted ? Icons.repeat : Icons.repeat,
          count: widget.comment.retweetsCount,
          color: widget.comment.isRetweeted 
              ? AppColors.success 
              : AppColors.textSecondary(isDark),
          onPressed: widget.onRetweet,
          isDark: isDark,
        ),
        const SizedBox(width: 32),
        _buildLikeButton(isDark),
        const SizedBox(width: 32),
        _buildActionButton(
          icon: Icons.share_outlined,
          count: 0,
          color: AppColors.textSecondary(isDark),
          onPressed: widget.onShare,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required Color color,
    VoidCallback? onPressed,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: widget.level > 0 ? 14 : 16,
              color: color,
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: TextStyles.bodySmall.copyWith(
                  color: color,
                  fontSize: widget.level > 0 ? 10 : 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton(bool isDark) {
    return InkWell(
      onTap: () {
        if (widget.onLike != null) {
          _animateLike();
          widget.onLike!();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _likeScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _likeScaleAnimation.value,
                  child: Icon(
                    widget.comment.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: widget.level > 0 ? 14 : 16,
                    color: widget.comment.isLiked 
                        ? AppColors.error 
                        : AppColors.textSecondary(isDark),
                  ),
                );
              },
            ),
            if (widget.comment.likesCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(widget.comment.likesCount),
                style: TextStyles.bodySmall.copyWith(
                  color: widget.comment.isLiked 
                      ? AppColors.error 
                      : AppColors.textSecondary(isDark),
                  fontSize: widget.level > 0 ? 10 : 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplies(bool isDark) {
    final repliesToShow = _showAllReplies 
        ? widget.comment.replies 
        : widget.comment.replies.take(2).toList();

    return Column(
      children: [
        ...repliesToShow.map((reply) => CommentCard(
          comment: reply,
          level: widget.level + 1,
          onLike: () => _likeReply(reply.id),
          onReply: () => _replyToComment(reply),
          onRetweet: () => _retweetReply(reply.id),
          onShare: () => _shareReply(reply.id),
        )),
        
        if (widget.comment.replies.length > 2 && !_showAllReplies)
          Container(
            padding: EdgeInsets.fromLTRB(
              48 + (widget.level * 32.0),
              8,
              16,
              8,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _showAllReplies = true;
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 2,
                    height: 20,
                    color: AppColors.blue.withOpacity(0.3),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Show ${widget.comment.replies.length - 2} more replies',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _animateLike() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'copy':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment copied to clipboard'),
            backgroundColor: AppColors.success,
          ),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your report'),
            backgroundColor: AppColors.info,
          ),
        );
        break;
    }
  }

  void _likeReply(String replyId) {
    // Handle reply like
  }

  void _replyToComment(Tweet reply) {
    // Handle reply to comment
  }

  void _retweetReply(String replyId) {
    // Handle reply retweet
  }

  void _shareReply(String replyId) {
    // Handle reply share
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}