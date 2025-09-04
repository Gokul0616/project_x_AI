import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService with ChangeNotifier {
  static const String _userKey = 'current_user';
  static const String _accountsKey = 'user_accounts';

  User? _currentUser;
  List<User> _accounts = [];
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  List<User> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadStoredAccounts();
      await _loadCurrentUser();

      if (_currentUser != null) {
        // Refresh current user data
        await _refreshCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String login, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.instance.login(
        login: login,
        password: password,
      );

      if (response['success']) {
        final token = response['token'];
        final userData = response['user'];

        await ApiService.instance.setToken(token);

        final user = User.fromJson(userData);
        await _setCurrentUser(user);
        await _addToAccounts(user);

        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.instance.register(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
      );

      if (response['success']) {
        final token = response['token'];
        final userData = response['user'];

        await ApiService.instance.setToken(token);

        final user = User.fromJson(userData);
        await _setCurrentUser(user);
        await _addToAccounts(user);

        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.instance.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }

    await _clearCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> switchAccount(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, you'd need to store tokens for each account
      // For now, we'll just switch to the user data we have stored
      await _setCurrentUser(user);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeAccount(User user) async {
    try {
      _accounts.removeWhere((account) => account.id == user.id);
      await _saveAccounts();

      // If removing current account, logout
      if (_currentUser?.id == user.id) {
        await logout();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> updateCurrentUser(User user) async {
    _currentUser = user;
    await _setCurrentUser(user);
    await _updateAccountInList(user);
  }

  Future<void> _refreshCurrentUser() async {
    try {
      final response = await ApiService.instance.getCurrentUser();
      if (response['success']) {
        final user = User.fromJson(response['user']);
        await updateCurrentUser(user);
      }
    } catch (e) {
      // If refresh fails, user might need to login again
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        await logout();
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        _currentUser = User.fromJson(userData);
      } catch (e) {
        // Clear invalid user data
        await prefs.remove(_userKey);
      }
    }
  }

  Future<void> _setCurrentUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearCurrentUser() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await ApiService.instance.clearToken();
  }

  Future<void> _loadStoredAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString(_accountsKey);

    if (accountsJson != null) {
      try {
        final List<dynamic> accountsList = jsonDecode(accountsJson);
        _accounts = accountsList.map((json) => User.fromJson(json)).toList();
      } catch (e) {
        // Clear invalid accounts data
        await prefs.remove(_accountsKey);
        _accounts = [];
      }
    }
  }

  Future<void> _addToAccounts(User user) async {
    // Remove existing account with same ID
    _accounts.removeWhere((account) => account.id == user.id);

    // Add new/updated account
    _accounts.insert(0, user);

    // Keep only last 5 accounts
    if (_accounts.length > 5) {
      _accounts = _accounts.take(5).toList();
    }

    await _saveAccounts();
  }

  Future<void> _updateAccountInList(User user) async {
    final index = _accounts.indexWhere((account) => account.id == user.id);
    if (index != -1) {
      _accounts[index] = user;
      await _saveAccounts();
    }
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = jsonEncode(
      _accounts.map((user) => user.toJson()).toList(),
    );
    await prefs.setString(_accountsKey, accountsJson);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
