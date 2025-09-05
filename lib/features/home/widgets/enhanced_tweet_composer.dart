import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/theme/theme_provider.dart';
import 'package:project_x/core/services/media_service.dart';
import 'package:project_x/core/models/tweet_model.dart';
import 'package:provider/provider.dart';

class EnhancedTweetComposer extends StatefulWidget {
  final Function(String, {List<String> mediaUrls, Tweet? quoteTweet}) onTweet;
  final Tweet? replyToTweet;
  final Tweet? quoteTweet;

  const EnhancedTweetComposer({
    super.key,
    required this.onTweet,
    this.replyToTweet,
    this.quoteTweet,
  });

  @override
  State<EnhancedTweetComposer> createState() => _EnhancedTweetComposerState();
}

class _EnhancedTweetComposerState extends State<EnhancedTweetComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _characterCount = 0;
  static const int _maxCharacters = 280;
  
  List<MediaItem> _selectedMedia = [];
  bool _isUploading = false;

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor(isDark),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, isDark),
              if (widget.replyToTweet != null) _buildReplyContext(isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildComposer(isDark),
                ),
              ),
              if (_selectedMedia.isNotEmpty) _buildMediaPreview(isDark),
              if (widget.quoteTweet != null) _buildQuoteTweetPreview(isDark),
              _buildBottomBar(context, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor(isDark), 
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close, 
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const Spacer(),
          Text(
            _getHeaderTitle(),
            style: TextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const Spacer(),
          _buildActionButton(isDark),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    return ElevatedButton(
      onPressed: (_canTweet() && !_isUploading) ? _handleTweet : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.blueDisabled,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: _isUploading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            )
          : Text(
              _getActionButtonText(),
              style: TextStyles.buttonMedium.copyWith(fontSize: 14),
            ),
    );
  }

  Widget _buildReplyContext(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark).withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor(isDark),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 16,
            color: AppColors.textSecondary(isDark),
          ),
          const SizedBox(width: 8),
          Text(
            'Replying to @${widget.replyToTweet!.handle}',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
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
                  hintText: _getHintText(),
                  hintStyle: TextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  counterText: '', // Hide the default counter
                ),
                style: TextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary(isDark),
                  fontSize: 20,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _selectedMedia.length,
          itemBuilder: (context, index) {
            final media = _selectedMedia[index];
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderColor(isDark),
                        width: 0.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: MediaService.isImage(media.path)
                          ? Image.file(
                              File(media.path),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 120,
                              height: 120,
                              color: AppColors.surfaceColor(isDark),
                              child: Icon(
                                Icons.videocam,
                                size: 40,
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                    ),
                  ),
                  if (media.isUploading)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: media.uploadProgress,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.blue,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeMedia(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuoteTweetPreview(bool isDark) {
    if (widget.quoteTweet == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.borderColor(isDark),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(widget.quoteTweet!.avatarUrl),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.quoteTweet!.username} @${widget.quoteTweet!.handle}',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.quoteTweet!.content,
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary(isDark),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor(isDark), 
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: _selectedMedia.length < 4 ? () => _showMediaOptions(context, isDark) : null,
              icon: Icon(
                Icons.image_outlined, 
                color: _selectedMedia.length < 4 
                    ? AppColors.blue 
                    : AppColors.textSecondary(isDark),
              ),
            ),
            IconButton(
              onPressed: _selectedMedia.isEmpty ? () => _showVideoOptions(context, isDark) : null,
              icon: Icon(
                Icons.videocam_outlined,
                color: _selectedMedia.isEmpty 
                    ? AppColors.blue 
                    : AppColors.textSecondary(isDark),
              ),
            ),
            IconButton(
              onPressed: () => _showPollDialog(context, isDark),
              icon: Icon(
                Icons.poll_outlined, 
                color: AppColors.blue,
              ),
            ),
            IconButton(
              onPressed: () => _showLocationDialog(context, isDark),
              icon: Icon(
                Icons.location_on_outlined, 
                color: AppColors.blue,
              ),
            ),
            const Spacer(),
            _buildCharacterCounter(isDark),
            const SizedBox(width: 16),
            _buildTweetButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterCounter(bool isDark) {
    final remaining = _maxCharacters - _characterCount;
    final color = remaining < 20
        ? AppColors.error
        : remaining < 50
            ? AppColors.warning
            : AppColors.textSecondary(isDark);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: _characterCount / _maxCharacters,
            strokeWidth: 2,
            backgroundColor: AppColors.borderColor(isDark),
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

  Widget _buildTweetButton(bool isDark) {
    return ElevatedButton(
      onPressed: (_canTweet() && !_isUploading) ? _handleTweet : null,
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
        _getActionButtonText(),
        style: TextStyles.buttonMedium,
      ),
    );
  }

  String _getHeaderTitle() {
    if (widget.replyToTweet != null) return 'Reply';
    if (widget.quoteTweet != null) return 'Quote Tweet';
    return 'Compose Tweet';
  }

  String _getActionButtonText() {
    if (widget.replyToTweet != null) return 'Reply';
    if (widget.quoteTweet != null) return 'Quote';
    return 'Tweet';
  }

  String _getHintText() {
    if (widget.replyToTweet != null) return 'Tweet your reply';
    if (widget.quoteTweet != null) return 'Add a comment';
    return "What's happening?";
  }

  bool _canTweet() {
    return _controller.text.trim().isNotEmpty && 
           _characterCount <= _maxCharacters;
  }

  void _handleTweet() async {
    if (_canTweet() && !_isUploading) {
      setState(() {
        _isUploading = true;
      });

      try {
        List<String> mediaUrls = [];
        
        if (_selectedMedia.isNotEmpty) {
          final files = _selectedMedia.map((media) => File(media.path)).toList();
          mediaUrls = await MediaService.uploadMultipleMedia(files);
        }

        widget.onTweet(
          _controller.text.trim(),
          mediaUrls: mediaUrls,
          quoteTweet: widget.quoteTweet,
        );
        
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  void _showMediaOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor(isDark),
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
              leading: Icon(
                Icons.photo_library, 
                color: AppColors.blue,
              ),
              title: Text(
                'Photo Library',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_camera, 
                color: AppColors.blue,
              ),
              title: Text(
                'Camera',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor(isDark),
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
              leading: Icon(
                Icons.videocam, 
                color: AppColors.blue,
              ),
              title: Text(
                'Record Video',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _captureVideo();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.video_library, 
                color: AppColors.blue,
              ),
              title: Text(
                'Video Library',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPollDialog(BuildContext context, bool isDark) {
    // Placeholder for poll functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Poll feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showLocationDialog(BuildContext context, bool isDark) {
    // Placeholder for location functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _pickImages() async {
    try {
      final files = await MediaService.pickImages(maxImages: 4 - _selectedMedia.length);
      
      for (final file in files) {
        final mediaItem = MediaItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          path: file.path,
          type: 'image',
          size: await file.length(),
        );
        
        setState(() {
          _selectedMedia.add(mediaItem);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick images: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _captureImage() async {
    try {
      final file = await MediaService.captureImage();
      
      if (file != null) {
        final mediaItem = MediaItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          path: file.path,
          type: 'image',
          size: await file.length(),
        );
        
        setState(() {
          _selectedMedia.add(mediaItem);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _pickVideo() async {
    try {
      final file = await MediaService.pickVideo();
      
      if (file != null) {
        final mediaItem = MediaItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          path: file.path,
          type: 'video',
          size: await file.length(),
        );
        
        setState(() {
          _selectedMedia = [mediaItem]; // Only one video allowed
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick video: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _captureVideo() async {
    try {
      final file = await MediaService.captureVideo();
      
      if (file != null) {
        final mediaItem = MediaItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          path: file.path,
          type: 'video',
          size: await file.length(),
        );
        
        setState(() {
          _selectedMedia = [mediaItem]; // Only one video allowed
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture video: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}