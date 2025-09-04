import 'package:flutter/material.dart';
import 'package:project_x/core/models/tweet_model.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/features/home/widgets/tweet_reply_dialog.dart';

class EnhancedTweetCard extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback? onLike;
  final VoidCallback? onRetweet;
  final VoidCallback? onReply;
  final VoidCallback? onShare;
  final bool showReplies;
  final int indentLevel;

  const EnhancedTweetCard({
    super.key,
    required this.tweet,
    this.onLike,
    this.onRetweet,
    this.onReply,
    this.onShare,
    this.showReplies = true,
    this.indentLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTweetContent(context),
        if (showReplies && tweet.replies.isNotEmpty)
          ...tweet.replies.map(
            (reply) => Padding(
              padding: EdgeInsets.only(left: 20.0 * (indentLevel + 1)),
              child: EnhancedTweetCard(
                tweet: reply,
                onLike: () => onLike?.call(),
                onRetweet: () => onRetweet?.call(),
                onReply: () => onReply?.call(),
                onShare: () => onShare?.call(),
                showReplies: true,
                indentLevel: indentLevel + 1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTweetContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: indentLevel > 0 ? AppColors.surfaceColor : Colors.transparent,
        borderRadius: indentLevel > 0 ? BorderRadius.circular(12) : null,
        border: indentLevel > 0
            ? Border.all(color: AppColors.borderColor, width: 0.5)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(child: _buildTweetBody(context)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: indentLevel > 0 ? 18 : 24,
      backgroundImage: NetworkImage(tweet.avatarUrl),
      backgroundColor: AppColors.darkGray,
    );
  }

  Widget _buildTweetBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfo(),
        const SizedBox(height: 4),
        _buildTweetContent(context),
        if (tweet.imageUrls.isNotEmpty) _buildImages(),
        const SizedBox(height: 12),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        Text(
          tweet.username,
          style: TextStyles.titleSmall.copyWith(
            color: AppColors.white,
            fontSize: indentLevel > 0 ? 13 : 15,
          ),
        ),
        if (tweet.username == 'Elon Musk' || tweet.username == 'Tech News') ...[
          const SizedBox(width: 4),
          Icon(
            Icons.verified,
            size: indentLevel > 0 ? 14 : 16,
            color: AppColors.blue,
          ),
        ],
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '@${tweet.handle} · ${tweet.timeAgo}',
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.midGray,
              fontSize: indentLevel > 0 ? 11 : 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Widget _buildTweetContent(BuildContext context) {
  //   return Text(
  //     tweet.content,
  //     style: TextStyles.bodyMedium.copyWith(
  //       color: AppColors.white,
  //       fontSize: indentLevel > 0 ? 14 : 16,
  //       height: 1.4,
  //     ),
  //   );
  // }

  Widget _buildImages() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: tweet.imageUrls.length == 1
            ? Image.network(
                tweet.imageUrls.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: AppColors.darkGray,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: AppColors.midGray),
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
      itemCount: tweet.imageUrls.length > 4 ? 4 : tweet.imageUrls.length,
      itemBuilder: (context, index) {
        return Image.network(
          tweet.imageUrls[index],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.darkGray,
            child: const Center(
              child: Icon(Icons.broken_image, color: AppColors.midGray),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          count: tweet.repliesCount,
          color: AppColors.midGray,
          onPressed: () => _showReplyDialog(context),
        ),
        _buildActionButton(
          icon: tweet.isRetweeted ? Icons.repeat : Icons.repeat,
          count: tweet.retweetsCount,
          color: tweet.isRetweeted ? AppColors.success : AppColors.midGray,
          onPressed: onRetweet,
        ),
        _buildActionButton(
          icon: tweet.isLiked ? Icons.favorite : Icons.favorite_border,
          count: tweet.likesCount,
          color: tweet.isLiked ? AppColors.error : AppColors.midGray,
          onPressed: onLike,
        ),
        _buildActionButton(
          icon: Icons.share_outlined,
          count: 0,
          color: AppColors.midGray,
          onPressed: onShare,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: indentLevel > 0 ? 16 : 18, color: color),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: TextStyles.bodySmall.copyWith(
                  color: color,
                  fontSize: indentLevel > 0 ? 11 : 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _showReplyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TweetReplyDialog(
        parentTweet: tweet,
        onReply: (content) {
          onReply?.call();
          Navigator.pop(context);
        },
      ),
    );
  }
}
