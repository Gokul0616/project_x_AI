import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/theme/theme_provider.dart';
import 'package:project_x/core/models/tweet_model.dart';
import 'package:project_x/features/home/widgets/enhanced_tweet_composer.dart';
import 'package:provider/provider.dart';

class RetweetDialog extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback onRetweet;
  final Function(String, {List<String> mediaUrls, Tweet? quoteTweet}) onQuoteTweet;

  const RetweetDialog({
    super.key,
    required this.tweet,
    required this.onRetweet,
    required this.onQuoteTweet,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor(isDark),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Retweet Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.repeat,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Retweet',
                  style: TextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                subtitle: Text(
                  'Share instantly',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onRetweet();
                },
              ),
              
              const SizedBox(height: 8),
              
              // Quote Tweet Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColors.blue,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Quote Tweet',
                  style: TextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                subtitle: Text(
                  'Add a comment',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showQuoteTweetComposer(context);
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showQuoteTweetComposer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedTweetComposer(
        quoteTweet: tweet,
        onTweet: onQuoteTweet,
      ),
    );
  }
}

class RetweetButton extends StatefulWidget {
  final Tweet tweet;
  final VoidCallback onRetweet;
  final Function(String, {List<String> mediaUrls, Tweet? quoteTweet}) onQuoteTweet;

  const RetweetButton({
    super.key,
    required this.tweet,
    required this.onRetweet,
    required this.onQuoteTweet,
  });

  @override
  State<RetweetButton> createState() => _RetweetButtonState();
}

class _RetweetButtonState extends State<RetweetButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
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
        
        return InkWell(
          onTap: _showRetweetDialog,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Icon(
                        widget.tweet.isRetweeted ? Icons.repeat : Icons.repeat,
                        size: 18,
                        color: widget.tweet.isRetweeted 
                            ? AppColors.success 
                            : AppColors.textSecondary(isDark),
                      ),
                    );
                  },
                ),
                if (widget.tweet.retweetsCount > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(widget.tweet.retweetsCount),
                    style: TextStyles.bodySmall.copyWith(
                      color: widget.tweet.isRetweeted 
                          ? AppColors.success 
                          : AppColors.textSecondary(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRetweetDialog() {
    if (widget.tweet.isRetweeted) {
      // If already retweeted, just unretweet
      _animateButton();
      widget.onRetweet();
    } else {
      // Show retweet options
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => RetweetDialog(
          tweet: widget.tweet,
          onRetweet: () {
            _animateButton();
            widget.onRetweet();
          },
          onQuoteTweet: widget.onQuoteTweet,
        ),
      );
    }
  }

  void _animateButton() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
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