import '../models/product.dart';

enum RecommendationType {
  viewedTogether,      // Products frequently viewed together
  boughtTogether,      // Products frequently bought together
  similarCategory,     // Products in same category
  trending,           // Trending/popular products
  personalized,       // AI-based personal recommendations
  recentlyViewed,     // Recently viewed products
  wishlistBased,      // Based on wishlist items
  seasonal,          // Seasonal/trending items
  priceRange,        // Products in similar price range
  brandLoyalty,      // Products from preferred brands
  behaviorBased,     // Based on user behavior patterns
}

class Recommendation {
  final String id;
  final Product product;
  final RecommendationType type;
  final double score; // 0.0 to 1.0 - relevance score
  final String reason; // Human-readable reason for recommendation
  final DateTime generatedAt;
  final Map<String, dynamic> metadata; // Additional data for the recommendation

  const Recommendation({
    required this.id,
    required this.product,
    required this.type,
    required this.score,
    required this.reason,
    required this.generatedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'type': type.toString(),
      'score': score,
      'reason': reason,
      'generatedAt': generatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      product: Product.fromJson(json['product']),
      type: RecommendationType.values.firstWhere(
        (type) => type.toString() == json['type'],
        orElse: () => RecommendationType.personalized,
      ),
      score: json['score'] ?? 0.0,
      reason: json['reason'] ?? '',
      generatedAt: DateTime.parse(json['generatedAt']),
      metadata: json['metadata'] ?? {},
    );
  }

  String get typeDisplayName {
    switch (type) {
      case RecommendationType.viewedTogether:
        return 'Frequently Viewed Together';
      case RecommendationType.boughtTogether:
        return 'Frequently Bought Together';
      case RecommendationType.similarCategory:
        return 'Similar Products';
      case RecommendationType.trending:
        return 'Trending Now';
      case RecommendationType.personalized:
        return 'Recommended for You';
      case RecommendationType.recentlyViewed:
        return 'Recently Viewed';
      case RecommendationType.wishlistBased:
        return 'Based on Your Wishlist';
      case RecommendationType.seasonal:
        return 'Seasonal Picks';
      case RecommendationType.priceRange:
        return 'Similar Price Range';
      case RecommendationType.brandLoyalty:
        return 'From Your Favorite Brands';
      case RecommendationType.behaviorBased:
        return 'Based on Your Activity';
    }
  }

  String get typeIcon {
    switch (type) {
      case RecommendationType.viewedTogether:
        return '👀';
      case RecommendationType.boughtTogether:
        return '🛒';
      case RecommendationType.similarCategory:
        return '📱';
      case RecommendationType.trending:
        return '🔥';
      case RecommendationType.personalized:
        return '🎯';
      case RecommendationType.recentlyViewed:
        return '🕐';
      case RecommendationType.wishlistBased:
        return '❤️';
      case RecommendationType.seasonal:
        return '🌸';
      case RecommendationType.priceRange:
        return '💰';
      case RecommendationType.brandLoyalty:
        return '🏷️';
      case RecommendationType.behaviorBased:
        return '📊';
    }
  }
}

class UserBehavior {
  final String userId;
  final String productId;
  final BehaviorType behaviorType;
  final DateTime timestamp;
  final int duration; // in seconds for view duration
  final Map<String, dynamic> context; // Additional context data

  const UserBehavior({
    required this.userId,
    required this.productId,
    required this.behaviorType,
    required this.timestamp,
    this.duration = 0,
    this.context = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'behaviorType': behaviorType.toString(),
      'timestamp': timestamp.toIso8601String(),
      'duration': duration,
      'context': context,
    };
  }

