import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [];
  final List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<Product> get products => [
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
  ];
  List<String> get categories => List.unmodifiable(_categories);
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get filteredProducts {
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

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    notifyListeners();
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
    // For demo purposes, return first 10 products
    return _products.take(10).toList();
  }

  // Load sample products for demo
  void loadSampleProducts() {
    final sampleProducts = [
      Product(
        id: '1',
        name: 'iPhone 15 Pro',
        description: 'The most advanced iPhone yet with titanium design and A17 Pro chip.',
        price: 999.99,
        imageUrl: 'assets/images/products/iphone.svg',
        category: 'Electronics',
        rating: 4.8,
        reviewCount: 245,
        isInStock: true,
        stockQuantity: 50,
        images: [
          'assets/images/products/iphone.svg',
          'assets/images/products/iphone.svg',
        ],
        specifications: {
          'Display': '6.1-inch Super Retina XDR',
          'Storage': '128GB',
          'Camera': '48MP Main, 12MP Ultra Wide',
          'Battery': 'Up to 23 hours video playback',
        },
      ),
      Product(
        id: '2',
        name: 'MacBook Air M3',
        description: 'Supercharged by the M3 chip. Up to 18 hours of battery life.',
        price: 1099.99,
        imageUrl: 'assets/images/products/macbook.svg',
        category: 'Electronics',
        rating: 4.9,
        reviewCount: 189,
        isInStock: true,
        stockQuantity: 30,
        specifications: {
          'Processor': 'Apple M3 chip',
          'Memory': '8GB unified memory',
          'Storage': '256GB SSD',
          'Display': '13.6-inch Liquid Retina',
        },
      ),
      Product(
        id: '3',
        name: 'Nike Air Max',
        description: 'Classic running shoes with responsive cushioning and iconic style.',
        price: 129.99,
        imageUrl: 'assets/images/products/nike-shoes.svg',
        category: 'Sports & Outdoors',
        rating: 4.5,
        reviewCount: 892,
        isInStock: true,
        stockQuantity: 100,
        specifications: {
          'Size': 'US 7-13',
          'Material': 'Synthetic/Mesh',
          'Sole': 'Rubber outsole',
          'Style': 'Running/Casual',
        },
      ),
      Product(
        id: '4',
        name: 'Sony WH-1000XM5',
        description: 'Industry-leading noise canceling with premium sound quality.',
        price: 349.99,
        imageUrl: 'assets/images/products/sony-headphones.svg',
        category: 'Electronics',
        rating: 4.7,
        reviewCount: 456,
        isInStock: true,
        stockQuantity: 75,
        specifications: {
          'Driver': '30mm',
          'Battery': '30 hours',
          'Connectivity': 'Bluetooth 5.2',
          'Weight': '250g',
        },
      ),
      Product(
        id: '5',
        name: 'Adidas T-Shirt',
        description: 'Sports t-shirt in organic cotton.',
        price: 79.99,
        imageUrl: 'assets/images/products/adidas-tshirt.svg',
        category: 'Clothing',
        rating: 4.3,
        reviewCount: 1243,
        isInStock: true,
        stockQuantity: 200,
        specifications: {
          'Fit': 'Regular',
          'Material': '100% Cotton',
          'Style': 'Sports',
          'Care': 'Machine wash',
        },
      ),
      Product(
        id: '6',
        name: 'Samsung Galaxy S24',
        description: '7-in-1 electric pressure cooker for fast, easy cooking.',
        price: 89.99,
        imageUrl: 'assets/images/products/samsung.svg',
        category: 'Electronics',
        rating: 4.6,
        reviewCount: 2156,
        isInStock: true,
        stockQuantity: 60,
        specifications: {
          'Display': '6.2-inch Dynamic AMOLED',
          'Storage': '128GB',
          'Camera': '50MP Main, 12MP Ultra Wide',
          'Battery': '4000mAh',
        },
      ),
    ];

    _products.clear();
    _products.addAll(sampleProducts);

    // Extract unique categories
    _categories.clear();
    _categories.add('All');
    _categories.addAll(sampleProducts.map((p) => p.category).toSet().toList());

    notifyListeners();
  }
}
