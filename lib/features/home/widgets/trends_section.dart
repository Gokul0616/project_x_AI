import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';

class TrendsSection extends StatelessWidget {
  const TrendsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'What\'s happening',
              style: TextStyles.titleMedium.copyWith(color: AppColors.white),
            ),
          ),
          _buildTrendItem('Technology', 'Flutter 3.19 released', '25.3K Tweets'),
          _buildTrendItem('Trending in Technology', 'OpenAI ChatGPT', '45.2K Tweets'),
          _buildTrendItem('Trending', 'Space X Launch', '12.8K Tweets'),
          _buildTrendItem('Programming', 'Dart Language', '8.1K Tweets'),
          _buildTrendItem('Mobile Development', 'React Native vs Flutter', '15.7K Tweets'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Show more',
              style: TextStyles.bodyMedium.copyWith(color: AppColors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String category, String title, String tweetCount) {
    return InkWell(
      onTap: () {
        // Handle trend tap
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyles.titleSmall.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 2),
            Text(
              tweetCount,
              style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
            ),
          ],
        ),
      ),
    );
  }
}