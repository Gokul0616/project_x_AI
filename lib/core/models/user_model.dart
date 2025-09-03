class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String? bio;
  final String? profileImageUrl;
  final String? bannerImageUrl;
  final int followers;
  final int following;
  final int followerCount;
  final int followingCount;
  final bool isVerified;
  final DateTime joinedDate;
  final String? location;
  final String? website;

  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    this.bio,
    this.profileImageUrl,
    this.bannerImageUrl,
    this.followers = 0,
    this.following = 0,
    int? followerCount,
    int? followingCount,
    this.isVerified = false,
    required this.joinedDate,
    this.location,
    this.website,
  }) : followerCount = followerCount ?? followers,
       followingCount = followingCount ?? following;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      email: json['email'],
      bio: json['bio'],
      profileImageUrl: json['profileImageUrl'],
      bannerImageUrl: json['bannerImageUrl'],
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      followerCount: json['followerCount'] ?? json['followers'] ?? 0,
      followingCount: json['followingCount'] ?? json['following'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      joinedDate: DateTime.parse(json['joinedDate']),
      location: json['location'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'email': email,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'bannerImageUrl': bannerImageUrl,
      'followers': followers,
      'following': following,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'isVerified': isVerified,
      'joinedDate': joinedDate.toIso8601String(),
      'location': location,
      'website': website,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? email,
    String? bio,
    String? profileImageUrl,
    String? bannerImageUrl,
    int? followers,
    int? following,
    int? followerCount,
    int? followingCount,
    bool? isVerified,
    DateTime? joinedDate,
    String? location,
    String? website,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      isVerified: isVerified ?? this.isVerified,
      joinedDate: joinedDate ?? this.joinedDate,
      location: location ?? this.location,
      website: website ?? this.website,
    );
  }
}