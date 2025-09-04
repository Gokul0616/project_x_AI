class Community {
  final String id;
  final String name;
  final String description;
  final String avatar;
  final String banner;
  final String category;
  final List<String> tags;
  final bool isPrivate;
  final bool requireApproval;
  final bool isVerified;
  final bool isActive;
  final int memberCount;
  final DateTime createdAt;
  final CommunityCreator creator;
  final List<CommunityMember> members;
  final List<CommunityRule> rules;
  final CommunityStats stats;
  final bool isMember;
  final bool isModerator;

  const Community({
    required this.id,
    required this.name,
    required this.description,
    this.avatar = '',
    this.banner = '',
    required this.category,
    this.tags = const [],
    this.isPrivate = false,
    this.requireApproval = false,
    this.isVerified = false,
    this.isActive = true,
    required this.memberCount,
    required this.createdAt,
    required this.creator,
    this.members = const [],
    this.rules = const [],
    required this.stats,
    this.isMember = false,
    this.isModerator = false,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      avatar: json['avatar'] ?? '',
      banner: json['banner'] ?? '',
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      isPrivate: json['isPrivate'] ?? false,
      requireApproval: json['requireApproval'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      memberCount: json['memberCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      creator: CommunityCreator.fromJson(json['creator'] ?? {}),
      members: (json['members'] as List<dynamic>?)
          ?.map((member) => CommunityMember.fromJson(member))
          .toList() ?? [],
      rules: (json['rules'] as List<dynamic>?)
          ?.map((rule) => CommunityRule.fromJson(rule))
          .toList() ?? [],
      stats: CommunityStats.fromJson(json['stats'] ?? {}),
      isMember: json['isMember'] ?? false,
      isModerator: json['isModerator'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar': avatar,
      'banner': banner,
      'category': category,
      'tags': tags,
      'isPrivate': isPrivate,
      'requireApproval': requireApproval,
      'isVerified': isVerified,
      'isActive': isActive,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
      'creator': creator.toJson(),
      'members': members.map((member) => member.toJson()).toList(),
      'rules': rules.map((rule) => rule.toJson()).toList(),
      'stats': stats.toJson(),
      'isMember': isMember,
      'isModerator': isModerator,
    };
  }

  Community copyWith({
    String? id,
    String? name,
    String? description,
    String? avatar,
    String? banner,
    String? category,
    List<String>? tags,
    bool? isPrivate,
    bool? requireApproval,
    bool? isVerified,
    bool? isActive,
    int? memberCount,
    DateTime? createdAt,
    CommunityCreator? creator,
    List<CommunityMember>? members,
    List<CommunityRule>? rules,
    CommunityStats? stats,
    bool? isMember,
    bool? isModerator,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      banner: banner ?? this.banner,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPrivate: isPrivate ?? this.isPrivate,
      requireApproval: requireApproval ?? this.requireApproval,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      creator: creator ?? this.creator,
      members: members ?? this.members,
      rules: rules ?? this.rules,
      stats: stats ?? this.stats,
      isMember: isMember ?? this.isMember,
      isModerator: isModerator ?? this.isModerator,
    );
  }
}

class CommunityCreator {
  final String id;
  final String username;
  final String displayName;
  final String avatar;
  final bool isVerified;

  const CommunityCreator({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatar = '',
    this.isVerified = false,
  });

  factory CommunityCreator.fromJson(Map<String, dynamic> json) {
    return CommunityCreator(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      avatar: json['avatar'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatar': avatar,
      'isVerified': isVerified,
    };
  }
}

class CommunityMember {
  final String userId;
  final String username;
  final String displayName;
  final String avatar;
  final bool isVerified;
  final String role;
  final DateTime joinedAt;

  const CommunityMember({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatar = '',
    this.isVerified = false,
    this.role = 'member',
    required this.joinedAt,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      userId: json['user']?['_id'] ?? json['user']?['id'] ?? json['userId'] ?? '',
      username: json['user']?['username'] ?? json['username'] ?? '',
      displayName: json['user']?['displayName'] ?? json['displayName'] ?? '',
      avatar: json['user']?['avatar'] ?? json['avatar'] ?? '',
      isVerified: json['user']?['isVerified'] ?? json['isVerified'] ?? false,
      role: json['role'] ?? 'member',
      joinedAt: DateTime.parse(json['joinedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'avatar': avatar,
      'isVerified': isVerified,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}

class CommunityRule {
  final String title;
  final String description;

  const CommunityRule({
    required this.title,
    required this.description,
  });

  factory CommunityRule.fromJson(Map<String, dynamic> json) {
    return CommunityRule(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}

class CommunityStats {
  final int totalPosts;
  final int totalViews;
  final double weeklyGrowth;

  const CommunityStats({
    this.totalPosts = 0,
    this.totalViews = 0,
    this.weeklyGrowth = 0.0,
  });

  factory CommunityStats.fromJson(Map<String, dynamic> json) {
    return CommunityStats(
      totalPosts: json['totalPosts'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      weeklyGrowth: (json['weeklyGrowth'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPosts': totalPosts,
      'totalViews': totalViews,
      'weeklyGrowth': weeklyGrowth,
    };
  }
}