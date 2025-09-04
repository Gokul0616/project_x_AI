// lib/features/tweets/tweet_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/features/home/widgets/tweet_card.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/core/services/app_navigation_service.dart';

class TweetDetailScreen extends StatefulWidget {
  final String tweetId;

  const TweetDetailScreen({super.key, required this.tweetId});

  @override
  State<TweetDetailScreen> createState() => _TweetDetailScreenState();
}

class _TweetDetailScreenState extends State<TweetDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor(isDark),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary(isDark),
              ),
              onPressed: () => AppNavigationService.goBack(),
            ),
            title: Text(
              'Post',
              style: TextStyle(
                color: AppColors.textPrimary(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
          ),
          body: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  color: AppColors.blue,
                  backgroundColor: AppColors.cardColor(isDark),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Main Tweet
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildMainTweet(isDark),
                        ),
                      ),

                      // Divider
                      SliverToBoxAdapter(
                        child: Container(
                          height: 1,
                          color: AppColors.borderColor(isDark),
                        ),
                      ),

                      // Reply Input
                      SliverToBoxAdapter(
                        child: _buildReplyInput(isDark),
                      ),

                      // Divider
                      SliverToBoxAdapter(
                        child: Container(
                          height: 8,
                          color: AppColors.surfaceColor(isDark),
                        ),
                      ),

                      // Replies Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Replies',
                            style: TextStyle(
                              color: AppColors.textPrimary(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Replies List
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildReplyTweet(index, isDark);
                          },
                          childCount: 5, // Mock replies
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainTweet(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User info
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                'https://via.placeholder.com/48',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          color: AppColors.textPrimary(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        color: AppColors.blue,
                        size: 16,
                      ),
                    ],
                  ),
                  Text(
                    '@johndoe',
                    style: TextStyle(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: AppColors.textSecondary(isDark),
              ),
              onPressed: () => _showTweetOptions(context),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Tweet content
        Text(
          'This is the main tweet content that we are viewing in detail. It can be longer and contain more information about the topic being discussed.',
          style: TextStyle(
            color: AppColors.textPrimary(isDark),
            fontSize: 18,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 16),

        // Tweet image (if any)
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://via.placeholder.com/400x200',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 16),

        // Tweet time and date
        Text(
          '2:34 PM · Jan 15, 2024',
          style: TextStyle(
            color: AppColors.textSecondary(isDark),
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 16),

        // Divider
        Container(
          height: 1,
          color: AppColors.borderColor(isDark),
        ),

        const SizedBox(height: 16),

        // Engagement stats
        Row(
          children: [
            _buildStatItem('24', 'Retweets', isDark),
            const SizedBox(width: 24),
            _buildStatItem('5', 'Quote Tweets', isDark),
            const SizedBox(width: 24),
            _buildStatItem('128', 'Likes', isDark),
          ],
        ),

        const SizedBox(height: 16),

        // Divider
        Container(
          height: 1,
          color: AppColors.borderColor(isDark),
        ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(Icons.chat_bubble_outline, isDark, () {
              _replyFocusNode.requestFocus();
            }),
            _buildActionButton(Icons.repeat, isDark, () {}),
            _buildActionButton(Icons.favorite_border, isDark, () {}),
            _buildActionButton(Icons.share_outlined, isDark, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label, bool isDark) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: count,
            style: TextStyle(
              color: AppColors.textPrimary(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: TextStyle(
              color: AppColors.textSecondary(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: AppColors.textSecondary(isDark),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildReplyInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              'https://via.placeholder.com/32',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _replyController,
                  focusNode: _replyFocusNode,
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Post your reply',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                  minLines: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: AppColors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.gif_box_outlined,
                          color: AppColors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.poll_outlined,
                          color: AppColors.blue,
                          size: 20,
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_replyController.text.trim().isNotEmpty) {
                          // Handle reply
                          _replyController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Reply posted!'),
                              backgroundColor: AppColors.blue,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyTweet(int index, bool isDark) {
    final replies = [
      {
        'username': 'Alice Johnson',
        'handle': 'alicejohnson',
        'content': 'Great post! Really insightful thoughts on this topic.',
        'time': '1h',
        'likes': 12,
        'retweets': 2,
        'replies': 1,
      },
      {
        'username': 'Bob Wilson',
        'handle': 'bobwilson',
        'content': 'I completely agree with your perspective here. Thanks for sharing!',
        'time': '45m',
        'likes': 8,
        'retweets': 0,
        'replies': 0,
      },
      {
        'username': 'Sarah Davis',
        'handle': 'sarahdavis',
        'content': 'This is exactly what I was thinking about earlier today. Perfect timing!',
        'time': '30m',
        'likes': 15,
        'retweets': 3,
        'replies': 2,
      },
      {
        'username': 'Mike Chen',
        'handle': 'mikechen',
        'content': 'Interesting point. I have a slightly different view on this matter though.',
        'time': '20m',
        'likes': 6,
        'retweets': 1,
        'replies': 0,
      },
      {
        'username': 'Emma Brown',
        'handle': 'emmabrown',
        'content': 'Thanks for breaking this down so clearly. Really helpful!',
        'time': '10m',
        'likes': 4,
        'retweets': 0,
        'replies': 0,
      },
    ];

    if (index >= replies.length) return const SizedBox.shrink();

    final reply = replies[index];
    
    return TweetCard(
      username: reply['username'] as String,
      handle: reply['handle'] as String,
      content: reply['content'] as String,
      time: reply['time'] as String,
      likes: reply['likes'] as int,
      retweets: reply['retweets'] as int,
      replies: reply['replies'] as int,
    );
  }

  void _showTweetOptions(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.link,
                color: AppColors.textPrimary(isDark),
              ),
              title: Text(
                'Copy link to post',
                style: TextStyle(color: AppColors.textPrimary(isDark)),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(
                Icons.share,
                color: AppColors.textPrimary(isDark),
              ),
              title: Text(
                'Share post via...',
                style: TextStyle(color: AppColors.textPrimary(isDark)),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(
                Icons.bookmark_border,
                color: AppColors.textPrimary(isDark),
              ),
              title: Text(
                'Bookmark',
                style: TextStyle(color: AppColors.textPrimary(isDark)),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(
                Icons.report_outlined,
                color: AppColors.error,
              ),
              title: Text(
                'Report post',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}