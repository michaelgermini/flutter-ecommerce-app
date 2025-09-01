import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get shippingCost {
    return totalAmount > 50 ? 0.0 : 5.99;
  }

  double get taxAmount {
    return totalAmount * 0.08; // 8% tax
  }

  double get finalTotal => totalAmount + shippingCost + taxAmount;

  bool get isEmpty => _items.isEmpty;

  void addItem(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Product already in cart, update quantity
      final existingItem = _items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      if (newQuantity <= product.stockQuantity) {
        _items[existingIndex] = existingItem.copyWith(quantity: newQuantity);
      }
    } else {
      // Product not in cart, add new item
      if (quantity <= product.stockQuantity) {
        _items.add(CartItem(product: product, quantity: quantity));
      }
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      if (newQuantity <= 0) {
        removeItem(productId);
      } else if (newQuantity <= _items[index].product.stockQuantity) {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
        notifyListeners();
      }
    }
  }

  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final currentQuantity = _items[index].quantity;
      updateQuantity(productId, currentQuantity + 1);
    }
  }

  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final currentQuantity = _items[index].quantity;
      updateQuantity(productId, currentQuantity - 1);
    }
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(
        id: '',
        name: '',
        description: '',
        price: 0.0,
        imageUrl: '',
        category: '',
      ), quantity: 0),
    );
    return item.quantity;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Get cart items as JSON for persistence
  List<Map<String, dynamic>> get cartItemsJson {
    return _items.map((item) => item.toJson()).toList();
  }

  // Load cart items from JSON
  void loadCartItems(List<Map<String, dynamic>> itemsJson) {
    _items.clear();
    for (final itemJson in itemsJson) {
      try {
        _items.add(CartItem.fromJson(itemJson));
      } catch (e) {
        debugPrint('Error loading cart item: $e');
      }
    }
    notifyListeners();
  }
}
