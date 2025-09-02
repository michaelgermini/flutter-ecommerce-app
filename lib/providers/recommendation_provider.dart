import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recommendation.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';

class RecommendationProvider with ChangeNotifier {
  static const String _recommendationsKey = 'cached_recommendations';
  static const String _userBehaviorKey = 'user_behavior';
  static const String _viewCountsKey = 'product_view_counts';
  static const String _purchaseCountsKey = 'product_purchase_counts';
  static const String _userHistoryKey = 'user_interaction_history';

  final ProductProvider _productProvider;
  final RecentlyViewedProvider _recentlyViewedProvider;
  final WishlistProvider _wishlistProvider;
  final CartProvider _cartProvider;

  List<Recommendation> _currentRecommendations = [];
  List<UserBehavior> _userBehaviors = [];
  Map<String, int> _productViewCounts = {};
  Map<String, int> _productPurchaseCounts = {};
  List<String> _userInteractionHistory = [];
  Map<String, List<String>> _userPreferences = {};

  bool _isLoading = false;
  String _errorMessage = '';
  DateTime? _lastUpdated;

  RecommendationProvider({
    required ProductProvider productProvider,
    required RecentlyViewedProvider recentlyViewedProvider,
    required WishlistProvider wishlistProvider,
    required CartProvider cartProvider,
  })  : _productProvider = productProvider,
        _recentlyViewedProvider = recentlyViewedProvider,
        _wishlistProvider = wishlistProvider,
        _cartProvider = cartProvider {
    _loadCachedData();
    _initializeRecommendationSystem();
  }

  // Getters
  List<Recommendation> get currentRecommendations => _currentRecommendations;
  List<UserBehavior> get userBehaviors => _userBehaviors;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;

  // Filtered getters
  List<Recommendation> getRecommendationsByType(RecommendationType type) {
    return _currentRecommendations.where((rec) => rec.type == type).toList();
  }

  List<Recommendation> getTopRecommendations({int limit = 10}) {
    final sorted = List<Recommendation>.from(_currentRecommendations);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted.take(limit).toList();
  }

  List<Recommendation> getRecommendationsForProduct(String productId) {
    return _currentRecommendations.where((rec) =>
      rec.id.contains(productId) ||
      rec.metadata['currentProductId'] == productId
    ).toList();
  }

  // Behavior tracking
  void trackUserBehavior({
    required String productId,
    required BehaviorType behaviorType,
    int duration = 0,
    Map<String, dynamic> context = const {},
  }) {
    final behavior = UserBehavior(
      userId: 'user_001', // In a real app, this would be the actual user ID
      productId: productId,
      behaviorType: behaviorType,
      timestamp: DateTime.now(),
      duration: duration,
      context: context,
    );

    _userBehaviors.add(behavior);

    // Update interaction history
    if (!_userInteractionHistory.contains(productId)) {
      _userInteractionHistory.add(productId);
    }

    // Update view/purchase counts
    if (behaviorType == BehaviorType.view || behaviorType == BehaviorType.click) {
      _productViewCounts[productId] = (_productViewCounts[productId] ?? 0) + 1;
    } else if (behaviorType == BehaviorType.purchase) {
      _productPurchaseCounts[productId] = (_productPurchaseCounts[productId] ?? 0) + 1;
    }

    // Keep behavior history manageable
    if (_userBehaviors.length > 500) {
      _userBehaviors = _userBehaviors.sublist(_userBehaviors.length - 500);
    }

    if (_userInteractionHistory.length > 100) {
      _userInteractionHistory = _userInteractionHistory.sublist(_userInteractionHistory.length - 100);
    }

    _saveData();
    notifyListeners();
  }

