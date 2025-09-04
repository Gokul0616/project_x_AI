import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  late Dio _dio;
  static ApiService? _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await clearToken();
            // Navigate to login screen
          }
          handler.next(error);
        },
      ),
    );
  }

  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'displayName': displayName,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'login': login,
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
      await clearToken();
    } catch (e) {
      await clearToken();
      throw _handleError(e);
    }
  }

  // Tweet endpoints
  Future<Map<String, dynamic>> getTweets({
    int page = 1,
    int limit = 20,
    String type = 'feed', // feed, explore, user
    String? username,
  }) async {
    try {
      String endpoint = '/tweets/feed';
      if (type == 'explore') {
        endpoint = '/tweets/explore';
      } else if (type == 'user' && username != null) {
        endpoint = '/tweets/user/$username';
      }

      final response = await _dio.get(endpoint, queryParameters: {
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createTweet({
    required String content,
    List<Map<String, dynamic>>? media,
    String? replyTo,
    String? quoteTweet,
    String? community,
  }) async {
    try {
      final response = await _dio.post('/tweets', data: {
        'content': content,
        'media': media,
        'replyTo': replyTo,
        'quoteTweet': quoteTweet,
        'community': community,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> likeTweet(String tweetId) async {
    try {
      final response = await _dio.post('/tweets/$tweetId/like');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> retweetTweet(String tweetId) async {
    try {
      final response = await _dio.post('/tweets/$tweetId/retweet');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTweet(String tweetId) async {
    try {
      final response = await _dio.get('/tweets/$tweetId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // User endpoints
  Future<Map<String, dynamic>> getProfile(String username) async {
    try {
      final response = await _dio.get('/users/profile/$username');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? bio,
    String? location,
    String? website,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['displayName'] = displayName;
      if (bio != null) data['bio'] = bio;
      if (location != null) data['location'] = location;
      if (website != null) data['website'] = website;

      final response = await _dio.put('/users/profile', data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> followUser(String userId) async {
    try {
      final response = await _dio.post('/users/follow/$userId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> unfollowUser(String userId) async {
    try {
      final response = await _dio.delete('/users/follow/$userId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/users/search', queryParameters: {
        'q': query,
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getSuggestions({int limit = 5}) async {
    try {
      final response = await _dio.get('/users/suggestions', queryParameters: {
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Communities endpoints
  Future<Map<String, dynamic>> getCommunities({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    String sort = 'memberCount',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sort': sort,
      };
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get('/communities', queryParameters: queryParams);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCommunity(String communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> joinCommunity(String communityId) async {
    try {
      final response = await _dio.post('/communities/$communityId/join');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> leaveCommunity(String communityId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/leave');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMyCommunities() async {
    try {
      final response = await _dio.get('/communities/my-communities');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDiscoverCommunities({int limit = 10}) async {
    try {
      final response = await _dio.get('/communities/discover', queryParameters: {
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Messages endpoints
  Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/messages/conversations', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createConversation(String participantId) async {
    try {
      final response = await _dio.post('/messages/conversations', data: {
        'participantId': participantId,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/messages/conversations/$conversationId/messages',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
    List<Map<String, dynamic>>? media,
    String? replyTo,
  }) async {
    try {
      final response = await _dio.post(
        '/messages/conversations/$conversationId/messages',
        data: {
          'content': content,
          'messageType': messageType,
          'media': media,
          'replyTo': replyTo,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await _dio.get('/messages/unread-count');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Upload endpoints
  Future<Map<String, dynamic>> uploadAvatar(File file) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(file.path),
      });

      final response = await _dio.post('/upload/profile/avatar', data: formData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadMedia(List<File> files) async {
    try {
      final formData = FormData.fromMap({
        'media': files.map((file) => MultipartFile.fromFileSync(file.path)).toList(),
      });

      final response = await _dio.post('/upload/tweet/media', data: formData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data['message'] != null) {
        return error.response!.data['message'];
      }
      return error.message ?? 'Network error occurred';
    }
    return error.toString();
  }
}