import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/models/tweet_model.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/features/home/widgets/enhanced_tweet_card.dart';
import 'package:project_x/features/home/widgets/tweet_reply_dialog.dart';
import 'package:project_x/features/home/viewmodels/tweet_viewmodel.dart';

class TweetDetailScreen extends StatelessWidget {
  final Tweet tweet;

  const TweetDetailScreen({
    super.key,
    required this.tweet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tweet',
          style: TextStyles.titleMedium.copyWith(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main tweet with larger text
            _buildMainTweet(context),
            Container(
              height: 0.5,
              color: AppColors.borderColor,
            ),
            // Reply composer
            _buildReplyComposer(context),
            Container(
              height: 0.5,
              color: AppColors.borderColor,
            ),
            // Replies thread
            _buildRepliesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTweet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(tweet.avatarUrl),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tweet.username,
                        style: TextStyles.titleMedium.copyWith(color: AppColors.white),
                      ),
                      if (tweet.username == 'Elon Musk' || tweet.username == 'Tech News') ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.blue,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '@${tweet.handle}',
                    style: TextStyles.bodyMedium.copyWith(color: AppColors.midGray),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // More options
                },
                icon: const Icon(Icons.more_horiz, color: AppColors.midGray),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Tweet content with larger text
          Text(
            tweet.content,
            style: TextStyles.bodyLarge.copyWith(
              color: AppColors.white,
              fontSize: 20,
              height: 1.4,
            ),
          ),
          
          // Images if any
          if (tweet.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                tweet.imageUrls.first,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: AppColors.darkGray,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: AppColors.midGray),
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Timestamp
          Text(
            '${tweet.createdAt.hour}:${tweet.createdAt.minute.toString().padLeft(2, '0')} · ${tweet.createdAt.day}/${tweet.createdAt.month}/${tweet.createdAt.year}',
            style: TextStyles.bodyMedium.copyWith(color: AppColors.midGray),
          ),
          
          const SizedBox(height: 16),
          
          // Engagement stats
          Row(
            children: [
              _buildStatItem('${tweet.retweetsCount}', 'Retweets'),
              const SizedBox(width: 20),
              _buildStatItem('${tweet.likesCount}', 'Likes'),
              const SizedBox(width: 20),
              _buildStatItem('${tweet.repliesCount}', 'Replies'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Consumer<TweetViewModel>(
            builder: (context, tweetViewModel, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    Icons.chat_bubble_outline,
                    AppColors.midGray,
                    () => _showReplyDialog(context),
                  ),
                  _buildActionButton(
                    tweet.isRetweeted ? Icons.repeat : Icons.repeat,
                    tweet.isRetweeted ? AppColors.success : AppColors.midGray,
                    () => tweetViewModel.retweetTweet(tweet.id),
                  ),
                  _buildActionButton(
                    tweet.isLiked ? Icons.favorite : Icons.favorite_border,
                    tweet.isLiked ? AppColors.error : AppColors.midGray,
                    () => tweetViewModel.likeTweet(tweet.id),
                  ),
                  _buildActionButton(
                    Icons.share_outlined,
                    AppColors.midGray,
                    () {
                      // Handle share
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: count,
            style: TextStyles.titleSmall.copyWith(color: AppColors.white),
          ),
          TextSpan(
            text: ' $label',
            style: TextStyles.bodyMedium.copyWith(color: AppColors.midGray),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildReplyComposer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _showReplyDialog(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tweet your reply',
                  style: TextStyles.bodyMedium.copyWith(color: AppColors.midGray),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesSection(BuildContext context) {
    if (tweet.replies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: tweet.replies.map((reply) => 
        EnhancedTweetCard(
          tweet: reply,
          onLike: () => Provider.of<TweetViewModel>(context, listen: false)
              .likeTweet(reply.id),
          onRetweet: () => Provider.of<TweetViewModel>(context, listen: false)
              .retweetTweet(reply.id),
          onReply: () => Provider.of<TweetViewModel>(context, listen: false)
              .addReply(reply.id, "Sample nested reply"),
          showReplies: true,
        ),
      ).toList(),
    );
  }

  void _showReplyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TweetReplyDialog(
        parentTweet: tweet,
        onReply: (content) {
          Provider.of<TweetViewModel>(context, listen: false)
              .addReply(tweet.id, content);
        },
      ),
    );
  }
}