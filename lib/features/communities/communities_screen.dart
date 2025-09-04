import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/models/community_model.dart';
import 'package:project_x/features/communities/viewmodels/communities_viewmodel.dart';
import 'package:project_x/features/communities/widgets/community_card.dart';
import 'package:project_x/features/communities/widgets/community_categories.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunitiesViewModel>().loadCommunities();
      context.read<CommunitiesViewModel>().loadMyCommunities();
      context.read<CommunitiesViewModel>().loadDiscoverCommunities();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Communities',
          style: TextStyles.titleMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.blue,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.midGray,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'My Communities'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(),
          _buildMyCommunitiesTab(),
          _buildAllCommunitiesTab(),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return Consumer<CommunitiesViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              _buildSearchBar(),
              const SizedBox(height: 16),
              
              // Categories
              Text(
                'Browse by category',
                style: TextStyles.titleMedium.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 12),
              const CommunityCategories(),
              const SizedBox(height: 24),
              
              // Recommended communities
              Text(
                'Recommended for you',
                style: TextStyles.titleMedium.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 12),
              
              if (viewModel.isLoadingDiscover)
                const Center(child: CircularProgressIndicator(color: AppColors.blue))
              else if (viewModel.discoverCommunities.isEmpty)
                _buildEmptyState('No communities found')
              else
                ...viewModel.discoverCommunities.map(
                  (community) => CommunityCard(
                    community: community,
                    onJoin: () => viewModel.joinCommunity(community.id),
                    onLeave: () => viewModel.leaveCommunity(community.id),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyCommunitiesTab() {
    return Consumer<CommunitiesViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingMy) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.blue),
          );
        }

        if (viewModel.myCommunities.isEmpty) {
          return _buildEmptyState(
            'You haven\'t joined any communities yet',
            actionText: 'Discover Communities',
            onAction: () => _tabController.animateTo(0),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.myCommunities.length,
          itemBuilder: (context, index) {
            final community = viewModel.myCommunities[index];
            return CommunityCard(
              community: community,
              onJoin: () => viewModel.joinCommunity(community.id),
              onLeave: () => viewModel.leaveCommunity(community.id),
            );
          },
        );
      },
    );
  }

  Widget _buildAllCommunitiesTab() {
    return Consumer<CommunitiesViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Search and filters
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildSortAndFilter(),
                ],
              ),
            ),
            
            // Communities list
            Expanded(
              child: viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.blue),
                    )
                  : viewModel.communities.isEmpty
                      ? _buildEmptyState('No communities found')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: viewModel.communities.length,
                          itemBuilder: (context, index) {
                            final community = viewModel.communities[index];
                            return CommunityCard(
                              community: community,
                              onJoin: () => viewModel.joinCommunity(community.id),
                              onLeave: () => viewModel.leaveCommunity(community.id),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'Search communities',
          hintStyle: TextStyles.bodyMedium.copyWith(color: AppColors.midGray),
          prefixIcon: const Icon(Icons.search, color: AppColors.midGray),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          // TODO: Implement search
        },
      ),
    );
  }

  Widget _buildSortAndFilter() {
    return Row(
      children: [
        _buildFilterChip('All Categories', true),
        const SizedBox(width: 8),
        _buildFilterChip('Technology', false),
        const SizedBox(width: 8),
        _buildFilterChip('Sports', false),
        const Spacer(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort, color: AppColors.white),
          color: AppColors.surfaceColor,
          onSelected: (value) {
            // TODO: Implement sorting
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'members',
              child: Text(
                'Most members',
                style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
            ),
            PopupMenuItem(
              value: 'newest',
              child: Text(
                'Newest',
                style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
            ),
            PopupMenuItem(
              value: 'active',
              child: Text(
                'Most active',
                style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Implement filter
      },
      backgroundColor: AppColors.surfaceColor,
      selectedColor: AppColors.blue,
      labelStyle: TextStyles.bodySmall.copyWith(
        color: isSelected ? AppColors.white : AppColors.midGray,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.blue : AppColors.borderColor,
      ),
    );
  }

  Widget _buildEmptyState(
    String message, {
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: AppColors.midGray,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyles.bodyLarge.copyWith(color: AppColors.midGray),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                ),
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}