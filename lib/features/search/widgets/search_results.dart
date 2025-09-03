import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/features/home/widgets/tweet_card.dart';

class SearchResults extends StatelessWidget {
  final String query;
  final int selectedTab;

  const SearchResults({
    super.key,
    required this.query,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return SingleChildScrollView(
          child: Column(
            children: [
              if (query.isNotEmpty) _buildSearchHeader(isDark),
              _buildResults(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppColors.textSecondary(isDark),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search results for "$query"',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    switch (selectedTab) {
      case 0: // Top
        return _buildTopResults(isDark);
      case 1: // Latest
        return _buildLatestResults(isDark);
      case 2: // People
        return _buildPeopleResults(isDark);
      case 3: // Media
        return _buildMediaResults(isDark);
      default:
        return _buildTopResults(isDark);
    }
  }

  Widget _buildTopResults(bool isDark) {
    return Column(
      children: [
        _buildSampleTweet(isDark),
        _buildSampleUser(isDark),
        _buildSampleTweet(isDark),
        _buildSampleUser(isDark),
      ],
    );
  }

  Widget _buildLatestResults(bool isDark) {
    return Column(
      children: List.generate(
        5,
        (index) => _buildSampleTweet(isDark),
      ),
    );
  }

  Widget _buildPeopleResults(bool isDark) {
    return Column(
      children: List.generate(
        8,
        (index) => _buildSampleUser(isDark),
      ),
    );
  }

  Widget _buildMediaResults(bool isDark) {
    return Column(
      children: List.generate(
        4,
        (index) => const TweetCard(
          username: "Media User",
          handle: "mediauser",
          content: "Check out this amazing content!",
          time: "2h",
          likes: 45,
          retweets: 12,
          replies: 8,
          imageUrl: "https://via.placeholder.com/500x300",
        ),
      ),
    );
  }

  Widget _buildSampleTweet(bool isDark) {
    return TweetCard(
      username: "Search Result",
      handle: "searchresult",
      content: "This tweet contains the search term: $query",
      time: "1h",
      likes: 23,
      retweets: 5,
      replies: 2,
    );
  }

  Widget _buildSampleUser(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor(isDark), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.midGray,
            child: Text(
              query.isNotEmpty ? query[0].toUpperCase() : 'U',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$query User',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${query.toLowerCase()}user',
                  style: TextStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Bio related to $query and other interesting topics.',
                  style: TextStyles.bodySmall,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Follow'),
          ),
        ],
      ),
    );
  }
}