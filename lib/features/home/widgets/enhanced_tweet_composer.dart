// lib/features/home/widgets/enhanced_tweet_composer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/utils/responsive_utils.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/core/models/tweet_model.dart';

enum ComposerType { tweet, reply, quote }

class EnhancedTweetComposer extends StatefulWidget {
  final Function(String, {String? replyToTweetId, String? quoteTweetId}) onTweet;
  final ComposerType type;
  final TweetModel? replyToTweet;
  final TweetModel? quoteTweet;

  const EnhancedTweetComposer({
    super.key,
    required this.onTweet,
    this.type = ComposerType.tweet,
    this.replyToTweet,
    this.quoteTweet,
  });

  @override
  State<EnhancedTweetComposer> createState() => _EnhancedTweetComposerState();
}

class _EnhancedTweetComposerState extends State<EnhancedTweetComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  int _characterCount = 0;
  final int _maxCharacters = 280;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    
    // Pre-fill for replies
    if (widget.type == ComposerType.reply && widget.replyToTweet != null) {
      final mentions = widget.replyToTweet!.mentions.isNotEmpty 
          ? widget.replyToTweet!.mentions.map((m) => '@$m').join(' ')
          : '@${widget.replyToTweet!.author.username}';
      _controller.text = '$mentions ';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
      _characterCount = _controller.text.length;
    });
  }

  void _sendTweet() {
    if (_hasText && _characterCount <= _maxCharacters) {
      switch (widget.type) {
        case ComposerType.reply:
          widget.onTweet(
            _controller.text.trim(),
            replyToTweetId: widget.replyToTweet?.id,
          );
          break;
        case ComposerType.quote:
          widget.onTweet(
            _controller.text.trim(),
            quoteTweetId: widget.quoteTweet?.id,
          );
          break;
        case ComposerType.tweet:
        default:
          widget.onTweet(_controller.text.trim());
          break;
      }
      _controller.clear();
      if (ResponsiveUtils.isMobile(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final remainingCharacters = _maxCharacters - _characterCount;
        final isOverLimit = remainingCharacters < 0;
        
        return Container(
          padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 16 : 20),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor(isDark),
            border: ResponsiveUtils.isLargeScreen(context)
                ? Border(
                    bottom: BorderSide(color: AppColors.borderColor(isDark), width: 0.5),
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ResponsiveUtils.isMobile(context)) _buildMobileHeader(isDark, isOverLimit),
              if (widget.type == ComposerType.reply) _buildReplyContext(isDark),
              _buildComposerContent(isDark),
              if (widget.type == ComposerType.quote) _buildQuoteContext(isDark),
              if (ResponsiveUtils.isLargeScreen(context)) _buildDesktopActions(isDark, isOverLimit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileHeader(bool isDark, bool isOverLimit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary(isDark)),
            ),
          ),
          Text(
            _getHeaderTitle(),
            style: TextStyle(
              color: AppColors.textPrimary(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          ElevatedButton(
            onPressed: _hasText && !isOverLimit ? _sendTweet : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: Text(_getButtonText()),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyContext(bool isDark) {
    if (widget.replyToTweet == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.midGray,
            child: Text(
              widget.replyToTweet!.author.displayName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.replyToTweet!.author.displayName,
                      style: TextStyle(
                        color: AppColors.textPrimary(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '@${widget.replyToTweet!.author.username}',
                      style: TextStyle(
                        color: AppColors.textSecondary(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.replyToTweet!.content,
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposerContent(bool isDark) {
    final remainingCharacters = _maxCharacters - _characterCount;
    final isOverLimit = remainingCharacters < 0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://via.placeholder.com/48'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  color: AppColors.textPrimary(isDark),
                  fontSize: 18,
                  height: 1.4,
                ),
                maxLines: ResponsiveUtils.isMobile(context) ? 6 : null,
                decoration: InputDecoration(
                  hintText: _getHintText(),
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) {
                  if (_hasText && !isOverLimit) {
                    _sendTweet();
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildActionRow(remainingCharacters, isOverLimit, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteContext(bool isDark) {
    if (widget.quoteTweet == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor(isDark)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.midGray,
            child: Text(
              widget.quoteTweet!.author.displayName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.quoteTweet!.author.displayName,
                      style: TextStyle(
                        color: AppColors.textPrimary(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '@${widget.quoteTweet!.author.username}',
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
                      widget.quoteTweet!.timeAgo,
                      style: TextStyle(
                        color: AppColors.textSecondary(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.quoteTweet!.content,
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(int remainingCharacters, bool isOverLimit, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildActionButton(
              icon: Icons.image,
              isDark: isDark,
              onPressed: () {
                print('Add image');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.gif_box,
              isDark: isDark,
              onPressed: () {
                print('Add GIF');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.poll,
              isDark: isDark,
              onPressed: () {
                print('Create poll');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.emoji_emotions,
              isDark: isDark,
              onPressed: () {
                print('Add emoji');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.schedule,
              isDark: isDark,
              onPressed: () {
                print('Schedule tweet');
              },
            ),
          ],
        ),
        Row(
          children: [
            if (_characterCount > 0) ...[
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: _characterCount / _maxCharacters,
                      strokeWidth: 2,
                      backgroundColor: AppColors.borderColor(isDark),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverLimit
                            ? AppColors.error
                            : remainingCharacters <= 20
                                ? AppColors.warning
                                : AppColors.blue,
                      ),
                    ),
                  ),
                  if (remainingCharacters <= 20)
                    Text(
                      remainingCharacters.toString(),
                      style: TextStyles.caption.copyWith(
                        color: isOverLimit
                            ? AppColors.error
                            : AppColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
            ],
            if (!ResponsiveUtils.isMobile(context))
              ElevatedButton(
                onPressed: _hasText && !isOverLimit ? _sendTweet : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                ),
                child: Text(_getButtonText()),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopActions(bool isDark, bool isOverLimit) {
    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.blue,
        ),
      ),
    );
  }

  String _getHeaderTitle() {
    switch (widget.type) {
      case ComposerType.reply:
        return 'Reply';
      case ComposerType.quote:
        return 'Quote Tweet';
      case ComposerType.tweet:
      default:
        return 'Tweet';
    }
  }

  String _getButtonText() {
    switch (widget.type) {
      case ComposerType.reply:
        return 'Reply';
      case ComposerType.quote:
        return 'Quote Tweet';
      case ComposerType.tweet:
      default:
        return 'Post';
    }
  }

  String _getHintText() {
    switch (widget.type) {
      case ComposerType.reply:
        return 'Post your reply';
      case ComposerType.quote:
        return 'Add a comment';
      case ComposerType.tweet:
      default:
        return "What's happening?";
    }
  }
}