import 'package:flutter/foundation.dart';
import '../../../core/models/community_model.dart';
import '../../../core/services/api_service.dart';

class CommunitiesViewModel with ChangeNotifier {
  List<Community> _communities = [];
  List<Community> _myCommunities = [];
  List<Community> _discoverCommunities = [];
  bool _isLoading = false;
  bool _isLoadingMy = false;
  bool _isLoadingDiscover = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<Community> get communities => _communities;
  List<Community> get myCommunities => _myCommunities;
  List<Community> get discoverCommunities => _discoverCommunities;
  bool get isLoading => _isLoading;
  bool get isLoadingMy => _isLoadingMy;
  bool get isLoadingDiscover => _isLoadingDiscover;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  Future<void> loadCommunities({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    String sort = 'memberCount',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.instance.getCommunities(
        page: page,
        limit: limit,
        category: category,
        search: search,
        sort: sort,
      );

      if (response['success']) {
        final List<dynamic> communitiesData = response['communities'];
        if (page == 1) {
          _communities = communitiesData
              .map((data) => Community.fromJson(data))
              .toList();
        } else {
          _communities.addAll(
            communitiesData.map((data) => Community.fromJson(data)).toList(),
          );
        }
      } else {
        _error = response['message'] ?? 'Failed to load communities';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyCommunities() async {
    _isLoadingMy = true;
    notifyListeners();

    try {
      final response = await ApiService.instance.getMyCommunities();

      if (response['success']) {
        final List<dynamic> communitiesData = response['communities'];
        _myCommunities = communitiesData
            .map((data) => Community.fromJson(data))
            .toList();
      } else {
        _error = response['message'] ?? 'Failed to load my communities';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMy = false;
      notifyListeners();
    }
  }

  Future<void> loadDiscoverCommunities({int limit = 10}) async {
    _isLoadingDiscover = true;
    notifyListeners();

    try {
      final response = await ApiService.instance.getDiscoverCommunities(
        limit: limit,
      );

      if (response['success']) {
        final List<dynamic> communitiesData = response['communities'];
        _discoverCommunities = communitiesData
            .map((data) => Community.fromJson(data))
            .toList();
      } else {
        _error = response['message'] ?? 'Failed to load discover communities';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDiscover = false;
      notifyListeners();
    }
  }

  Future<bool> joinCommunity(String communityId) async {
    try {
      final response = await ApiService.instance.joinCommunity(communityId);
      
      if (response['success']) {
        // Update community membership status in all lists
        _updateCommunityMembership(communityId, true);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to join community';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> leaveCommunity(String communityId) async {
    try {
      final response = await ApiService.instance.leaveCommunity(communityId);
      
      if (response['success']) {
        // Update community membership status in all lists
        _updateCommunityMembership(communityId, false);
        return true;
      } else {
        _error = response['message'] ?? 'Failed to leave community';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void _updateCommunityMembership(String communityId, bool isMember) {
    // Update in communities list
    final communityIndex = _communities.indexWhere((c) => c.id == communityId);
    if (communityIndex != -1) {
      _communities[communityIndex] = _communities[communityIndex].copyWith(
        isMember: isMember,
        memberCount: isMember 
            ? _communities[communityIndex].memberCount + 1
            : _communities[communityIndex].memberCount - 1,
      );
    }

    // Update in discover list
    final discoverIndex = _discoverCommunities.indexWhere((c) => c.id == communityId);
    if (discoverIndex != -1) {
      _discoverCommunities[discoverIndex] = _discoverCommunities[discoverIndex].copyWith(
        isMember: isMember,
        memberCount: isMember 
            ? _discoverCommunities[discoverIndex].memberCount + 1
            : _discoverCommunities[discoverIndex].memberCount - 1,
      );
    }

    // Update my communities list
    if (isMember) {
      // Add to my communities if not already there
      if (!_myCommunities.any((c) => c.id == communityId)) {
        final community = _communities.firstWhere(
          (c) => c.id == communityId,
          orElse: () => _discoverCommunities.firstWhere((c) => c.id == communityId),
        );
        _myCommunities.insert(0, community.copyWith(isMember: true));
      }
    } else {
      // Remove from my communities
      _myCommunities.removeWhere((c) => c.id == communityId);
    }

    notifyListeners();
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      loadCommunities(category: category == 'All' ? null : category);
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      loadCommunities(search: query.isEmpty ? null : query);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}