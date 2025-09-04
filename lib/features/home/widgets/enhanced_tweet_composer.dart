import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';

class EnhancedTweetComposer extends StatefulWidget {
  final Function(String) onTweet;

  const EnhancedTweetComposer({
    super.key,
    required this.onTweet,
  });

  @override
  State<EnhancedTweetComposer> createState() => _EnhancedTweetComposerState();
}

class _EnhancedTweetComposerState extends State<EnhancedTweetComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _characterCount = 0;
  static const int _maxCharacters = 280;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateCharacterCount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCharacterCount);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _controller.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildComposer(),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.white),
          ),
          const Spacer(),
          Text(
            'Compose Tweet',
            style: TextStyles.titleMedium.copyWith(color: AppColors.white),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _canTweet() ? _handleTweet : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.blueDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: Text(
              'Tweet',
              style: TextStyles.buttonMedium.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                maxLength: _maxCharacters,
                decoration: InputDecoration(
                  hintText: "What's happening?",
                  hintStyle: TextStyles.bodyLarge.copyWith(
                    color: AppColors.midGray,
                    fontSize: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  counterText: '', // Hide the default counter
                ),
                style: TextStyles.bodyLarge.copyWith(
                  color: AppColors.white,
                  fontSize: 20,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildMediaPreview(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreview() {
    // Placeholder for media preview
    // This would show selected images, videos, etc.
    return const SizedBox.shrink();
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Add image functionality
              _showMediaOptions(context);
            },
            icon: const Icon(Icons.image_outlined, color: AppColors.blue),
          ),
          IconButton(
            onPressed: () {
              // Add GIF functionality
            },
            icon: const Icon(Icons.gif_box_outlined, color: AppColors.blue),
          ),
          IconButton(
            onPressed: () {
              // Add poll functionality
            },
            icon: const Icon(Icons.poll_outlined, color: AppColors.blue),
          ),
          IconButton(
            onPressed: () {
              // Add location functionality
            },
            icon: const Icon(Icons.location_on_outlined, color: AppColors.blue),
          ),
          const Spacer(),
          _buildCharacterCounter(),
          const SizedBox(width: 16),
          _buildTweetButton(),
        ],
      ),
    );
  }

  Widget _buildCharacterCounter() {
    final remaining = _maxCharacters - _characterCount;
    final color = remaining < 20
        ? AppColors.error
        : remaining < 50
            ? AppColors.warning
            : AppColors.midGray;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: _characterCount / _maxCharacters,
            strokeWidth: 2,
            backgroundColor: AppColors.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (remaining < 20)
          Text(
            remaining.toString(),
            style: TextStyles.caption.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildTweetButton() {
    return ElevatedButton(
      onPressed: _canTweet() ? _handleTweet : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.blueDisabled,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      child: Text(
        'Tweet',
        style: TextStyles.buttonMedium,
      ),
    );
  }

  bool _canTweet() {
    return _controller.text.trim().isNotEmpty && 
           _characterCount <= _maxCharacters;
  }

  void _handleTweet() {
    if (_canTweet()) {
      widget.onTweet(_controller.text.trim());
      Navigator.pop(context);
    }
  }

  void _showMediaOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.blue),
              title: Text(
                'Photo Library',
                style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle photo library selection
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: AppColors.blue),
              title: Text(
                'Camera',
                style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle camera capture
              },
            ),
          ],
        ),
      ),
    );
  }
}