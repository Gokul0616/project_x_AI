import 'package:flutter/material.dart';
import 'package:project_x/core/models/tweet_model.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/theme/theme_provider.dart';
import 'package:project_x/features/home/widgets/tweet_reply_dialog.dart';
import 'package:project_x/features/home/widgets/retweet_dialog.dart';
import 'package:project_x/features/home/widgets/tweet_comments_screen.dart';
import 'package:provider/provider.dart';

class EnhancedTweetCard extends StatefulWidget {
  final Tweet tweet;
  final VoidCallback? onLike;
  final VoidCallback? onRetweet;
  final VoidCallback? onReply;
  final VoidCallback? onShare;
  final Function(String, {List<String> mediaUrls, Tweet? quoteTweet})?
  onQuoteTweet;
  final bool showReplies;
  final int indentLevel;

  const EnhancedTweetCard({
    super.key,
    required this.tweet,
    this.onLike,
    this.onRetweet,
    this.onReply,
    this.onShare,
    this.onQuoteTweet,
    this.showReplies = false,
    this.indentLevel = 0,
  });

  @override
  State<EnhancedTweetCard> createState() => _EnhancedTweetCardState();
}

class _EnhancedTweetCardState extends State<EnhancedTweetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _likeScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
            _buildTweetContent(context, isDark),
            if (widget.showReplies && widget.tweet.replies.isNotEmpty)
              ...widget.tweet.replies.map(
                (reply) => Padding(
                  padding: EdgeInsets.only(
                    left: 20.0 * (widget.indentLevel + 1),
                  ),
                  child: EnhancedTweetCard(
                    tweet: reply,
                    onLike: widget.onLike,
                    onRetweet: widget.onRetweet,
                    onReply: widget.onReply,
                    onShare: widget.onShare,
                    onQuoteTweet: widget.onQuoteTweet,
                    showReplies: true,
                    indentLevel: widget.indentLevel + 1,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTweetContent(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () => _navigateToComments(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.indentLevel > 0
              ? AppColors.surfaceColor(isDark)
              : Colors.transparent,
          borderRadius: widget.indentLevel > 0
              ? BorderRadius.circular(12)
              : null,
          border: widget.indentLevel > 0
              ? Border.all(color: AppColors.borderColor(isDark), width: 0.5)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(isDark),
            const SizedBox(width: 12),
            Expanded(child: _buildTweetBody(context, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return CircleAvatar(
      radius: widget.indentLevel > 0 ? 18 : 24,
      backgroundImage: NetworkImage(widget.tweet.avatarUrl),
      backgroundColor: AppColors.surfaceColor(isDark),
    );
  }

  Widget _buildTweetBody(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfo(isDark),
        const SizedBox(height: 4),
        _buildContent(isDark),
        if (widget.tweet.imageUrls.isNotEmpty) _buildImages(),
        const SizedBox(height: 12),
        _buildActionButtons(context, isDark),
      ],
    );
  }

  Widget _buildUserInfo(bool isDark) {
    return Row(
      children: [
        Flexible(
          child: Text(
            widget.tweet.username,
            style: TextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary(isDark),
              fontSize: widget.indentLevel > 0 ? 13 : 15,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.tweet.username == 'Elon Musk' ||
            widget.tweet.username == 'Tech News') ...[
          const SizedBox(width: 4),
          Icon(
            Icons.verified,
            size: widget.indentLevel > 0 ? 14 : 16,
            color: AppColors.blue,
          ),
        ],
        const SizedBox(width: 4),
        Text(
          '@${widget.tweet.handle}',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary(isDark),
            fontSize: widget.indentLevel > 0 ? 11 : 13,
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
        Flexible(
          child: Text(
            widget.tweet.timeAgo,
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary(isDark),
              fontSize: widget.indentLevel > 0 ? 11 : 13,
            ),
            overflow: TextOverflow.ellipsis,
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
              value: 'follow',
              child: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    size: 16,
                    color: AppColors.textPrimary(isDark),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Follow @${widget.tweet.handle}',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(
                    Icons.volume_off,
                    size: 16,
                    color: AppColors.textPrimary(isDark),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mute @${widget.tweet.handle}',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(
                    'Block @${widget.tweet.handle}',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag, size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(
                    'Report Tweet',
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

  Widget _buildContent(bool isDark) {
    return Text(
      widget.tweet.content,
      style: TextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary(isDark),
        fontSize: widget.indentLevel > 0 ? 14 : 16,
        height: 1.4,
      ),
    );
  }

  Widget _buildImages() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.tweet.imageUrls.length == 1
            ? Image.network(
                widget.tweet.imageUrls.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: AppColors.surfaceColor(
                    Provider.of<ThemeProvider>(context).isDarkMode,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.textSecondary(
                        Provider.of<ThemeProvider>(context).isDarkMode,
                      ),
                    ),
                  ),
                ),
              )
            : _buildMultipleImages(),
      ),
    );
  }

  Widget _buildMultipleImages() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: widget.tweet.imageUrls.length > 4
          ? 4
          : widget.tweet.imageUrls.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Image.network(
              widget.tweet.imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surfaceColor(
                  Provider.of<ThemeProvider>(context).isDarkMode,
                ),
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: AppColors.textSecondary(
                      Provider.of<ThemeProvider>(context).isDarkMode,
                    ),
                  ),
                ),
              ),
            ),
            if (index == 3 && widget.tweet.imageUrls.length > 4)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Text(
                    '+${widget.tweet.imageUrls.length - 4}',
                    style: TextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          count: widget.tweet.repliesCount,
          color: AppColors.textSecondary(isDark),
          onPressed: () => _navigateToComments(context),
          isDark: isDark,
        ),
        _buildRetweetButton(context, isDark),
        _buildLikeButton(isDark),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: widget.indentLevel > 0 ? 16 : 18, color: color),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: TextStyles.bodySmall.copyWith(
                  color: color,
                  fontSize: widget.indentLevel > 0 ? 11 : 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRetweetButton(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () => _showRetweetDialog(context),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.tweet.isRetweeted ? Icons.repeat : Icons.repeat,
              size: widget.indentLevel > 0 ? 16 : 18,
              color: widget.tweet.isRetweeted
                  ? AppColors.success
                  : AppColors.textSecondary(isDark),
            ),
            if (widget.tweet.retweetsCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(widget.tweet.retweetsCount),
                style: TextStyles.bodySmall.copyWith(
                  color: widget.tweet.isRetweeted
                      ? AppColors.success
                      : AppColors.textSecondary(isDark),
                  fontSize: widget.indentLevel > 0 ? 11 : 12,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _likeScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _likeScaleAnimation.value,
                  child: Icon(
                    widget.tweet.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: widget.indentLevel > 0 ? 16 : 18,
                    color: widget.tweet.isLiked
                        ? AppColors.error
                        : AppColors.textSecondary(isDark),
                  ),
                );
              },
            ),
            if (widget.tweet.likesCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(widget.tweet.likesCount),
                style: TextStyles.bodySmall.copyWith(
                  color: widget.tweet.isLiked
                      ? AppColors.error
                      : AppColors.textSecondary(isDark),
                  fontSize: widget.indentLevel > 0 ? 11 : 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _animateLike() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _navigateToComments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TweetCommentsScreen(
          tweet: widget.tweet,
          onReply: (content, tweet) {
            if (widget.onReply != null) {
              widget.onReply!();
            }
          },
          onLike: widget.onLike ?? () {},
          onRetweet: widget.onRetweet ?? () {},
          onShare: widget.onShare ?? () {},
        ),
      ),
    );
  }

  void _showRetweetDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => RetweetDialog(
        tweet: widget.tweet,
        onRetweet: widget.onRetweet ?? () {},
        onQuoteTweet:
            widget.onQuoteTweet ??
            (content, {List<String>? mediaUrls, quoteTweet}) {},
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'follow':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Following @${widget.tweet.handle}'),
            backgroundColor: AppColors.success,
          ),
        );
        break;
      case 'mute':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Muted @${widget.tweet.handle}'),
            backgroundColor: AppColors.info,
          ),
        );
        break;
      case 'block':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Blocked @${widget.tweet.handle}'),
            backgroundColor: AppColors.error,
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

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
