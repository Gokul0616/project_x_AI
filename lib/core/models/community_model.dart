import 'package:project_x/core/models/user_model.dart';

class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String? bannerImageUrl;
  final String? iconUrl;
  final UserModel creator;
  final int memberCount;
  final bool isPublic;
  final List<String> tags;
  final DateTime createdAt;
  final bool isJoined;
  final List<CommunityPost> posts;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    this.bannerImageUrl,
    this.iconUrl,
    required this.creator,
    required this.memberCount,
    required this.isPublic,
    required this.tags,
    required this.createdAt,
    this.isJoined = false,
    this.posts = const [],
  });

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? bannerImageUrl,
    String? iconUrl,
    UserModel? creator,
    int? memberCount,
    bool? isPublic,
    List<String>? tags,
    DateTime? createdAt,
    bool? isJoined,
    List<CommunityPost>? posts,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      creator: creator ?? this.creator,
      memberCount: memberCount ?? this.memberCount,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isJoined: isJoined ?? this.isJoined,
      posts: posts ?? this.posts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'bannerImageUrl': bannerImageUrl,
      'iconUrl': iconUrl,
      'creator': creator.toJson(),
      'memberCount': memberCount,
      'isPublic': isPublic,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'isJoined': isJoined,
      'posts': posts.map((post) => post.toJson()).toList(),
    };
  }

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      bannerImageUrl: json['bannerImageUrl'],
      iconUrl: json['iconUrl'],
      creator: UserModel.fromJson(json['creator']),
      memberCount: json['memberCount'],
      isPublic: json['isPublic'],
      tags: List<String>.from(json['tags']),
      createdAt: DateTime.parse(json['createdAt']),
      isJoined: json['isJoined'] ?? false,
      posts: (json['posts'] as List?)
          ?.map((post) => CommunityPost.fromJson(post))
          .toList() ?? [],
    );
  }
}

class CommunityPost {
  final String id;
  final String communityId;
  final UserModel author;
  final String content;
  final List<String> imageUrls;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final bool isLiked;

  const CommunityPost({
    required this.id,
    required this.communityId,
    required this.author,
    required this.content,
    this.imageUrls = const [],
    required this.likes,
    required this.comments,
    required this.createdAt,
    this.isLiked = false,
  });

  CommunityPost copyWith({
    String? id,
    String? communityId,
    UserModel? author,
    String? content,
    List<String>? imageUrls,
    int? likes,
    int? comments,
    DateTime? createdAt,
    bool? isLiked,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      author: author ?? this.author,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'author': author.toJson(),
      'content': content,
      'imageUrls': imageUrls,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
    };
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      communityId: json['communityId'],
      author: UserModel.fromJson(json['author']),
      content: json['content'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      likes: json['likes'],
      comments: json['comments'],
      createdAt: DateTime.parse(json['createdAt']),
      isLiked: json['isLiked'] ?? false,
    );
  }
}