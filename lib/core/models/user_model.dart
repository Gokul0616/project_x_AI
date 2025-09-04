class User {
  final String id;
  final String username;
  final String handle;
  final String email;
  final String avatarUrl;
  final String bio;
  final String location;
  final String website;
  final DateTime joinedDate;
  final int followersCount;
  final int followingCount;
  final int tweetsCount;
  final bool isFollowing;
  final bool isVerified;

  const User({
    required this.id,
    required this.username,
    required this.handle,
    required this.email,
    required this.avatarUrl,
    this.bio = '',
    this.location = '',
    this.website = '',
    required this.joinedDate,
    this.followersCount = 0,
    this.followingCount = 0,
    this.tweetsCount = 0,
    this.isFollowing = false,
    this.isVerified = false,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      handle: json['handle'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      website: json['website'] ?? '',
      joinedDate: DateTime.parse(json['joinedDate']),
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      tweetsCount: json['tweetsCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'handle': handle,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'location': location,
      'website': website,
      'joinedDate': joinedDate.toIso8601String(),
      'followersCount': followersCount,
      'followingCount': followingCount,
      'tweetsCount': tweetsCount,
      'isFollowing': isFollowing,
      'isVerified': isVerified,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? handle,
    String? email,
    String? avatarUrl,
    String? bio,
    String? location,
    String? website,
    DateTime? joinedDate,
    int? followersCount,
    int? followingCount,
    int? tweetsCount,
    bool? isFollowing,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      handle: handle ?? this.handle,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      joinedDate: joinedDate ?? this.joinedDate,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      tweetsCount: tweetsCount ?? this.tweetsCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
