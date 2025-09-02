import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _wishlistItems = [];
  final String _wishlistKey = 'wishlist_items';

  List<Product> get wishlistItems => List.unmodifiable(_wishlistItems);

  int get itemCount => _wishlistItems.length;

  bool isInWishlist(String productId) {
    return _wishlistItems.any((product) => product.id == productId);
  }

  void addToWishlist(Product product) {
    if (!isInWishlist(product.id)) {
      _wishlistItems.add(product);
      _saveWishlistToStorage();
      notifyListeners();
    }
  }

  void removeFromWishlist(String productId) {
    _wishlistItems.removeWhere((product) => product.id == productId);
    _saveWishlistToStorage();
    notifyListeners();
  }

  void toggleWishlist(Product product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }

  void clearWishlist() {
    _wishlistItems.clear();
    _saveWishlistToStorage();
    notifyListeners();
  }

  // Charger les favoris depuis le stockage local
  Future<void> loadWishlistFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getStringList(_wishlistKey) ?? [];

      _wishlistItems.clear();
      for (final productJson in wishlistJson) {
        final productMap = json.decode(productJson) as Map<String, dynamic>;
        final product = Product.fromJson(productMap);
        _wishlistItems.add(product);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  // Sauvegarder les favoris dans le stockage local
  Future<void> _saveWishlistToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = _wishlistItems
          .map((product) => json.encode(product.toJson()))
          .toList();

      await prefs.setStringList(_wishlistKey, wishlistJson);
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  // Méthode pour obtenir tous les IDs des produits favoris
  List<String> getWishlistIds() {
    return _wishlistItems.map((product) => product.id).toList();
  }
}
