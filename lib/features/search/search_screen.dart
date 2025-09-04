import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSearchAppBar(),
      body: _isSearching ? _buildSearchResults() : _buildTrending(),
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor, width: 0.5),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search Twitter',
            hintStyle: TextStyles.bodyMedium.copyWith(color: AppColors.midGray),
            prefixIcon: const Icon(Icons.search, color: AppColors.midGray),
            suffixIcon: _isSearching
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.midGray),
                    onPressed: () {
                      _searchController.clear();
                      _focusNode.unfocus();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildTrending() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending for you',
            style: TextStyles.titleLarge.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 16),
          _buildTrendingSection(),
        ],
      ),
    );
  }

  Widget _buildTrendingSection() {
    final trends = [
      {'category': 'Trending in Technology', 'title': 'Flutter 3.19', 'tweets': '25.3K'},
      {'category': 'Technology', 'title': 'OpenAI ChatGPT', 'tweets': '45.2K'},
      {'category': 'Trending', 'title': 'Space X Launch', 'tweets': '12.8K'},
      {'category': 'Programming', 'title': 'Dart Language', 'tweets': '8.1K'},
      {'category': 'Mobile Development', 'title': 'React Native', 'tweets': '15.7K'},
      {'category': 'Trending in Tech', 'title': 'AI Revolution', 'tweets': '67.9K'},
      {'category': 'Development', 'title': 'Web3', 'tweets': '23.4K'},
    ];

    return Column(
      children: trends.map((trend) => _buildTrendItem(
        trend['category']!,
        trend['title']!,
        '${trend['tweets']} Tweets',
      )).toList(),
    );
  }

  Widget _buildTrendItem(String category, String title, String tweetCount) {
    return InkWell(
      onTap: () {
        _searchController.text = title;
        _focusNode.requestFocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
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
            Icon(
              Icons.more_horiz,
              color: AppColors.midGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search results for "${_searchController.text}"',
            style: TextStyles.titleMedium.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 16),
          _buildSearchTabs(),
          const SizedBox(height: 16),
          _buildSearchResultsList(),
        ],
      ),
    );
  }

  Widget _buildSearchTabs() {
    return Row(
      children: [
        _buildTabItem('All', true),
        _buildTabItem('People', false),
        _buildTabItem('Photos', false),
        _buildTabItem('Videos', false),
      ],
    );
  }

  Widget _buildTabItem(String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyles.titleSmall.copyWith(
              color: isSelected ? AppColors.white : AppColors.midGray,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: title.length * 8.0,
            color: isSelected ? AppColors.blue : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList() {
    // Mock search results
    return Column(
      children: [
        _buildSearchResultItem(
          'Flutter Development',
          '@flutterdev',
          'Official Flutter Twitter account. Learn Dart & Flutter development.',
          true,
        ),
        _buildSearchResultItem(
          'Jane Smith',
          '@janesmith',
          'Flutter Developer 💙 | Coffee enthusiast ☕',
          false,
        ),
        _buildSearchResultItem(
          'Tech News',
          '@technews',
          'Latest tech news and updates 📱💻',
          true,
        ),
      ],
    );
  }

  Widget _buildSearchResultItem(
    String name,
    String handle,
    String bio,
    bool isVerified,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-${isVerified ? '1507003211169-0a1dd7228f2d' : '1494790108755-2616b612b5bc'}?w=150&h=150&fit=crop&crop=face',
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
                      name,
                      style: TextStyles.titleSmall.copyWith(color: AppColors.white),
                    ),
                    if (isVerified) ...[
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
                  handle,
                  style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
                ),
                const SizedBox(height: 4),
                Text(
                  bio,
                  style: TextStyles.bodySmall.copyWith(color: AppColors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // Handle follow/unfollow
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.blue,
              side: const BorderSide(color: AppColors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Follow',
              style: TextStyles.buttonSmall,
            ),
          ),
        ],
      ),
    );
  }
}