  // Recommendation generation
  Future<void> generateRecommendations({String? currentProductId}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final allProducts = _productProvider.products;

      if (allProducts.isEmpty) {
        _currentRecommendations = [];
        return;
      }

      // Build purchase and view history from behavior data
      final purchaseHistory = _buildPurchaseHistory();
      final viewHistory = _buildViewHistory();

      // Generate recommendations using the engine
      final recommendations = RecommendationEngine.generateAllRecommendations(
        currentProductId,
        allProducts,
        _productViewCounts,
        _productPurchaseCounts,
        _userInteractionHistory,
        _userPreferences,
        purchaseHistory,
        viewHistory,
      );

      _currentRecommendations = recommendations;
      _lastUpdated = DateTime.now();

      _saveData();
    } catch (e) {
      _errorMessage = 'Failed to generate recommendations: $e';
      debugPrint('Recommendation generation error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Specific recommendation methods
  Future<void> generateForProduct(String productId) async {
    await generateRecommendations(currentProductId: productId);
  }

  Future<void> generateTrending() async {
    await generateRecommendations(); // Will generate trending as part of all recommendations
  }

  Future<void> generatePersonalized() async {
    await generateRecommendations(); // Will generate personalized as part of all recommendations
  }

  // Helper methods for building history data
  Map<String, List<String>> _buildPurchaseHistory() {
    final history = <String, List<String>>{};

    // Group purchases by session/order
    final purchaseBehaviors = _userBehaviors
        .where((b) => b.behaviorType == BehaviorType.purchase)
        .toList();

    // Simple grouping by day for demo purposes
    for (final behavior in purchaseBehaviors) {
      final dayKey = behavior.timestamp.toIso8601String().substring(0, 10);
      if (!history.containsKey(dayKey)) {
        history[dayKey] = [];
      }
      if (!history[dayKey]!.contains(behavior.productId)) {
        history[dayKey]!.add(behavior.productId);
      }
    }

    return history;
  }

  Map<String, List<String>> _buildViewHistory() {
    final history = <String, List<String>>{};

    // Group views by session (using a simple time-based grouping)
    final viewBehaviors = _userBehaviors
        .where((b) => b.behaviorType == BehaviorType.view)
        .toList();

    // Group by hour for demo purposes
    for (final behavior in viewBehaviors) {
      final hourKey = behavior.timestamp.toIso8601String().substring(0, 13);
      if (!history.containsKey(hourKey)) {
        history[hourKey] = [];
      }
      if (!history[hourKey]!.contains(behavior.productId)) {
        history[hourKey]!.add(behavior.productId);
      }
    }

    return history;
  }

  // Update user preferences based on behavior
  void _updateUserPreferences() {
    _userPreferences.clear();

    // Analyze category preferences
    final categoryCounts = <String, int>{};
    for (final productId in _userInteractionHistory) {
      final product = _productProvider.products.firstWhere(
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

      if (product.category.isNotEmpty) {
        categoryCounts[product.category] = (categoryCounts[product.category] ?? 0) + 1;
      }
    }

    // Convert to preferences format
    categoryCounts.forEach((category, count) {
      _userPreferences[category] = List.filled(count, category);
    });
  }

  // Quick actions for common behaviors
  void trackProductView(String productId, {int duration = 0}) {
    trackUserBehavior(
      productId: productId,
      behaviorType: BehaviorType.view,
      duration: duration,
    );
  }

  void trackProductClick(String productId) {
    trackUserBehavior(
      productId: productId,
      behaviorType: BehaviorType.click,
    );
  }

  void trackAddToCart(String productId) {
    trackUserBehavior(
      productId: productId,
      behaviorType: BehaviorType.addToCart,
    );
  }

  void trackPurchase(String productId) {
    trackUserBehavior(
      productId: productId,
      behaviorType: BehaviorType.purchase,
    );
  }

  void trackAddToWishlist(String productId) {
    trackUserBehavior(
      productId: productId,
      behaviorType: BehaviorType.wishlist,
    );
  }

  // Analytics and insights
  Map<String, dynamic> getRecommendationStats() {
    final typeCounts = <String, int>{};
    final avgScores = <String, double>{};
    final scoreSums = <String, double>{};

    for (final rec in _currentRecommendations) {
      final typeKey = rec.type.toString().split('.').last;
      typeCounts[typeKey] = (typeCounts[typeKey] ?? 0) + 1;
      scoreSums[typeKey] = (scoreSums[typeKey] ?? 0) + rec.score;
    }

    scoreSums.forEach((type, sum) {
      avgScores[type] = sum / (typeCounts[type] ?? 1);
    });

    return {
      'totalRecommendations': _currentRecommendations.length,
      'typeBreakdown': typeCounts,
      'averageScores': avgScores,
      'userInteractions': _userInteractionHistory.length,
      'behaviorEvents': _userBehaviors.length,
      'lastUpdated': _lastUpdated?.toIso8601String(),
    };
  }

  // Refresh recommendations
  Future<void> refreshRecommendations() async {
    await generateRecommendations();
  }

  // Clear all data (for testing)
  void clearRecommendationData() {
    _currentRecommendations.clear();
    _userBehaviors.clear();
    _productViewCounts.clear();
    _productPurchaseCounts.clear();
    _userInteractionHistory.clear();
    _userPreferences.clear();
    _lastUpdated = null;
    _saveData();
    notifyListeners();
  }

  // Data persistence
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load recommendations
      final recommendationsJson = prefs.getString(_recommendationsKey);
      if (recommendationsJson != null) {
        final recommendationsList = json.decode(recommendationsJson) as List;
        _currentRecommendations = recommendationsList
            .map((item) => Recommendation.fromJson(item))
            .toList();
      }

      // Load user behaviors
      final behaviorsJson = prefs.getString(_userBehaviorKey);
      if (behaviorsJson != null) {
        final behaviorsList = json.decode(behaviorsJson) as List;
        _userBehaviors = behaviorsList
            .map((item) => UserBehavior.fromJson(item))
            .toList();
      }

      // Load view counts
      final viewCountsJson = prefs.getString(_viewCountsKey);
      if (viewCountsJson != null) {
        _productViewCounts = Map<String, int>.from(json.decode(viewCountsJson));
      }

      // Load purchase counts
      final purchaseCountsJson = prefs.getString(_purchaseCountsKey);
      if (purchaseCountsJson != null) {
        _productPurchaseCounts = Map<String, int>.from(json.decode(purchaseCountsJson));
      }

      // Load user history
      final historyJson = prefs.getString(_userHistoryKey);
      if (historyJson != null) {
        _userInteractionHistory = List<String>.from(json.decode(historyJson));
      }

      _updateUserPreferences();
    } catch (e) {
      debugPrint('Error loading recommendation data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save recommendations
      final recommendationsJson = json.encode(
        _currentRecommendations.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_recommendationsKey, recommendationsJson);

      // Save user behaviors (keep only recent ones)
      final recentBehaviors = _userBehaviors.take(200).toList();
      final behaviorsJson = json.encode(
        recentBehaviors.map((b) => b.toJson()).toList(),
      );
      await prefs.setString(_userBehaviorKey, behaviorsJson);

      // Save counts
      await prefs.setString(_viewCountsKey, json.encode(_productViewCounts));
      await prefs.setString(_purchaseCountsKey, json.encode(_productPurchaseCounts));
      await prefs.setString(_userHistoryKey, json.encode(_userInteractionHistory));
    } catch (e) {
      debugPrint('Error saving recommendation data: $e');
    }
  }

  // Initialize the system with some demo data
  void _initializeRecommendationSystem() {
    // Add some demo behaviors for better recommendations
    if (_userBehaviors.isEmpty) {
      // Simulate some user interactions
      _addDemoBehaviors();
    }

    // Generate initial recommendations
    Future.microtask(() => generateRecommendations());
  }

  void _addDemoBehaviors() {
    final demoBehaviors = [
      UserBehavior(
        userId: 'user_001',
        productId: '1', // iPhone
        behaviorType: BehaviorType.view,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        duration: 45,
      ),
      UserBehavior(
        userId: 'user_001',
        productId: '2', // MacBook
        behaviorType: BehaviorType.view,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        duration: 30,
      ),
      UserBehavior(
        userId: 'user_001',
        productId: '1', // iPhone
        behaviorType: BehaviorType.addToCart,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      UserBehavior(
        userId: 'user_001',
        productId: '4', // Samsung
        behaviorType: BehaviorType.view,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        duration: 20,
      ),
      UserBehavior(
        userId: 'user_001',
        productId: '3', // Nike shoes
        behaviorType: BehaviorType.purchase,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UserBehavior(
        userId: 'user_001',
        productId: '5', // Adidas t-shirt
        behaviorType: BehaviorType.purchase,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    for (final behavior in demoBehaviors) {
      _userBehaviors.add(behavior);

      if (!_userInteractionHistory.contains(behavior.productId)) {
        _userInteractionHistory.add(behavior.productId);
      }

      if (behavior.behaviorType == BehaviorType.view || behavior.behaviorType == BehaviorType.click) {
        _productViewCounts[behavior.productId] = (_productViewCounts[behavior.productId] ?? 0) + 1;
      } else if (behavior.behaviorType == BehaviorType.purchase) {
        _productPurchaseCounts[behavior.productId] = (_productPurchaseCounts[behavior.productId] ?? 0) + 1;
      }
    }

    _updateUserPreferences();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
