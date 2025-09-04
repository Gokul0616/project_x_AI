// lib/features/profile/widgets/profile_content.dart
import 'package:flutter/material.dart';
import 'package:project_x/features/home/widgets/tweet_card.dart';
import 'package:project_x/core/models/user_model.dart';

class ProfileContent extends StatefulWidget {
  final String? userId;

  const ProfileContent({super.key, this.userId});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _user = _getMockUser();
    
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  UserModel _getMockUser() {
    return UserModel(
      id: 'user123',
      username: 'johndoe',
      displayName: 'John Doe',
      email: 'john@example.com',
      bio: 'Flutter developer passionate about creating amazing mobile experiences. Love to code and share knowledge with the community.',
      location: 'San Francisco, CA',
      website: 'https://johndoe.dev',
      profileImageUrl: 'https://via.placeholder.com/100',
      bannerImageUrl: 'https://via.placeholder.com/800x200',
      followers: 1234,
      following: 567,
      followerCount: 1234,
      followingCount: 567,
      isVerified: true,
      joinedDate: DateTime(2020, 1, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Banner
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    image: _user.bannerImageUrl?.isNotEmpty == true
                        ? DecorationImage(
                            image: NetworkImage(_user.bannerImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                
                // Profile Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile image and follow button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -30),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 4,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundImage: _user.profileImageUrl != null
                                    ? NetworkImage(_user.profileImageUrl!)
                                    : null,
                                backgroundColor: Colors.grey,
                                child: _user.profileImageUrl == null
                                    ? const Icon(Icons.person, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Edit profile',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Name and username
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _user.displayName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_user.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '@${_user.username}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 15,
                        ),
                      ),
                      
                      // Bio
                      if (_user.bio?.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        Text(
                          _user.bio!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                      
                      // Location and website
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (_user.location?.isNotEmpty == true) ...[
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey[500],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _user.location!,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey[500],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Joined ${_formatJoinDate(_user.joinedDate)}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      // Following/Followers
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${_user.followingCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Following',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${_user.followerCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Followers',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 2,
                labelColor: Theme.of(context).colorScheme.onSurface,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                labelStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'Replies'),
                  Tab(text: 'Media'),
                  Tab(text: 'Likes'),
                ],
              ),
            ),
          ),
          
          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTweets(),
                _buildReplies(),
                _buildMedia(),
                _buildLikes(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTweets() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const TweetCard(
          username: "John Doe",
          handle: "johndoe",
          content: "Just finished working on a new Flutter feature! Excited to share it with the community soon. #FlutterDev #MobileDev",
          time: "2h",
          likes: 24,
          retweets: 5,
          replies: 3,
        );
      },
    );
  }

  Widget _buildReplies() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No replies yet',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No media yet',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLikes() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No likes yet',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}