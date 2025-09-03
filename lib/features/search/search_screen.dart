import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/utils/responsive_utils.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/features/search/widgets/search_bar_widget.dart';
import 'package:project_x/features/search/widgets/trending_section.dart';
import 'package:project_x/features/search/widgets/search_results.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0; // 0: Top, 1: Latest, 2: People, 3: Media

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          body: ResponsiveUtils.isLargeScreen(context)
              ? _buildLargeScreenLayout(isDark)
              : _buildMobileLayout(isDark),
        );
      },
    );
  }

  Widget _buildLargeScreenLayout(bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildMainContent(isDark),
        ),
        if (ResponsiveUtils.isDesktop(context))
          Expanded(
            flex: 1,
            child: _buildRightSidebar(isDark),
          ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        // Search bar at top
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SearchBarWidget(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onSubmitted: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(child: _buildMainContent(isDark)),
      ],
    );
  }

  Widget _buildMainContent(bool isDark) {
    return Column(
      children: [
        if (_searchQuery.isNotEmpty) _buildSearchTabs(isDark),
        Expanded(
          child: _searchQuery.isEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  color: AppColors.blue,
                  backgroundColor: AppColors.cardColor(isDark),
                  child: _buildExploreContent(isDark),
                )
              : SearchResults(
                  query: _searchQuery,
                  selectedTab: _selectedTab,
                ),
        ),
      ],
    );
  }

  Widget _buildSearchTabs(bool isDark) {
    final tabs = ['Top', 'Latest', 'People', 'Media'];
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor(isDark), width: 0.5),
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == _selectedTab;
          
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.blue : AppColors.textSecondary(isDark),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExploreContent(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TrendingSection(),
          _buildTopicsSection(isDark),
          _buildSuggestedUsers(isDark),
        ],
      ),
    );
  }

  Widget _buildTopicsSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(isDark), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Topics to follow',
            style: TextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          ...['Technology', 'Sports', 'Entertainment', 'Politics', 'Science']
              .map((topic) => _buildTopicItem(topic, isDark))
              ,
        ],
      ),
    );
  }

  Widget _buildTopicItem(String topic, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.tag,
              color: AppColors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic,
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Trending topic',
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

  Widget _buildSuggestedUsers(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(isDark), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who to follow',
            style: TextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          ...['John Developer', 'Tech News', 'Flutter Dev', 'Design Tips']
              .map((user) => _buildUserSuggestion(user, isDark))
              ,
        ],
      ),
    );
  }

  Widget _buildUserSuggestion(String username, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.midGray,
            child: Text(
              username[0].toUpperCase(),
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
                  username,
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${username.toLowerCase().replaceAll(' ', '')}',
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

  Widget _buildRightSidebar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search filters',
            style: TextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildFilterOption('From anyone', true, isDark),
          _buildFilterOption('People you follow', false, isDark),
          _buildFilterOption('Near you', false, isDark),
          const SizedBox(height: 24),
          Text(
            'Date',
            style: TextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildFilterOption('Anytime', true, isDark),
          _buildFilterOption('Past hour', false, isDark),
          _buildFilterOption('Today', false, isDark),
          _buildFilterOption('This week', false, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, bool isSelected, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: isSelected,
            onChanged: (value) {},
            activeColor: AppColors.blue,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}