import 'package:flutter/foundation.dart';
import '../models/product.dart';

enum LoadingState { initial, loading, loaded, error }

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [];
  final List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  LoadingState _loadingState = LoadingState.initial;
  String? _errorMessage;

  // Getters
  List<Product> get products => _getFilteredProducts();
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get hasError => _loadingState == LoadingState.error;
  bool get isEmpty => _products.isEmpty && _loadingState == LoadingState.loaded;

  List<Product> _getFilteredProducts() {
    List<Product> filtered = _products;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) =>
        product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        product.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        product.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  // Methods to manage loading states
  void _setLoadingState(LoadingState state, {String? error}) {
    _loadingState = state;
    _errorMessage = error;
    notifyListeners();
  }

  // Public methods
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadSampleProducts() async {
    try {
      _setLoadingState(LoadingState.loading);

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Clear existing data
      _products.clear();
      _categories.clear();

      // Add sample products
      _products.addAll([
        Product(
          id: '1',
          name: 'iPhone 15 Pro',
          description: 'The latest iPhone with A17 Pro chip and 48MP camera',
          price: 1199.99,
          imageUrl: 'assets/images/products/iphone.svg',
          category: 'Electronics',
          rating: 4.8,
          reviewCount: 1247,
        ),
        Product(
          id: '2',
          name: 'MacBook Air M2',
          description: 'Ultra-lightweight laptop with M2 chip',
          price: 1299.99,
          imageUrl: 'assets/images/products/macbook.svg',
          category: 'Electronics',
          rating: 4.9,
          reviewCount: 892,
        ),
        Product(
          id: '3',
          name: 'Nike Air Max',
          description: 'Comfortable and stylish sports shoes',
          price: 129.99,
          imageUrl: 'assets/images/products/nike-shoes.svg',
          category: 'Fashion',
          rating: 4.6,
          reviewCount: 567,
        ),
        Product(
          id: '4',
          name: 'Samsung Galaxy S24',
          description: 'Android smartphone with integrated AI',
          price: 899.99,
          imageUrl: 'assets/images/products/samsung.svg',
          category: 'Electronics',
          rating: 4.7,
          reviewCount: 743,
        ),
        Product(
          id: '5',
          name: 'Adidas T-Shirt',
          description: 'Sports t-shirt in organic cotton',
          price: 29.99,
          imageUrl: 'assets/images/products/adidas-tshirt.svg',
          category: 'Fashion',
          rating: 4.5,
          reviewCount: 234,
        ),
        Product(
          id: '6',
          name: 'Sony WH-1000XM5',
          description: 'Wireless headphones with noise cancellation',
          price: 349.99,
          imageUrl: 'assets/images/products/sony-headphones.svg',
          category: 'Electronics',
          rating: 4.8,
          reviewCount: 456,
        ),
      ]);

      // Extract categories from products
      _categories.addAll(_products.map((product) => product.category).toSet());
      if (!_categories.contains('All')) {
        _categories.insert(0, 'All');
      }

      _setLoadingState(LoadingState.loaded);
    } catch (error) {
      debugPrint('Error loading products: $error');
      _setLoadingState(LoadingState.error, error: 'Failed to load products. Please try again.');
    }
  }

  Future<void> refreshProducts() async {
    await loadSampleProducts();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String category) {
    if (category == 'All') return _products;
    return _products.where((product) => product.category == category).toList();
  }

  List<Product> getFeaturedProducts() {
    return _products.where((product) => product.rating >= 4.0).toList();
  }

  List<Product> getNewArrivals() {
    // In a real app, you'd sort by creation date
    // For demo purposes, return first 6 products
    return _products.take(6).toList();
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    notifyListeners();
  }
}