  factory UserBehavior.fromJson(Map<String, dynamic> json) {
    return UserBehavior(
      userId: json['userId'],
      productId: json['productId'],
      behaviorType: BehaviorType.values.firstWhere(
        (type) => type.toString() == json['behaviorType'],
        orElse: () => BehaviorType.view,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      duration: json['duration'] ?? 0,
      context: json['context'] ?? {},
    );
  }
}

enum BehaviorType {
  view,           // Product viewed
  addToCart,      // Added to cart
  removeFromCart, // Removed from cart
  purchase,       // Purchased
  wishlist,       // Added to wishlist
  share,          // Shared product
  review,         // Wrote a review
  compare,        // Added to comparison
  search,         // Searched for similar
  click,          // Clicked on product
}

class RecommendationEngine {
  static const int _maxRecommendations = 20;
  static const double _minScoreThreshold = 0.3;

  // Frequently Bought Together Algorithm
  static List<Recommendation> generateFrequentlyBoughtTogether(
    String productId,
    List<Product> allProducts,
    Map<String, List<String>> purchaseHistory,
  ) {
    final recommendations = <Recommendation>[];

    // Find products frequently purchased with the current product
    final relatedProducts = <String, double>{};

    purchaseHistory.forEach((orderId, productIds) {
      if (productIds.contains(productId)) {
        for (final pid in productIds) {
          if (pid != productId) {
            relatedProducts[pid] = (relatedProducts[pid] ?? 0) + 1;
          }
        }
      }
    });

    // Convert to recommendations
    relatedProducts.forEach((pid, score) {
      final product = allProducts.firstWhere(
        (p) => p.id == pid,
        orElse: () => Product(
          id: '',
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: '',
        ),
      );

      if (product.id.isNotEmpty) {
        final normalizedScore = score / purchaseHistory.length;
        if (normalizedScore >= _minScoreThreshold) {
          recommendations.add(Recommendation(
            id: 'fbt_${productId}_${pid}',
            product: product,
            type: RecommendationType.boughtTogether,
            score: normalizedScore,
            reason: 'Frequently bought together',
            generatedAt: DateTime.now(),
            metadata: {'frequency': score},
          ));
        }
      }
    });

    return recommendations.take(_maxRecommendations).toList();
  }

  // Viewed Together Algorithm
  static List<Recommendation> generateViewedTogether(
    String productId,
    List<Product> allProducts,
    Map<String, List<String>> viewHistory,
  ) {
    final recommendations = <Recommendation>[];

    // Find products frequently viewed with the current product
    final relatedProducts = <String, double>{};

    viewHistory.forEach((sessionId, productIds) {
      if (productIds.contains(productId)) {
        for (final pid in productIds) {
          if (pid != productId) {
            relatedProducts[pid] = (relatedProducts[pid] ?? 0) + 1;
          }
        }
      }
    });

    // Convert to recommendations
    relatedProducts.forEach((pid, score) {
      final product = allProducts.firstWhere(
        (p) => p.id == pid,
        orElse: () => Product(
          id: '',
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: '',
        ),
      );

      if (product.id.isNotEmpty) {
        final normalizedScore = score / viewHistory.length;
        if (normalizedScore >= _minScoreThreshold) {
          recommendations.add(Recommendation(
            id: 'vt_${productId}_${pid}',
            product: product,
            type: RecommendationType.viewedTogether,
            score: normalizedScore,
            reason: 'Frequently viewed together',
            generatedAt: DateTime.now(),
            metadata: {'frequency': score},
          ));
        }
      }
    });

    return recommendations.take(_maxRecommendations).toList();
  }

  // Similar Category Algorithm
  static List<Recommendation> generateSimilarCategory(
    Product currentProduct,
    List<Product> allProducts,
  ) {
    final recommendations = <Recommendation>[];

    final similarProducts = allProducts
        .where((product) =>
            product.category == currentProduct.category &&
            product.id != currentProduct.id)
        .toList();

    // Sort by rating and review count for quality
    similarProducts.sort((a, b) {
      final scoreA = (a.rating * a.reviewCount) + (a.price / 1000);
      final scoreB = (b.rating * b.reviewCount) + (b.price / 1000);
      return scoreB.compareTo(scoreA);
    });

    for (var i = 0; i < similarProducts.length && i < _maxRecommendations; i++) {
      final product = similarProducts[i];
      final score = 0.8 - (i * 0.05); // Decreasing score based on position

      recommendations.add(Recommendation(
        id: 'cat_${currentProduct.id}_${product.id}',
        product: product,
        type: RecommendationType.similarCategory,
        score: score.clamp(0.0, 1.0),
        reason: 'Similar ${currentProduct.category.toLowerCase()} product',
        generatedAt: DateTime.now(),
        metadata: {'category': currentProduct.category, 'rank': i + 1},
      ));
    }

    return recommendations;
  }

