import 'package:flutter/material.dart';
import 'package:project_x/core/utils/responsive_utils.dart';
import 'package:project_x/features/profile/widgets/profile_header.dart';
import 'package:project_x/features/profile/widgets/profile_stats.dart';
import 'package:project_x/features/home/widgets/tweet_card.dart';
import 'package:project_x/core/models/user_model.dart';
import 'package:project_x/core/models/tweet_model.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  late UserModel _user;
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _user = _getMockUser();
    
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });

    _scrollController.addListener(() {
      const offset = 200.0;
      if (_scrollController.offset > offset && !_showAppBarTitle) {
        setState(() {
          _showAppBarTitle = true;
        });
      } else if (_scrollController.offset <= offset && _showAppBarTitle) {
        setState(() {
          _showAppBarTitle = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveUtils.isLargeScreen(context)
          ? _buildLargeScreenLayout()
          : _buildMobileLayout(),
    );
  }

  Widget _buildLargeScreenLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildMainContent(),
        ),
        if (ResponsiveUtils.isDesktop(context))
          Expanded(
            flex: 1,
            child: _buildRightSidebar(),
          ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: AnimatedOpacity(
              opacity: _showAppBarTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                _user.displayName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: _showProfileMenu,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ProfileHeader(
                user: _user,
                onEditProfile: _editProfile,
                onFollow: _followUser,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 2,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                labelStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
                tabs: [
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Tweets'),
                        Text(
                          '${_user.following}', // Using following as tweet count for demo
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Replies'),
                        Text(
                          '42',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Media'),
                        Text(
                          '15',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Likes'),
                        Text(
                          '128',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTweetsTab(),
          _buildRepliesTab(),
          _buildMediaTab(),
          _buildLikesTab(),
        ],
      ),
    );
  }

  Widget _buildTweetsTab() {
    final tweets = _getMockTweets();
    
    if (tweets.isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No tweets yet',
        subtitle: 'When ${_user.displayName} tweets, they\'ll show up here.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: tweets.length,
      itemBuilder: (context, index) {
        final tweet = tweets[index];
        return TweetCard(
          username: tweet.author.displayName,
          handle: tweet.author.username,
          content: tweet.content,
          time: tweet.timeAgo,
          likes: tweet.likes,
          retweets: tweet.retweets,
          replies: tweet.replies,
          imageUrl: tweet.mediaUrls.isNotEmpty ? tweet.mediaUrls.first : null,
        );
      },
    );
  }

  Widget _buildRepliesTab() {
    return _buildEmptyState(
      icon: Icons.reply,
      title: 'No replies yet',
      subtitle: 'When ${_user.displayName} replies to tweets, they\'ll show up here.',
    );
  }

  Widget _buildMediaTab() {
    final mediaTweets = _getMockTweets()
        .where((tweet) => tweet.mediaUrls.isNotEmpty)
        .toList();

    if (mediaTweets.isEmpty) {
      return _buildEmptyState(
        icon: Icons.photo_library,
        title: 'No media yet',
        subtitle: 'When ${_user.displayName} tweets photos and videos, they\'ll show up here.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getCrossAxisCount(context),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: mediaTweets.length,
      itemBuilder: (context, index) {
        final tweet = mediaTweets[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            tweet.mediaUrls.first,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildLikesTab() {
    return _buildEmptyState(
      icon: Icons.favorite_border,
      title: 'No likes yet',
      subtitle: 'When ${_user.displayName} likes tweets, they\'ll show up here.',
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSidebar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileStats(user: _user),
          const SizedBox(height: 24),
          _buildFollowingSuggestions(),
        ],
      ),
    );
  }

  Widget _buildFollowingSuggestions() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You might like',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...['Tech News', 'Flutter Dev', 'Design Tips']
              .map((username) => _buildSuggestionItem(username))
              ,
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String username) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: Text(
              username[0].toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${username.toLowerCase().replaceAll(' ', '')}',
                  style: theme.textTheme.bodySmall,
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

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share profile'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copy link to profile'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editProfile() {
    // TODO: Navigate to edit profile screen
    print('Edit profile');
  }

  void _followUser() {
    // TODO: Implement follow/unfollow functionality
    print('Follow user');
  }

  UserModel _getMockUser() {
    return UserModel(
      id: widget.userId ?? 'current_user',
      username: 'johndoe',
      displayName: 'John Doe',
      email: 'john@example.com',
      bio: 'Flutter developer • UI/UX enthusiast • Coffee lover ☕\nBuilding amazing mobile experiences',
      profileImageUrl: 'https://via.placeholder.com/150',
      bannerImageUrl: 'https://via.placeholder.com/600x200',
      followers: 1234,
      following: 567,
      isVerified: true,
      joinedDate: DateTime(2020, 3, 15),
      location: 'San Francisco, CA',
      website: 'https://johndoe.dev',
    );
  }

  List<TweetModel> _getMockTweets() {
    final now = DateTime.now();
    final author = _user;

    return [
      TweetModel(
        id: '1',
        content: 'Just launched my new Flutter app! 🚀 Excited to share it with the world. #FlutterDev #MobileApp',
        author: author,
        createdAt: now.subtract(const Duration(hours: 2)),
        likes: 45,
        retweets: 12,
        replies: 8,
        mediaUrls: ['https://via.placeholder.com/500x300'],
      ),
      TweetModel(
        id: '2',
        content: 'Working on responsive design is challenging but so rewarding when you see it work across all devices! 💻📱',
        author: author,
        createdAt: now.subtract(const Duration(hours: 8)),
        likes: 23,
        retweets: 5,
        replies: 3,
      ),
      TweetModel(
        id: '3',
        content: 'Coffee and code - the perfect combination for a productive morning ☕👨‍💻',
        author: author,
        createdAt: now.subtract(const Duration(days: 1)),
        likes: 67,
        retweets: 15,
        replies: 12,
        mediaUrls: ['https://via.placeholder.com/400x400'],
      ),
    ];
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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