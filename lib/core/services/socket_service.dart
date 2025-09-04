import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'api_service.dart';

class SocketService with ChangeNotifier {
  static const String socketUrl = 'http://localhost:5000';
  
  io.Socket? _socket;
  bool _isConnected = false;
  final AuthService _authService;

  SocketService(this._authService);

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_socket != null && _isConnected) return;

    try {
      final token = await ApiService.instance.getToken();
      if (token == null || _authService.currentUser == null) return;

      _socket = io.io(socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'extraHeaders': {
          'Authorization': 'Bearer $token',
        },
      });

      _socket!.connect();

      _socket!.onConnect((_) {
        _isConnected = true;
        notifyListeners();
        
        // Join user's personal room
        if (_authService.currentUser != null) {
          _socket!.emit('join-user-room', _authService.currentUser!.id);
        }
        
        print('Socket connected');
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        notifyListeners();
        print('Socket disconnected');
      });

      _socket!.onError((error) {
        print('Socket error: $error');
      });

      _setupEventListeners();
    } catch (e) {
      print('Socket connection error: $e');
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      notifyListeners();
    }
  }

  void _setupEventListeners() {
    if (_socket == null) return;

    // New message received
    _socket!.on('new-message', (data) {
      _handleNewMessage(data);
    });

    // New follower notification
    _socket!.on('new-follower', (data) {
      _handleNewFollower(data);
    });

    // New like notification
    _socket!.on('new-like', (data) {
      _handleNewLike(data);
    });

    // New retweet notification
    _socket!.on('new-retweet', (data) {
      _handleNewRetweet(data);
    });

    // New reply notification
    _socket!.on('new-reply', (data) {
      _handleNewReply(data);
    });

    // New mention notification
    _socket!.on('new-mention', (data) {
      _handleNewMention(data);
    });

    // Typing indicators
    _socket!.on('typing', (data) {
      _handleTyping(data);
    });

    _socket!.on('stop-typing', (data) {
      _handleStopTyping(data);
    });

    // Community events
    _socket!.on('new-community-tweet', (data) {
      _handleNewCommunityTweet(data);
    });

    _socket!.on('new-community-member', (data) {
      _handleNewCommunityMember(data);
    });
  }

  // Event handlers
  void _handleNewMessage(dynamic data) {
    // Emit to message screens/widgets
    notifyListeners();
    print('New message received: $data');
  }

  void _handleNewFollower(dynamic data) {
    // Show notification
    print('New follower: ${data['user']['displayName']}');
  }

  void _handleNewLike(dynamic data) {
    // Show notification
    print('Tweet liked by: ${data['user']['displayName']}');
  }

  void _handleNewRetweet(dynamic data) {
    // Show notification
    print('Tweet retweeted by: ${data['user']['displayName']}');
  }

  void _handleNewReply(dynamic data) {
    // Show notification
    print('New reply from: ${data['tweet']['author']['displayName']}');
  }

  void _handleNewMention(dynamic data) {
    // Show notification
    print('Mentioned by: ${data['tweet']['author']['displayName']}');
  }

  void _handleTyping(dynamic data) {
    // Update typing indicators in message screens
    print('User typing: ${data['userId']}');
  }

  void _handleStopTyping(dynamic data) {
    // Remove typing indicators
    print('User stopped typing: ${data['userId']}');
  }

  void _handleNewCommunityTweet(dynamic data) {
    // Update community feeds
    print('New community tweet');
  }

  void _handleNewCommunityMember(dynamic data) {
    // Show community notification
    print('New community member: ${data['user']['displayName']}');
  }

  // Emit events
  void joinCommunity(String communityId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join-community', communityId);
    }
  }

  void startTyping(String recipientId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('typing', {
        'recipientId': recipientId,
        'userId': _authService.currentUser?.id,
      });
    }
  }

  void stopTyping(String recipientId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('stop-typing', {
        'recipientId': recipientId,
        'userId': _authService.currentUser?.id,
      });
    }
  }
}