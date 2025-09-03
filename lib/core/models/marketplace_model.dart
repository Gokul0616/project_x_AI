import 'package:project_x/core/models/user_model.dart';

enum ProductCategory {
  electronics,
  fashion,
  home,
  vehicles,
  books,
  sports,
  toys,
  other,
}

enum ProductCondition {
  new_item,
  like_new,
  good,
  fair,
  poor,
}

class MarketplaceItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final ProductCategory category;
  final ProductCondition condition;
  final UserModel seller;
  final String location;
  final DateTime createdAt;
  final bool isAvailable;
  final int views;
  final bool isFavorited;

  const MarketplaceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'USD',
    required this.imageUrls,
    required this.category,
    required this.condition,
    required this.seller,
    required this.location,
    required this.createdAt,
    this.isAvailable = true,
    this.views = 0,
    this.isFavorited = false,
  });

  MarketplaceItem copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? currency,
    List<String>? imageUrls,
    ProductCategory? category,
    ProductCondition? condition,
    UserModel? seller,
    String? location,
    DateTime? createdAt,
    bool? isAvailable,
    int? views,
    bool? isFavorited,
  }) {
    return MarketplaceItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      seller: seller ?? this.seller,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      isAvailable: isAvailable ?? this.isAvailable,
      views: views ?? this.views,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get categoryName {
    switch (category) {
      case ProductCategory.electronics:
        return 'Electronics';
      case ProductCategory.fashion:
        return 'Fashion';
      case ProductCategory.home:
        return 'Home & Garden';
      case ProductCategory.vehicles:
        return 'Vehicles';
      case ProductCategory.books:
        return 'Books';
      case ProductCategory.sports:
        return 'Sports';
      case ProductCategory.toys:
        return 'Toys & Games';
      case ProductCategory.other:
        return 'Other';
    }
  }

  String get conditionName {
    switch (condition) {
      case ProductCondition.new_item:
        return 'New';
      case ProductCondition.like_new:
        return 'Like New';
      case ProductCondition.good:
        return 'Good';
      case ProductCondition.fair:
        return 'Fair';
      case ProductCondition.poor:
        return 'Poor';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'imageUrls': imageUrls,
      'category': category.toString(),
      'condition': condition.toString(),
      'seller': seller.toJson(),
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'isAvailable': isAvailable,
      'views': views,
      'isFavorited': isFavorited,
    };
  }

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    return MarketplaceItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      currency: json['currency'] ?? 'USD',
      imageUrls: List<String>.from(json['imageUrls']),
      category: ProductCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => ProductCategory.other,
      ),
      condition: ProductCondition.values.firstWhere(
        (e) => e.toString() == json['condition'],
        orElse: () => ProductCondition.good,
      ),
      seller: UserModel.fromJson(json['seller']),
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
      isAvailable: json['isAvailable'] ?? true,
      views: json['views'] ?? 0,
      isFavorited: json['isFavorited'] ?? false,
    );
  }
}