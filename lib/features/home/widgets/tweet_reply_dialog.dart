import 'package:flutter/material.dart';
import 'package:project_x/core/models/tweet_model.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';

class TweetReplyDialog extends StatefulWidget {
  final Tweet parentTweet;
  final Function(String) onReply;

  const TweetReplyDialog({
    super.key,
    required this.parentTweet,
    required this.onReply,
  });

  @override
  State<TweetReplyDialog> createState() => _TweetReplyDialogState();
}

class _TweetReplyDialogState extends State<TweetReplyDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParentTweet(),
                  const SizedBox(height: 16),
                  _buildReplyComposer(),
                ],
              ),
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
            'Reply',
            style: TextStyles.titleMedium.copyWith(color: AppColors.white),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildParentTweet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(widget.parentTweet.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.parentTweet.username,
                      style: TextStyles.titleSmall.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '@${widget.parentTweet.handle}',
                      style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.parentTweet.content,
                  style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyComposer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Replying to @${widget.parentTweet.handle}',
          style: TextStyles.bodySmall.copyWith(color: AppColors.blue),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Tweet your reply',
                  hintStyle: TextStyles.bodyLarge.copyWith(color: AppColors.midGray),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyles.bodyLarge.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
      ],
    );
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
              // Add image functionality later
            },
            icon: const Icon(Icons.image_outlined, color: AppColors.blue),
          ),
          IconButton(
            onPressed: () {
              // Add GIF functionality later
            },
            icon: const Icon(Icons.gif_box_outlined, color: AppColors.blue),
          ),
          IconButton(
            onPressed: () {
              // Add poll functionality later
            },
            icon: const Icon(Icons.poll_outlined, color: AppColors.blue),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _controller.text.trim().isEmpty
                ? null
                : () => widget.onReply(_controller.text.trim()),
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
              'Reply',
              style: TextStyles.buttonMedium,
            ),
          ),
        ],
      ),
    );
  }
}