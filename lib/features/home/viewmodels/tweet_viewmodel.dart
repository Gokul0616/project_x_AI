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

  void addTweet(String content, {List<String> mediaUrls = const []}) {
    final newTweet = Tweet(
      id: 'tweet_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      username: 'You',
      handle: 'you',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      content: content,
      createdAt: DateTime.now(),
      imageUrls: mediaUrls,
    );

    _tweets.insert(0, newTweet);
    notifyListeners();
  }

  void addQuoteTweet(String content, Tweet quotedTweet, {List<String> mediaUrls = const []}) {
    final newTweet = Tweet(
      id: 'quote_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      username: 'You',
      handle: 'you',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      content: content,
      createdAt: DateTime.now(),
      imageUrls: mediaUrls,
      quotedTweet: quotedTweet,
    );

    _tweets.insert(0, newTweet);
    
    // Increment quote count on original tweet
    final originalIndex = _tweets.indexWhere((tweet) => tweet.id == quotedTweet.id);
    if (originalIndex != -1) {
      final originalTweet = _tweets[originalIndex];
      _tweets[originalIndex] = originalTweet.copyWith(
        retweetsCount: originalTweet.retweetsCount + 1,
      );
    }
    
    notifyListeners();
  }

  void addReply(String parentTweetId, String content, {List<String> mediaUrls = const []}) {
    final reply = Tweet(
      id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      username: 'You',
      handle: 'you',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      content: content,
      createdAt: DateTime.now(),
      parentTweetId: parentTweetId,
      imageUrls: mediaUrls,
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

  void updateTweet(Tweet updatedTweet) {
    final index = _tweets.indexWhere((tweet) => tweet.id == updatedTweet.id);
    if (index != -1) {
      _tweets[index] = updatedTweet;
      notifyListeners();
    }
  }

  void deleteTweet(String tweetId) {
    _tweets.removeWhere((tweet) => tweet.id == tweetId);
    notifyListeners();
  }

  void bookmarkTweet(String tweetId) {
    final tweetIndex = _tweets.indexWhere((tweet) => tweet.id == tweetId);
    if (tweetIndex != -1) {
      final tweet = _tweets[tweetIndex];
      _tweets[tweetIndex] = tweet.copyWith(
        isBookmarked: !tweet.isBookmarked,
      );
      notifyListeners();
    }
  }

  void followUser(String userId) {
    // Update tweets from this user to show following status
    for (int i = 0; i < _tweets.length; i++) {
      if (_tweets[i].userId == userId) {
        _tweets[i] = _tweets[i].copyWith(isFollowing: true);
      }
    }
    notifyListeners();
  }

  void unfollowUser(String userId) {
    // Update tweets from this user to show unfollowing status
    for (int i = 0; i < _tweets.length; i++) {
      if (_tweets[i].userId == userId) {
        _tweets[i] = _tweets[i].copyWith(isFollowing: false);
      }
    }
    notifyListeners();
  }

  void muteUser(String userId) {
    // Remove tweets from muted user
    _tweets.removeWhere((tweet) => tweet.userId == userId);
    notifyListeners();
  }

  void blockUser(String userId) {
    // Remove tweets from blocked user
    _tweets.removeWhere((tweet) => tweet.userId == userId);
    notifyListeners();
  }

  void reportTweet(String tweetId, String reason) {
    // In a real app, this would send a report to the server
    // For now, just show that the tweet was reported
    final tweetIndex = _tweets.indexWhere((tweet) => tweet.id == tweetId);
    if (tweetIndex != -1) {
      // Could mark tweet as reported or remove it
      // _tweets.removeAt(tweetIndex);
      // notifyListeners();
    }
  }

  List<Tweet> getTweetsByUser(String userId) {
    return _tweets.where((tweet) => tweet.userId == userId).toList();
  }

  List<Tweet> getBookmarkedTweets() {
    return _tweets.where((tweet) => tweet.isBookmarked).toList();
  }

  List<Tweet> getLikedTweets() {
    return _tweets.where((tweet) => tweet.isLiked).toList();
  }

  List<Tweet> getRetweetedTweets() {
    return _tweets.where((tweet) => tweet.isRetweeted).toList();
  }

  List<Tweet> searchTweets(String query) {
    return _tweets.where((tweet) => 
      tweet.content.toLowerCase().contains(query.toLowerCase()) ||
      tweet.username.toLowerCase().contains(query.toLowerCase()) ||
      tweet.handle.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}