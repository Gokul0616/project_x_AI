import '../models/tweet_model.dart';
import '../models/user_model.dart';

class MockDataService {
  static List<User> _users = [];
  static List<Tweet> _tweets = [];

  static void initializeMockData() {
    _users = _generateMockUsers();
    _tweets = _generateMockTweets();
  }

  static List<User> _generateMockUsers() {
    return [
      User(
        id: 'user1',
        username: 'Elon Musk',
        handle: 'elonmusk',
        email: 'elon@twitter.com',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        bio: 'Technoking of Tesla, Imperator of Mars 🚀',
        location: 'Mars',
        website: 'tesla.com',
        joinedDate: DateTime.now().subtract(const Duration(days: 2000)),
        followersCount: 50000000,
        followingCount: 100,
        tweetsCount: 15000,
        isVerified: true,
      ),
      User(
        id: 'user2',
        username: 'Jane Smith',
        handle: 'janesmith',
        email: 'jane@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=150&h=150&fit=crop&crop=face',
        bio: 'Flutter Developer 💙 | Coffee enthusiast ☕',
        location: 'San Francisco, CA',
        website: 'janesmith.dev',
        joinedDate: DateTime.now().subtract(const Duration(days: 800)),
        followersCount: 5000,
        followingCount: 500,
        tweetsCount: 1200,
      ),
      User(
        id: 'user3',
        username: 'Tech News',
        handle: 'technews',
        email: 'news@tech.com',
        avatarUrl: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=150&h=150&fit=crop&crop=center',
        bio: 'Latest tech news and updates 📱💻',
        location: 'Global',
        website: 'technews.com',
        joinedDate: DateTime.now().subtract(const Duration(days: 1200)),
        followersCount: 100000,
        followingCount: 200,
        tweetsCount: 5000,
        isVerified: true,
      ),
      User(
        id: 'user4',
        username: 'Sarah Wilson',
        handle: 'sarahwilson',
        email: 'sarah@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
        bio: 'UX Designer | Digital nomad 🌍',
        location: 'Remote',
        website: 'sarahdesigns.co',
        joinedDate: DateTime.now().subtract(const Duration(days: 600)),
        followersCount: 8000,
        followingCount: 300,
        tweetsCount: 800,
      ),
    ];
  }

  static List<Tweet> _generateMockTweets() {
    final tweets = [
      Tweet(
        id: 'tweet1',
        userId: 'user1',
        username: 'Elon Musk',
        handle: 'elonmusk',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        content: 'Mars needs memes 🚀 Working on Starship orbital refueling. Next stop: Red Planet!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 25000,
        retweetsCount: 8000,
        repliesCount: 2500,
        imageUrls: [],
      ),
      Tweet(
        id: 'tweet2',
        userId: 'user2',
        username: 'Jane Smith',
        handle: 'janesmith',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=150&h=150&fit=crop&crop=face',
        content: 'Just shipped a new Flutter feature! The hot reload functionality is absolutely amazing for rapid development. #FlutterDev #MobileDev',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        likesCount: 120,
        retweetsCount: 25,
        repliesCount: 8,
        imageUrls: ['https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500&h=300&fit=crop'],
      ),
      Tweet(
        id: 'tweet3',
        userId: 'user3',
        username: 'Tech News',
        handle: 'technews',
        avatarUrl: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=150&h=150&fit=crop&crop=center',
        content: 'BREAKING: Flutter 3.19 released with major performance improvements! 🎉\n\n• 40% faster startup times\n• New Material 3 components\n• Enhanced web support',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        likesCount: 850,
        retweetsCount: 300,
        repliesCount: 45,
      ),
      Tweet(
        id: 'tweet4',
        userId: 'user4',
        username: 'Sarah Wilson',
        handle: 'sarahwilson',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
        content: 'Beautiful sunset from my office today 🌅 Remote work has its perks!',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likesCount: 42,
        retweetsCount: 3,
        repliesCount: 12,
        imageUrls: ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=300&fit=crop'],
      ),
    ];

    // Add nested replies
    final reply1 = Tweet(
      id: 'reply1',
      userId: 'user2',
      username: 'Jane Smith',
      handle: 'janesmith',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=150&h=150&fit=crop&crop=face',
      content: 'This is amazing! Can\'t wait for the Mars livestreams 📺',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      parentTweetId: 'tweet1',
      likesCount: 500,
      retweetsCount: 20,
      repliesCount: 5,
    );

    final reply2 = Tweet(
      id: 'reply2',
      userId: 'user4',
      username: 'Sarah Wilson',
      handle: 'sarahwilson',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
      content: 'When do you think the first human mission will launch?',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      parentTweetId: 'tweet1',
      likesCount: 200,
      retweetsCount: 5,
      repliesCount: 2,
    );

    final nestedReply = Tweet(
      id: 'nested1',
      userId: 'user1',
      username: 'Elon Musk',
      handle: 'elonmusk',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
      content: 'Probably 2029 if all goes well! 🚀',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      parentTweetId: 'reply2',
      likesCount: 1500,
      retweetsCount: 100,
      repliesCount: 0,
    );

    // Build reply relationships
    reply2.replies.add(nestedReply);
    tweets[0] = tweets[0].copyWith(replies: [reply1, reply2]);

    return tweets;
  }

  static List<Tweet> getTweets() {
    if (_tweets.isEmpty) initializeMockData();
    return _tweets;
  }

  static List<User> getUsers() {
    if (_users.isEmpty) initializeMockData();
    return _users;
  }

  static User? getUserById(String id) {
    return _users.firstWhere((user) => user.id == id);
  }

  static Tweet? getTweetById(String id) {
    return _tweets.firstWhere((tweet) => tweet.id == id);
  }
}