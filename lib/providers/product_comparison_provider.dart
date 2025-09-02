import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class ProductComparisonProvider with ChangeNotifier {
  static const String _comparisonKey = 'product_comparison';
  static const int _maxComparisonProducts = 4;

  List<Product> _comparisonProducts = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Product> get comparisonProducts => _comparisonProducts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get count => _comparisonProducts.length;
  bool get canAddMore => _comparisonProducts.length < _maxComparisonProducts;
  int get remainingSlots => _maxComparisonProducts - _comparisonProducts.length;

  ProductComparisonProvider() {
    _loadComparisonProducts();
  }

  // Add product to comparison
  bool addToComparison(Product product) {
    if (_comparisonProducts.length >= _maxComparisonProducts) {
      _errorMessage = 'Maximum $_maxComparisonProducts products can be compared at once';
      notifyListeners();
      return false;
    }

    // Check if product already exists
    if (_comparisonProducts.any((p) => p.id == product.id)) {
      _errorMessage = 'Product already in comparison';
      notifyListeners();
      return false;
    }

    _comparisonProducts.add(product);
    _saveComparisonProducts();
    notifyListeners();
    return true;
  }

  // Remove product from comparison
  void removeFromComparison(String productId) {
    _comparisonProducts.removeWhere((p) => p.id == productId);
    _saveComparisonProducts();
    notifyListeners();
  }

  // Clear all comparison products
  void clearComparison() {
    _comparisonProducts.clear();
    _saveComparisonProducts();
    notifyListeners();
  }

  // Check if product is in comparison
  bool isInComparison(String productId) {
    return _comparisonProducts.any((p) => p.id == productId);
  }

  // Toggle product in comparison
  bool toggleComparison(Product product) {
    if (isInComparison(product.id)) {
      removeFromComparison(product.id);
      return false;
    } else {
      return addToComparison(product);
    }
  }

  // Get comparison data for specific attributes
  Map<String, List<dynamic>> getComparisonData() {
    if (_comparisonProducts.isEmpty) return {};

    Map<String, List<dynamic>> comparisonData = {};

    // Basic product info
    comparisonData['Product'] = _comparisonProducts.map((p) => p.name).toList();
    comparisonData['Price'] = _comparisonProducts.map((p) => '\$${p.price.toStringAsFixed(2)}').toList();
    comparisonData['Rating'] = _comparisonProducts.map((p) => '${p.rating} ⭐').toList();
    comparisonData['Category'] = _comparisonProducts.map((p) => p.category).toList();

    // Product specifications (using mock data for now)
    comparisonData['Brand'] = _comparisonProducts.map((p) => _getBrand(p)).toList();
    comparisonData['Warranty'] = _comparisonProducts.map((p) => _getWarranty(p)).toList();
    comparisonData['Weight'] = _comparisonProducts.map((p) => _getWeight(p)).toList();
    comparisonData['Dimensions'] = _comparisonProducts.map((p) => _getDimensions(p)).toList();

    return comparisonData;
  }

  // Helper methods for mock specifications
  String _getBrand(Product product) {
    final brands = ['Apple', 'Samsung', 'Google', 'Microsoft', 'Sony', 'Dell', 'HP', 'Lenovo'];
    return brands[product.id.hashCode % brands.length];
  }

  String _getWarranty(Product product) {
    final warranties = ['1 Year', '2 Years', '3 Years', '5 Years', 'Lifetime'];
    return warranties[product.id.hashCode % warranties.length];
  }

  String _getWeight(Product product) {
    final weights = ['0.5 kg', '1.2 kg', '2.1 kg', '3.5 kg', '5.2 kg'];
    return weights[product.id.hashCode % weights.length];
  }

  String _getDimensions(Product product) {
    final dimensions = [
      '30x20x5 cm', '35x25x8 cm', '40x30x10 cm', '45x35x12 cm', '50x40x15 cm'
    ];
    return dimensions[product.id.hashCode % dimensions.length];
  }

  // Get products by category for comparison suggestions
  List<Product> getSimilarProductsForComparison(Product product, List<Product> allProducts) {
    return allProducts
        .where((p) => p.category == product.category && p.id != product.id)
        .take(3)
        .toList();
  }

  // Get comparison statistics
  Map<String, dynamic> getComparisonStats() {
    if (_comparisonProducts.isEmpty) return {};

    double totalPrice = _comparisonProducts.fold(0, (sum, p) => sum + p.price);
    double avgPrice = totalPrice / _comparisonProducts.length;
    double minPrice = _comparisonProducts.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    double maxPrice = _comparisonProducts.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    double avgRating = _comparisonProducts.fold(0.0, (sum, p) => sum + p.rating) / _comparisonProducts.length;

    Map<String, int> categoryCount = {};
    for (var product in _comparisonProducts) {
      categoryCount[product.category] = (categoryCount[product.category] ?? 0) + 1;
    }

    return {
      'totalProducts': _comparisonProducts.length,
      'totalPrice': totalPrice,
      'avgPrice': avgPrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'avgRating': avgRating,
      'categories': categoryCount,
      'priceRange': maxPrice - minPrice,
    };
  }

  // Persistence methods
  Future<void> _loadComparisonProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(_comparisonKey);
      if (productsJson != null) {
        final productsList = json.decode(productsJson) as List;
        _comparisonProducts = productsList
            .map((item) => Product.fromJson(item))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load comparison products: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveComparisonProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = json.encode(
        _comparisonProducts.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_comparisonKey, productsJson);
    } catch (e) {
      debugPrint('Error saving comparison products: $e');
    }
  }

  // Utility methods
  bool hasComparisonProducts() => _comparisonProducts.isNotEmpty;

  Product? getProductById(String productId) {
    try {
      return _comparisonProducts.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
