// lib/features/home/widgets/tweet_composer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/utils/responsive_utils.dart';
import 'package:project_x/core/providers/theme_provider.dart';

class TweetComposer extends StatefulWidget {
  final Function(String) onTweet;

  const TweetComposer({super.key, required this.onTweet});

  @override
  State<TweetComposer> createState() => _TweetComposerState();
}

class _TweetComposerState extends State<TweetComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  int _characterCount = 0;
  final int _maxCharacters = 280;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
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
      widget.onTweet(_controller.text.trim());
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
            color: Theme.of(context).colorScheme.surface,
            border: ResponsiveUtils.isLargeScreen(context)
                ? Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 0.5,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ResponsiveUtils.isMobile(context)) _buildMobileHeader(isDark),
              _buildComposerContent(isDark),
              if (ResponsiveUtils.isLargeScreen(context)) _buildDesktopActions(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileHeader(bool isDark) {
    final remainingCharacters = _maxCharacters - _characterCount;
    final isOverLimit = remainingCharacters < 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Text(
            'Tweet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          ElevatedButton(
            onPressed: _hasText && !isOverLimit ? _sendTweet : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text('Post'),
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
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(
                  height: 1.4,
                ),
                maxLines: ResponsiveUtils.isMobile(context) ? 6 : null,
                decoration: InputDecoration(
                  hintText: "What's happening?",
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildActionRow(int remainingCharacters, bool isOverLimit, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildActionButton(
              icon: Icons.image,
              onPressed: () {
                // TODO: Implement image picker
                print('Add image');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.gif_box,
              onPressed: () {
                // TODO: Implement GIF picker
                print('Add GIF');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.poll,
              onPressed: () {
                // TODO: Implement poll creation
                print('Create poll');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.emoji_emotions,
              onPressed: () {
                // TODO: Implement emoji picker
                print('Add emoji');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.schedule,
              onPressed: () {
                // TODO: Implement schedule tweet
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
                      backgroundColor: Theme.of(context).colorScheme.outline,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverLimit
                            ? Theme.of(context).colorScheme.error
                            : remainingCharacters <= 20
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  if (remainingCharacters <= 20)
                    Text(
                      remainingCharacters.toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isOverLimit
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
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
                child: const Text('Tweet'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopActions(bool isDark) {
    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required IconData icon,
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
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}