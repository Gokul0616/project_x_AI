import 'package:flutter/material.dart';
import 'package:project_x/core/models/community_model.dart';
import 'package:project_x/core/models/user_model.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/core/utils/responsive_utils.dart';
import 'package:project_x/features/communities/widgets/community_card.dart';
import 'package:provider/provider.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: ResponsiveUtils.isLargeScreen(context)
              ? _buildLargeScreenLayout(isDark)
              : _buildMobileLayout(isDark),
          floatingActionButton: FloatingActionButton(
            onPressed: _createCommunity,
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
          ),
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
        _buildSearchBar(isDark),
        _buildTabBar(isDark),
        Expanded(child: _buildMainContent(isDark)),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search communities...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 2,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        labelStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Discover'),
          Tab(text: 'My Communities'),
          Tab(text: 'Trending'),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDark) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDiscoverTab(isDark),
        _buildMyCommunitiesTab(isDark),
        _buildTrendingTab(isDark),
      ],
    );
  }

  Widget _buildDiscoverTab(bool isDark) {
    final communities = _getFilteredCommunities(_getMockCommunities());

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: communities.isEmpty
          ? _buildEmptyState(
              icon: Icons.explore,
              title: 'No communities found',
              subtitle: 'Try adjusting your search or create a new community.',
              isDark: isDark,
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: communities.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CommunityCard(
                    community: communities[index],
                    onTap: () => _openCommunity(communities[index]),
                    onJoin: () => _joinCommunity(communities[index]),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMyCommunitiesTab(bool isDark) {
    final myCommunities = _getMockCommunities()
        .where((community) => community.isJoined)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: myCommunities.isEmpty
          ? _buildEmptyState(
              icon: Icons.groups,
              title: 'No communities joined',
              subtitle: 'Join communities to see them here.',
              isDark: isDark,
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: myCommunities.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CommunityCard(
                    community: myCommunities[index],
                    onTap: () => _openCommunity(myCommunities[index]),
                    onJoin: () => _joinCommunity(myCommunities[index]),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTrendingTab(bool isDark) {
    final trendingCommunities = _getMockCommunities()
        .where((community) => community.memberCount > 500)
        .toList()
      ..sort((a, b) => b.memberCount.compareTo(a.memberCount));

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: trendingCommunities.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CommunityCard(
              community: trendingCommunities[index],
              onTap: () => _openCommunity(trendingCommunities[index]),
              onJoin: () => _joinCommunity(trendingCommunities[index]),
            ),
          );
        },
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
            'Community Guidelines',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildGuidelineItem('Be respectful and kind', isDark),
          _buildGuidelineItem('No spam or self-promotion', isDark),
          _buildGuidelineItem('Stay on topic', isDark),
          _buildGuidelineItem('Follow community rules', isDark),
          const SizedBox(height: 24),
          Text(
            'Popular Categories',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildCategoryChip('Technology', isDark),
          _buildCategoryChip('Sports', isDark),
          _buildCategoryChip('Gaming', isDark),
          _buildCategoryChip('Art & Design', isDark),
          _buildCategoryChip('Music', isDark),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Chip(
        label: Text(category),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<CommunityModel> _getFilteredCommunities(List<CommunityModel> communities) {
    if (_searchQuery.isEmpty) return communities;
    
    return communities.where((community) {
      return community.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          community.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          community.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  void _createCommunity() {
    print('Create new community');
    // TODO: Navigate to community creation screen
  }

  void _openCommunity(CommunityModel community) {
    print('Open community: ${community.name}');
    // TODO: Navigate to community detail screen
  }

  void _joinCommunity(CommunityModel community) {
    print('Join community: ${community.name}');
    // TODO: Implement join/leave community logic
  }

  List<CommunityModel> _getMockCommunities() {
    final now = DateTime.now();
    final mockUser = UserModel(
      id: '1',
      username: 'creator',
      displayName: 'Community Creator',
      email: 'creator@example.com',
      joinedDate: now.subtract(const Duration(days: 365)),
    );

    return [
      CommunityModel(
        id: '1',
        name: 'Flutter Developers',
        description: 'A community for Flutter developers to share knowledge and collaborate.',
        bannerImageUrl: 'https://via.placeholder.com/800x200',
        iconUrl: 'https://via.placeholder.com/100x100',
        creator: mockUser,
        memberCount: 1250,
        isPublic: true,
        tags: ['flutter', 'dart', 'mobile', 'development'],
        createdAt: now.subtract(const Duration(days: 180)),
        isJoined: true,
      ),
      CommunityModel(
        id: '2',
        name: 'Photography Enthusiasts',
        description: 'Share your best shots and learn from fellow photographers.',
        bannerImageUrl: 'https://via.placeholder.com/800x200',
        iconUrl: 'https://via.placeholder.com/100x100',
        creator: mockUser,
        memberCount: 890,
        isPublic: true,
        tags: ['photography', 'art', 'creative', 'tips'],
        createdAt: now.subtract(const Duration(days: 120)),
        isJoined: false,
      ),
      CommunityModel(
        id: '3',
        name: 'Gaming Central',
        description: 'Discuss the latest games, strategies, and gaming news.',
        bannerImageUrl: 'https://via.placeholder.com/800x200',
        iconUrl: 'https://via.placeholder.com/100x100',
        creator: mockUser,
        memberCount: 2340,
        isPublic: true,
        tags: ['gaming', 'esports', 'reviews', 'news'],
        createdAt: now.subtract(const Duration(days: 90)),
        isJoined: true,
      ),
      CommunityModel(
        id: '4',
        name: 'Food Lovers',
        description: 'Share recipes, restaurant reviews, and culinary adventures.',
        bannerImageUrl: 'https://via.placeholder.com/800x200',
        iconUrl: 'https://via.placeholder.com/100x100',
        creator: mockUser,
        memberCount: 670,
        isPublic: true,
        tags: ['food', 'recipes', 'cooking', 'restaurants'],
        createdAt: now.subtract(const Duration(days: 60)),
        isJoined: false,
      ),
      CommunityModel(
        id: '5',
        name: 'Tech Startups',
        description: 'Connect with entrepreneurs and discuss startup strategies.',
        bannerImageUrl: 'https://via.placeholder.com/800x200',
        iconUrl: 'https://via.placeholder.com/100x100',
        creator: mockUser,
        memberCount: 450,
        isPublic: true,
        tags: ['startups', 'business', 'tech', 'entrepreneurship'],
        createdAt: now.subtract(const Duration(days: 30)),
        isJoined: false,
      ),
    ];
  }
}