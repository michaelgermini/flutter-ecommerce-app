import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class RecentlyViewedProvider with ChangeNotifier {
  static const String _recentlyViewedKey = 'recently_viewed_products';
  static const int _maxRecentlyViewed = 20;

  List<Product> _recentlyViewedProducts = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Product> get recentlyViewedProducts => _recentlyViewedProducts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get count => _recentlyViewedProducts.length;

  RecentlyViewedProvider() {
    _loadRecentlyViewedProducts();
  }

  // Add product to recently viewed
  void addToRecentlyViewed(Product product) {
    // Remove if already exists to move it to the front
    _recentlyViewedProducts.removeWhere((p) => p.id == product.id);

    // Add to the beginning of the list
    _recentlyViewedProducts.insert(0, product);

    // Limit the number of recently viewed products
    if (_recentlyViewedProducts.length > _maxRecentlyViewed) {
      _recentlyViewedProducts = _recentlyViewedProducts.sublist(0, _maxRecentlyViewed);
    }

    _saveRecentlyViewedProducts();
    notifyListeners();
  }

  // Remove product from recently viewed
  void removeFromRecentlyViewed(String productId) {
    _recentlyViewedProducts.removeWhere((p) => p.id == productId);
    _saveRecentlyViewedProducts();
    notifyListeners();
  }

  // Clear all recently viewed products
  void clearRecentlyViewed() {
    _recentlyViewedProducts.clear();
    _saveRecentlyViewedProducts();
    notifyListeners();
  }

  // Check if product is in recently viewed
  bool isRecentlyViewed(String productId) {
    return _recentlyViewedProducts.any((p) => p.id == productId);
  }

  // Get recently viewed products by category
  List<Product> getRecentlyViewedByCategory(String category) {
    return _recentlyViewedProducts
        .where((p) => p.category == category)
        .toList();
  }

  // Get recently viewed products within price range
  List<Product> getRecentlyViewedByPriceRange(double minPrice, double maxPrice) {
    return _recentlyViewedProducts
        .where((p) => p.price >= minPrice && p.price <= maxPrice)
        .toList();
  }

  // Get recent products (last N products)
  List<Product> getRecentProducts({int limit = 5}) {
    return _recentlyViewedProducts.take(limit).toList();
  }

  // Persistence methods
  Future<void> _loadRecentlyViewedProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(_recentlyViewedKey);
      if (productsJson != null) {
        final productsList = json.decode(productsJson) as List;
        _recentlyViewedProducts = productsList
            .map((item) => Product.fromJson(item))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load recently viewed products: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveRecentlyViewedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = json.encode(
        _recentlyViewedProducts.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_recentlyViewedKey, productsJson);
    } catch (e) {
      debugPrint('Error saving recently viewed products: $e');
    }
  }

  // Statistics methods
  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (final product in _recentlyViewedProducts) {
      stats[product.category] = (stats[product.category] ?? 0) + 1;
    }
    return stats;
  }

  double getAveragePrice() {
    if (_recentlyViewedProducts.isEmpty) return 0.0;
    final total = _recentlyViewedProducts.fold(0.0, (sum, p) => sum + p.price);
    return total / _recentlyViewedProducts.length;
  }

  List<String> getPopularCategories({int limit = 5}) {
    final stats = getCategoryStats();
    final sorted = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }
}
