import 'package:flutter/material.dart';
import 'package:project_x/core/models/tweet_model.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class TweetCardDetailed extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback? onLike;
  final VoidCallback? onRetweet;
  final VoidCallback? onReply;
  final VoidCallback? onShare;

  const TweetCardDetailed({
    super.key,
    required this.tweet,
    this.onLike,
    this.onRetweet,
    this.onReply,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderColor(isDark),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(isDark),
              const SizedBox(height: 12),
              _buildTweetContent(isDark),
              if (tweet.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildImages(),
              ],
              const SizedBox(height: 16),
              _buildTweetMeta(isDark),
              const SizedBox(height: 16),
              Divider(
                color: AppColors.borderColor(isDark),
                height: 1,
              ),
              const SizedBox(height: 16),
              _buildEngagementStats(isDark),
              const SizedBox(height: 16),
              Divider(
                color: AppColors.borderColor(isDark),
                height: 1,
              ),
              const SizedBox(height: 16),
              _buildActionButtons(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInfo(bool isDark) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(tweet.avatarUrl),
          backgroundColor: AppColors.surfaceColor(isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      tweet.username,
                      style: TextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (tweet.username == 'Elon Musk' || tweet.username == 'Tech News') ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: AppColors.blue,
                    ),
                  ],
                ],
              ),
              Text(
                '@${tweet.handle}',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_horiz,
            color: AppColors.textSecondary(isDark),
          ),
          color: AppColors.surfaceColor(isDark),
          onSelected: (value) {
            // Handle menu actions
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'follow',
              child: Text(
                'Follow @${tweet.handle}',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'mute',
              child: Text(
                'Mute @${tweet.handle}',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary(isDark),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'block',
              child: Text(
                'Block @${tweet.handle}',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Text(
                'Report Tweet',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTweetContent(bool isDark) {
    return Text(
      tweet.content,
      style: TextStyles.bodyLarge.copyWith(
        color: AppColors.textPrimary(isDark),
        fontSize: 20,
        height: 1.4,
      ),
    );
  }

  Widget _buildImages() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: tweet.imageUrls.length == 1
          ? Image.network(
              tweet.imageUrls.first,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
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
    );
  }

  Widget _buildMultipleImages() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: tweet.imageUrls.length == 2 ? 2 : 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: tweet.imageUrls.length == 2 ? 1.5 : 1,
      ),
      itemCount: tweet.imageUrls.length > 4 ? 4 : tweet.imageUrls.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Image.network(
              tweet.imageUrls[index],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
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
            if (index == 3 && tweet.imageUrls.length > 4)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Text(
                    '+${tweet.imageUrls.length - 4}',
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

  Widget _buildTweetMeta(bool isDark) {
    return Text(
      '${_formatTime(tweet.createdAt)} · ${_formatDate(tweet.createdAt)}',
      style: TextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary(isDark),
      ),
    );
  }

  Widget _buildEngagementStats(bool isDark) {
    return Row(
      children: [
        if (tweet.retweetsCount > 0) ...[
          _buildStatItem(
            '${_formatCount(tweet.retweetsCount)}',
            tweet.retweetsCount == 1 ? 'Retweet' : 'Retweets',
            isDark,
          ),
          const SizedBox(width: 20),
        ],
        if (tweet.likesCount > 0) ...[
          _buildStatItem(
            '${_formatCount(tweet.likesCount)}',
            tweet.likesCount == 1 ? 'Like' : 'Likes',
            isDark,
          ),
          const SizedBox(width: 20),
        ],
        if (tweet.repliesCount > 0) ...[
          _buildStatItem(
            '${_formatCount(tweet.repliesCount)}',
            tweet.repliesCount == 1 ? 'Reply' : 'Replies',
            isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(String count, String label, bool isDark) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: count,
            style: TextStyles.titleSmall.copyWith(
              color: AppColors.textPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          onPressed: onReply,
          isDark: isDark,
        ),
        _buildActionButton(
          icon: tweet.isRetweeted ? Icons.repeat : Icons.repeat,
          color: tweet.isRetweeted ? AppColors.success : null,
          onPressed: onRetweet,
          isDark: isDark,
        ),
        _buildActionButton(
          icon: tweet.isLiked ? Icons.favorite : Icons.favorite_border,
          color: tweet.isLiked ? AppColors.error : null,
          onPressed: onLike,
          isDark: isDark,
        ),
        _buildActionButton(
          icon: Icons.share_outlined,
          onPressed: onShare,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color? color,
    VoidCallback? onPressed,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: 24,
          color: color ?? AppColors.textSecondary(isDark),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
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