  // Price Range Algorithm
  static List<Recommendation> generatePriceRange(
    Product currentProduct,
    List<Product> allProducts,
  ) {
    final recommendations = <Recommendation>[];

    // Define price range (±30% of current price)
    final minPrice = currentProduct.price * 0.7;
    final maxPrice = currentProduct.price * 1.3;

    final similarPriceProducts = allProducts
        .where((product) =>
            product.price >= minPrice &&
            product.price <= maxPrice &&
            product.id != currentProduct.id)
        .toList();

    // Sort by price proximity and rating
    similarPriceProducts.sort((a, b) {
      final priceDiffA = (a.price - currentProduct.price).abs();
      final priceDiffB = (b.price - currentProduct.price).abs();
      final priceComparison = priceDiffA.compareTo(priceDiffB);

      if (priceComparison == 0) {
        return (b.rating * b.reviewCount).compareTo(a.rating * a.reviewCount);
      }
      return priceComparison;
    });

    for (var i = 0; i < similarPriceProducts.length && i < _maxRecommendations; i++) {
      final product = similarPriceProducts[i];
      final priceDifference = ((product.price - currentProduct.price) / currentProduct.price).abs();
      final score = 0.9 - (priceDifference * 0.5) - (i * 0.05);

      if (score >= _minScoreThreshold) {
        recommendations.add(Recommendation(
          id: 'price_${currentProduct.id}_${product.id}',
          product: product,
          type: RecommendationType.priceRange,
          score: score.clamp(0.0, 1.0),
          reason: 'Similar price range',
          generatedAt: DateTime.now(),
          metadata: {
            'priceDifference': product.price - currentProduct.price,
            'percentageDifference': priceDifference,
          },
        ));
      }
    }

    return recommendations;
  }

  // Trending Algorithm
  static List<Recommendation> generateTrending(
    List<Product> allProducts,
    Map<String, int> viewCounts,
    Map<String, int> purchaseCounts,
  ) {
    final recommendations = <Recommendation>[];

    final scoredProducts = allProducts.map((product) {
      final views = viewCounts[product.id] ?? 0;
      final purchases = purchaseCounts[product.id] ?? 0;
      final rating = product.rating;
      final reviewCount = product.reviewCount;

      // Calculate trending score
      final score = (views * 0.3) + (purchases * 0.4) + (rating * reviewCount * 0.3);

      return {
        'product': product,
        'score': score,
        'views': views,
        'purchases': purchases,
      };
    }).toList();

    // Sort by score
    scoredProducts.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    for (var i = 0; i < scoredProducts.length && i < _maxRecommendations; i++) {
      final data = scoredProducts[i];
      final product = data['product'] as Product;
      final score = data['score'] as double;

      final normalizedScore = score / (scoredProducts.first['score'] as double);

      recommendations.add(Recommendation(
        id: 'trending_${product.id}',
        product: product,
        type: RecommendationType.trending,
        score: normalizedScore.clamp(0.0, 1.0),
        reason: 'Trending product',
        generatedAt: DateTime.now(),
        metadata: {
          'views': data['views'],
          'purchases': data['purchases'],
          'rank': i + 1,
        },
      ));
    }

    return recommendations;
  }

  // Personalized Algorithm (based on user behavior)
  static List<Recommendation> generatePersonalized(
    List<String> userHistory,
    List<Product> allProducts,
    Map<String, List<String>> userPreferences,
  ) {
    final recommendations = <Recommendation>[];

    // Analyze user's preferred categories and price ranges
    final preferredCategories = <String, int>{};
    final preferredPriceRanges = <String, int>{};

    for (final productId in userHistory) {
      final product = allProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => Product(
          id: '',
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: '',
        ),
      );

      if (product.id.isNotEmpty) {
        preferredCategories[product.category] = (preferredCategories[product.category] ?? 0) + 1;

        // Categorize price ranges
        final priceRange = _getPriceRange(product.price);
        preferredPriceRanges[priceRange] = (preferredPriceRanges[priceRange] ?? 0) + 1;
      }
    }

