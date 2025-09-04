import 'package:flutter/foundation.dart';
import '../../../core/models/tweet_model.dart';
import '../../../core/services/mock_data_service.dart';

class TweetViewModel with ChangeNotifier {
  List<Tweet> _tweets = [];
  bool _isLoading = false;
  String? _error;

  List<Tweet> get tweets => _tweets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TweetViewModel() {
    loadTweets();
  }

  Future<void> loadTweets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      _tweets = MockDataService.getTweets();
    } catch (e) {
      _error = 'Failed to load tweets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTweets() async {
    await loadTweets();
  }

  void likeTweet(String tweetId) {
    final tweetIndex = _tweets.indexWhere((tweet) => tweet.id == tweetId);
    if (tweetIndex != -1) {
      final tweet = _tweets[tweetIndex];
      _tweets[tweetIndex] = tweet.copyWith(
        isLiked: !tweet.isLiked,
        likesCount: tweet.isLiked ? tweet.likesCount - 1 : tweet.likesCount + 1,
      );
      notifyListeners();
    }
  }

  void retweetTweet(String tweetId) {
    final tweetIndex = _tweets.indexWhere((tweet) => tweet.id == tweetId);
    if (tweetIndex != -1) {
      final tweet = _tweets[tweetIndex];
      _tweets[tweetIndex] = tweet.copyWith(
        isRetweeted: !tweet.isRetweeted,
        retweetsCount: tweet.isRetweeted 
            ? tweet.retweetsCount - 1 
            : tweet.retweetsCount + 1,
      );
      notifyListeners();
    }
  }

  void addTweet(String content, {List<String> imageUrls = const []}) {
    final newTweet = Tweet(
      id: 'tweet_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      username: 'You',
      handle: 'you',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      content: content,
      createdAt: DateTime.now(),
      imageUrls: imageUrls,
    );

    _tweets.insert(0, newTweet);
    notifyListeners();
  }

  void addReply(String parentTweetId, String content) {
    final reply = Tweet(
      id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      username: 'You',
      handle: 'you',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      content: content,
      createdAt: DateTime.now(),
      parentTweetId: parentTweetId,
    );

    // Find parent tweet and add reply
    final parentIndex = _tweets.indexWhere((tweet) => tweet.id == parentTweetId);
    if (parentIndex != -1) {
      final parentTweet = _tweets[parentIndex];
      final updatedReplies = List<Tweet>.from(parentTweet.replies)..add(reply);
      _tweets[parentIndex] = parentTweet.copyWith(
        replies: updatedReplies,
        repliesCount: parentTweet.repliesCount + 1,
      );
      notifyListeners();
    }
  }
}