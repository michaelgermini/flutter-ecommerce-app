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
    _products.clear();
    _categories.clear();

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
          'https://via.placeholder.com/300x300/007AFF/FFFFFF?text=iPhone+15+Pro',
          'https://via.placeholder.com/300x300/007AFF/FFFFFF?text=iPhone+15+Pro+2',
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
        imageUrl: 'https://via.placeholder.com/300x300/000000/FFFFFF?text=MacBook+Air+M3',
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
        imageUrl: 'https://via.placeholder.com/300x300/FF6B35/FFFFFF?text=Nike+Air+Max',
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
        imageUrl: 'https://via.placeholder.com/300x300/000000/FFFFFF?text=Sony+WH-1000XM5',
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
        name: 'Levi\'s 501 Jeans',
        description: 'The original blue jean since 1873. Timeless style and comfort.',
        price: 79.99,
        imageUrl: 'https://via.placeholder.com/300x300/4169E1/FFFFFF?text=Levi%27s+501',
        category: 'Clothing',
        rating: 4.3,
        reviewCount: 1243,
        isInStock: true,
        stockQuantity: 200,
        specifications: {
          'Fit': 'Straight',
          'Material': '100% Cotton',
          'Rise': 'Mid',
          'Care': 'Machine wash',
        },
      ),
      Product(
        id: '6',
        name: 'Instant Pot Duo',
        description: '7-in-1 electric pressure cooker for fast, easy cooking.',
        price: 89.99,
        imageUrl: 'https://via.placeholder.com/300x300/8B4513/FFFFFF?text=Instant+Pot+Duo',
        category: 'Home & Kitchen',
        rating: 4.6,
        reviewCount: 2156,
        isInStock: true,
        stockQuantity: 60,
        specifications: {
          'Capacity': '6 Quart',
          'Functions': 'Pressure Cooker, Slow Cooker, Rice Cooker, Steamer, Sauté, Yogurt Maker, Warmer',
          'Material': 'Stainless Steel',
          'Power': '1200W',
        },
      ),
      Product(
        id: '7',
        name: 'Adidas Ultraboost',
        description: 'Responsive running shoes with energy-returning cushioning.',
        price: 189.99,
        imageUrl: 'https://via.placeholder.com/300x300/000000/FFFFFF?text=Adidas+Ultraboost',
        category: 'Sports & Outdoors',
        rating: 4.4,
        reviewCount: 678,
        isInStock: true,
        stockQuantity: 85,
        specifications: {
          'Technology': 'Boost midsole',
          'Weight': '310g',
          'Drop': '10mm',
          'Use': 'Running/Training',
        },
      ),
      Product(
        id: '8',
        name: 'Dyson V15 Detect',
        description: 'Powerful cordless vacuum with laser dust detection.',
        price: 749.99,
        imageUrl: 'https://via.placeholder.com/300x300/FF0000/FFFFFF?text=Dyson+V15',
        category: 'Home & Kitchen',
        rating: 4.8,
        reviewCount: 342,
        isInStock: true,
        stockQuantity: 25,
        specifications: {
          'Battery': '60 minutes',
          'Filtration': 'Whole-machine HEPA',
          'Weight': '3.1kg',
          'Tools': 'Fluffy head, laser slim flange head',
        },
      ),
    ];

    _products.addAll(sampleProducts);

    // Extract unique categories
    final categorySet = <String>{};
    for (final product in _products) {
      categorySet.add(product.category);
    }
    _categories.addAll(['All', ...categorySet.toList()..sort()]);

    notifyListeners();
  }
}
