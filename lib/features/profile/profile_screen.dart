import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor1,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTweetsTab(),
                _buildRepliesTab(),
                _buildMediaTab(),
                _buildLikesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight:
          400, // Increased to ensure all profile details are visible
      pinned: true,
      backgroundColor: AppColors.backgroundColor1,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          children: [
            // Banner
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.blue, AppColors.blueHighlight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Profile info (fixed, non-scrollable)
            Container(
              color: AppColors.backgroundColor1,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.backgroundColor1,
                            width: 4,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundImage: CachedNetworkImageProvider(
                            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Handle follow/unfollow
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Follow'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'John Doe',
                              style: TextStyles.displaySmall.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 20,
                              color: AppColors.blue,
                            ),
                          ],
                        ),
                        Text(
                          '@${widget.username}',
                          style: TextStyles.bodyMedium.copyWith(
                            color: AppColors.midGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Flutter Developer 💙 | Coffee enthusiast ☕ | Building amazing apps',
                          style: TextStyles.bodyMedium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.midGray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'San Francisco, CA',
                              style: TextStyles.bodySmall.copyWith(
                                color: AppColors.midGray,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: AppColors.midGray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Joined March 2020',
                              style: TextStyles.bodySmall.copyWith(
                                color: AppColors.midGray,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatItem('1,234', 'Following'),
                            const SizedBox(width: 20),
                            _buildStatItem('5,678', 'Followers'),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ), // Increased padding to avoid TabBar overlap
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: AppColors.backgroundColor1,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.blue,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.midGray,
            tabs: const [
              Tab(text: 'Tweets'),
              Tab(text: 'Replies'),
              Tab(text: 'Media'),
              Tab(text: 'Likes'),
            ],
          ),
        ),
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
            style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
          ),
        ],
      ),
    );
  }

  Widget _buildTweetsTab() {
    return const Center(
      child: Text(
        'Tweets will be displayed here',
        style: TextStyle(color: AppColors.midGray),
      ),
    );
  }

  Widget _buildRepliesTab() {
    return const Center(
      child: Text(
        'Replies will be displayed here',
        style: TextStyle(color: AppColors.midGray),
      ),
    );
  }

  Widget _buildMediaTab() {
    return const Center(
      child: Text(
        'Media will be displayed here',
        style: TextStyle(color: AppColors.midGray),
      ),
    );
  }

  Widget _buildLikesTab() {
    return const Center(
      child: Text(
        'Liked tweets will be displayed here',
        style: TextStyle(color: AppColors.midGray),
      ),
    );
  }
}
