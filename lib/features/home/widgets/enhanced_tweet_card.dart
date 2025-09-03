// lib/features/home/widgets/enhanced_tweet_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/utils/responsive_utils.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/core/models/tweet_model.dart';
import 'package:project_x/core/services/app_navigation_service.dart';
import 'package:project_x/shared/widgets/animated_counter.dart';

class EnhancedTweetCard extends StatefulWidget {
  final TweetModel tweet;
  final bool showThread;
  final int threadLevel;
  final VoidCallback? onLike;
  final VoidCallback? onRetweet;
  final VoidCallback? onReply;
  final VoidCallback? onShare;

  const EnhancedTweetCard({
    super.key,
    required this.tweet,
    this.showThread = false,
    this.threadLevel = 0,
    this.onLike,
    this.onRetweet,
    this.onReply,
    this.onShare,
  });

  @override
  State<EnhancedTweetCard> createState() => _EnhancedTweetCardState();
}

class _EnhancedTweetCardState extends State<EnhancedTweetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late bool _isLiked;
  late bool _isRetweeted;
  late int _likesCount;
  late int _retweetsCount;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _isLiked = widget.tweet.isLiked;
    _isRetweeted = widget.tweet.isRetweeted;
    _likesCount = widget.tweet.likes;
    _retweetsCount = widget.tweet.retweets;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    widget.onLike?.call();
  }

  void _handleRetweet() {
    AppNavigationService.showRetweetOptions(context, widget.tweet.id);
  }

  void _handleReply() {
    AppNavigationService.showTweetComposer(
      context,
      replyToTweetId: widget.tweet.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Column(
          children: [
            // Main tweet
            _buildTweetContent(isDark),
            
            // Nested replies if thread is shown
            if (widget.showThread && widget.tweet.replyToTweet != null)
              _buildThreadReplies(isDark),
          ],
        );
      },
    );
  }

  Widget _buildTweetContent(bool isDark) {
    final isRepost = widget.tweet.quotedTweet != null && widget.tweet.content.isEmpty;
    
    return InkWell(
      onTap: () {
        AppNavigationService.navigateToTweetDetail(widget.tweet.id);
      },
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 16 : 20)
            .copyWith(left: widget.threadLevel > 0 ? 16 + (widget.threadLevel * 40) : null),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor(isDark),
          border: Border(
            bottom: BorderSide(color: AppColors.borderColor(isDark), width: 0.5),
            left: widget.threadLevel > 0 
                ? BorderSide(color: AppColors.borderColor(isDark), width: 2) 
                : BorderSide.none,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Repost indicator
            if (isRepost) _buildRepostIndicator(isDark),
            
            // Tweet content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileImage(isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isDark),
                      const SizedBox(height: 4),
                      if (widget.tweet.content.isNotEmpty) _buildContent(isDark),
                      if (widget.tweet.mediaUrls.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildMedia(isDark),
                      ],
                      if (widget.tweet.quotedTweet != null) ...[
                        const SizedBox(height: 12),
                        _buildQuotedTweet(isDark),
                      ],
                      const SizedBox(height: 12),
                      _buildActions(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepostIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 32),
      child: Row(
        children: [
          Icon(
            Icons.repeat,
            size: 14,
            color: AppColors.textSecondary(isDark),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.tweet.author.displayName} Reposted',
            style: TextStyle(
              color: AppColors.textSecondary(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(bool isDark) {
    return GestureDetector(
      onTap: () {
        AppNavigationService.navigateToProfile(userId: widget.tweet.author.id);
      },
      child: CircleAvatar(
        radius: ResponsiveUtils.isMobile(context) ? 20 : 24,
        backgroundColor: AppColors.midGray,
        backgroundImage: widget.tweet.author.profileImageUrl != null
            ? NetworkImage(widget.tweet.author.profileImageUrl!)
            : null,
        child: widget.tweet.author.profileImageUrl == null
            ? Text(
                widget.tweet.author.displayName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            AppNavigationService.navigateToProfile(userId: widget.tweet.author.id);
          },
          child: Row(
            children: [
              Text(
                widget.tweet.author.displayName,
                style: TextStyle(
                  color: AppColors.textPrimary(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.tweet.author.isVerified) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.verified,
                  size: 16,
                  color: AppColors.blue,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '@${widget.tweet.author.username}',
          style: TextStyle(
            color: AppColors.textSecondary(isDark),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '·',
          style: TextStyle(
            color: AppColors.textSecondary(isDark),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          widget.tweet.timeAgo,
          style: TextStyle(
            color: AppColors.textSecondary(isDark),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_horiz,
            color: AppColors.textSecondary(isDark),
            size: 20,
          ),
          onSelected: (value) {
            switch (value) {
              case 'follow':
                print('Follow user');
                break;
              case 'mute':
                print('Mute user');
                break;
              case 'block':
                print('Block user');
                break;
              case 'report':
                print('Report tweet');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'follow',
              child: Row(
                children: [
                  Icon(Icons.person_add, size: 18),
                  SizedBox(width: 12),
                  Text('Follow'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(Icons.volume_off, size: 18),
                  SizedBox(width: 12),
                  Text('Mute'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 18),
                  SizedBox(width: 12),
                  Text('Block'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag, size: 18),
                  SizedBox(width: 12),
                  Text('Report'),
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
      style: TextStyle(
        color: AppColors.textPrimary(isDark),
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildMedia(bool isDark) {
    if (widget.tweet.mediaUrls.isEmpty) return const SizedBox.shrink();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: widget.tweet.mediaUrls.first,
        height: ResponsiveUtils.isMobile(context) ? 200 : 250,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: ResponsiveUtils.isMobile(context) ? 200 : 250,
          color: AppColors.surfaceColor(isDark),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.blue,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: ResponsiveUtils.isMobile(context) ? 200 : 250,
          color: AppColors.surfaceColor(isDark),
          child: Center(
            child: Icon(
              Icons.broken_image,
              color: AppColors.textSecondary(isDark),
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuotedTweet(bool isDark) {
    if (widget.tweet.quotedTweet == null) return const SizedBox.shrink();
    
    final quotedTweet = widget.tweet.quotedTweet!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor(isDark)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.midGray,
                backgroundImage: quotedTweet.author.profileImageUrl != null
                    ? NetworkImage(quotedTweet.author.profileImageUrl!)
                    : null,
                child: quotedTweet.author.profileImageUrl == null
                    ? Text(
                        quotedTweet.author.displayName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 8),
                      )
                    : null,
              ),
              const SizedBox(width: 6),
              Text(
                quotedTweet.author.displayName,
                style: TextStyle(
                  color: AppColors.textPrimary(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '@${quotedTweet.author.username}',
                style: TextStyle(
                  color: AppColors.textSecondary(isDark),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '·',
                style: TextStyle(
                  color: AppColors.textSecondary(isDark),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                quotedTweet.timeAgo,
                style: TextStyle(
                  color: AppColors.textSecondary(isDark),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            quotedTweet.content,
            style: TextStyle(
              color: AppColors.textPrimary(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          Icons.chat_bubble_outline,
          widget.tweet.replies,
          AppColors.textSecondary(isDark),
          _handleReply,
        ),
        _buildActionButton(
          Icons.repeat,
          _retweetsCount,
          _isRetweeted ? Colors.green : AppColors.textSecondary(isDark),
          _handleRetweet,
          isActive: _isRetweeted,
        ),
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildActionButton(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                _likesCount,
                _isLiked ? Colors.red : AppColors.textSecondary(isDark),
                _handleLike,
                isActive: _isLiked,
              ),
            );
          },
        ),
        _buildActionButton(
          Icons.share,
          0,
          AppColors.textSecondary(isDark),
          () {
            widget.onShare?.call();
            print('Share tweet');
          },
          showCount: false,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    int count,
    Color color,
    VoidCallback onTap, {
    bool isActive = false,
    bool showCount = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: ResponsiveUtils.isMobile(context) ? 18 : 20,
              color: color,
            ),
            if (showCount && count > 0) ...[
              const SizedBox(width: 4),
              AnimatedCounter(
                count: count,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThreadReplies(bool isDark) {
    // This would typically load replies from a data source
    // For now, showing a placeholder
    return Container(
      padding: EdgeInsets.only(
        left: 16 + ((widget.threadLevel + 1) * 40),
        right: 16,
      ),
      child: Column(
        children: [
          // Thread line
          Container(
            height: 40,
            width: 1,
            color: AppColors.borderColor(isDark),
            margin: const EdgeInsets.only(left: 20),
          ),
          // Reply placeholder
          Text(
            'Show this thread',
            style: TextStyle(
              color: AppColors.blue,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}