import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/utils/responsive_utils.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/core/services/app_navigation_service.dart';
import 'package:project_x/shared/widgets/animated_counter.dart';

class TweetCard extends StatefulWidget {
  final String username;
  final String handle;
  final String content;
  final String time;
  final int likes;
  final int retweets;
  final int replies;
  final String? imageUrl;
  final bool isLiked;
  final bool isRetweeted;
  final VoidCallback? onLike;
  final VoidCallback? onRetweet;
  final VoidCallback? onReply;
  final VoidCallback? onShare;

  const TweetCard({
    super.key,
    required this.username,
    required this.handle,
    required this.content,
    required this.time,
    required this.likes,
    required this.retweets,
    required this.replies,
    this.imageUrl,
    this.isLiked = false,
    this.isRetweeted = false,
    this.onLike,
    this.onRetweet,
    this.onReply,
    this.onShare,
  });

  @override
  State<TweetCard> createState() => _TweetCardState();
}

class _TweetCardState extends State<TweetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;
  bool _isRetweeted = false;
  int _likesCount = 0;
  int _retweetsCount = 0;

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

    _isLiked = widget.isLiked;
    _isRetweeted = widget.isRetweeted;
    _likesCount = widget.likes;
    _retweetsCount = widget.retweets;
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
    setState(() {
      _isRetweeted = !_isRetweeted;
      _retweetsCount += _isRetweeted ? 1 : -1;
    });
    
    widget.onRetweet?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return InkWell(
          onTap: () {
            // Navigate to tweet detail with a mock tweet ID
            AppNavigationService.navigateToTweetDetail('${widget.handle}_${widget.time}');
          },
          child: Container(
            padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 16 : 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderColor(isDark), width: 0.5),
              ),
            ),
            child: Row(
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
                      _buildContent(isDark),
                      if (widget.imageUrl != null) ...[
                        const SizedBox(height: 12),
                        _buildImage(isDark),
                      ],
                      const SizedBox(height: 12),
                      _buildActions(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(bool isDark) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to user profile
        print('Tapped profile: ${widget.handle}');
      },
      child: CircleAvatar(
        radius: ResponsiveUtils.isMobile(context) ? 20 : 24,
        backgroundColor: AppColors.midGray,
        child: Text(
          widget.username[0].toUpperCase(),
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // TODO: Navigate to user profile
            print('Tapped username: ${widget.handle}');
          },
          child: Text(
            widget.username,
            style: TextStyle(
              color: AppColors.textPrimary(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '@${widget.handle}',
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
          widget.time,
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
      widget.content,
      style: TextStyle(
        color: AppColors.textPrimary(isDark),
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        height: ResponsiveUtils.isMobile(context) ? 200 : 250,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: ResponsiveUtils.isMobile(context) ? 200 : 250,
          color: AppColors.darkGray,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.blue,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: ResponsiveUtils.isMobile(context) ? 200 : 250,
          color: AppColors.darkGray,
          child: Icon(
            Icons.broken_image,
            color: AppColors.textSecondary(isDark),
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          Icons.chat_bubble_outline,
          widget.replies,
          AppColors.textSecondary(isDark),
          () {
            widget.onReply?.call();
            print('Reply to tweet');
          },
          isDark,
        ),
        _buildActionButton(
          Icons.repeat,
          _retweetsCount,
          _isRetweeted ? Colors.green : AppColors.textSecondary(isDark),
          _handleRetweet,
          isDark,
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
                isDark,
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
          isDark,
          showCount: false,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    int count,
    Color color,
    VoidCallback onTap,
    bool isDark, {
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
}