    // Find products in preferred categories and price ranges
    final personalizedProducts = allProducts
        .where((product) =>
            !userHistory.contains(product.id) &&
            preferredCategories.containsKey(product.category))
        .toList();

    // Sort by preference strength and rating
    personalizedProducts.sort((a, b) {
      final categoryScoreA = preferredCategories[a.category] ?? 0;
      final categoryScoreB = preferredCategories[b.category] ?? 0;
      final ratingScoreA = a.rating * a.reviewCount;
      final ratingScoreB = b.rating * b.reviewCount;

      final totalScoreA = categoryScoreA + ratingScoreA;
      final totalScoreB = categoryScoreB + ratingScoreB;

      return totalScoreB.compareTo(totalScoreA);
    });

    for (var i = 0; i < personalizedProducts.length && i < _maxRecommendations; i++) {
      final product = personalizedProducts[i];
      final categoryScore = preferredCategories[product.category] ?? 0;
      final score = (categoryScore / userHistory.length) * 0.8 + (product.rating / 5.0) * 0.2;

      if (score >= _minScoreThreshold) {
        recommendations.add(Recommendation(
          id: 'personal_${product.id}',
          product: product,
          type: RecommendationType.personalized,
          score: score.clamp(0.0, 1.0),
          reason: 'Recommended based on your preferences',
          generatedAt: DateTime.now(),
          metadata: {
            'preferredCategory': product.category,
            'categoryScore': categoryScore,
          },
        ));
      }
    }

    return recommendations;
  }

  static String _getPriceRange(double price) {
    if (price < 50) return 'budget';
    if (price < 200) return 'mid-range';
    if (price < 1000) return 'premium';
    return 'luxury';
  }

  // Combine all recommendation types
  static List<Recommendation> generateAllRecommendations(
    String? currentProductId,
    List<Product> allProducts,
    Map<String, int> viewCounts,
    Map<String, int> purchaseCounts,
    List<String> userHistory,
    Map<String, List<String>> userPreferences,
    Map<String, List<String>> purchaseHistory,
    Map<String, List<String>> viewHistory,
  ) {
    final allRecommendations = <Recommendation>[];

    if (currentProductId != null) {
      // Product-specific recommendations
      allRecommendations.addAll(generateFrequentlyBoughtTogether(
        currentProductId,
        allProducts,
        purchaseHistory,
      ));

      allRecommendations.addAll(generateViewedTogether(
        currentProductId,
        allProducts,
        viewHistory,
      ));

      final currentProduct = allProducts.firstWhere(
        (p) => p.id == currentProductId,
        orElse: () => Product(
          id: '',
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: '',
        ),
      );

      if (currentProduct.id.isNotEmpty) {
        allRecommendations.addAll(generateSimilarCategory(currentProduct, allProducts));
        allRecommendations.addAll(generatePriceRange(currentProduct, allProducts));
      }
    }

    // Global recommendations
    allRecommendations.addAll(generateTrending(allProducts, viewCounts, purchaseCounts));
    allRecommendations.addAll(generatePersonalized(userHistory, allProducts, userPreferences));

    // Remove duplicates and sort by score
    final uniqueRecommendations = <String, Recommendation>{};
    for (final rec in allRecommendations) {
      if (!uniqueRecommendations.containsKey(rec.product.id) ||
          uniqueRecommendations[rec.product.id]!.score < rec.score) {
        uniqueRecommendations[rec.product.id] = rec;
      }
    }

    final finalRecommendations = uniqueRecommendations.values.toList();
    finalRecommendations.sort((a, b) => b.score.compareTo(a.score));

    return finalRecommendations.take(_maxRecommendations).toList();
  }
}
