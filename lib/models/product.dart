class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isInStock;
  final int stockQuantity;
  final List<String> images;
  final Map<String, String> specifications;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isInStock = true,
    this.stockQuantity = 0,
    this.images = const [],
    this.specifications = const {},
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isInStock: json['isInStock'] as bool? ?? true,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      images: List<String>.from(json['images'] ?? []),
      specifications: Map<String, String>.from(json['specifications'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'isInStock': isInStock,
      'stockQuantity': stockQuantity,
      'images': images,
      'specifications': specifications,
    };
  }

  // Sample reviews for demonstration
  List<Map<String, dynamic>> get sampleReviews => [
    {
      'id': '1',
      'userName': 'Sarah Johnson',
      'userAvatar': null,
      'rating': 5.0,
      'date': '2024-01-15',
      'title': 'Excellent quality and fast delivery!',
      'comment': 'I\'m very satisfied with this product. The quality is outstanding and it arrived much faster than expected. The packaging was also very professional.',
      'helpful': 12,
      'verified': true,
      'images': [],
    },
    {
      'id': '2',
      'userName': 'Mike Chen',
      'userAvatar': null,
      'rating': 4.0,
      'date': '2024-01-10',
      'title': 'Good product, minor issues',
      'comment': 'Overall good product. Works as described. Only minor issue is that the setup took a bit longer than expected, but the manual was clear.',
      'helpful': 8,
      'verified': true,
      'images': [],
    },
    {
      'id': '3',
      'userName': 'Emma Wilson',
      'userAvatar': null,
      'rating': 5.0,
      'date': '2024-01-08',
      'title': 'Perfect for my needs',
      'comment': 'Exactly what I was looking for. Great build quality and the features are exactly as advertised. Highly recommend!',
      'helpful': 15,
      'verified': true,
      'images': [],
    },
  ];

  // Price history for the last 30 days
  List<Map<String, dynamic>> get priceHistory => [
    {'date': '2024-08-15', 'price': price * 1.1},
    {'date': '2024-08-22', 'price': price * 1.05},
    {'date': '2024-08-29', 'price': price * 0.95},
    {'date': '2024-09-05', 'price': price * 0.98},
    {'date': '2024-09-12', 'price': price},
  ];

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    double? rating,
    int? reviewCount,
    bool? isInStock,
    int? stockQuantity,
    List<String>? images,
    Map<String, String>? specifications,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isInStock: isInStock ?? this.isInStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      images: images ?? this.images,
      specifications: specifications ?? this.specifications,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
