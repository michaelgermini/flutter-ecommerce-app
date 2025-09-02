class SearchFilters {
  final String query;
  final double? minPrice;
  final double? maxPrice;
  final List<String> categories;
  final double? minRating;
  final List<String> brands;
  final String sortBy;
  final bool sortAscending;
  final bool inStockOnly;
  final bool onSaleOnly;

  const SearchFilters({
    this.query = '',
    this.minPrice,
    this.maxPrice,
    this.categories = const [],
    this.minRating,
    this.brands = const [],
    this.sortBy = 'relevance',
    this.sortAscending = false,
    this.inStockOnly = false,
    this.onSaleOnly = false,
  });

  SearchFilters copyWith({
    String? query,
    double? minPrice,
    double? maxPrice,
    List<String>? categories,
    double? minRating,
    List<String>? brands,
    String? sortBy,
    bool? sortAscending,
    bool? inStockOnly,
    bool? onSaleOnly,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      categories: categories ?? this.categories,
      minRating: minRating ?? this.minRating,
      brands: brands ?? this.brands,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      onSaleOnly: onSaleOnly ?? this.onSaleOnly,
    );
  }

  bool get hasActiveFilters =>
      (minPrice != null && minPrice! > 0) ||
      (maxPrice != null && maxPrice! < 10000) ||
      categories.isNotEmpty ||
      (minRating != null && minRating! > 0) ||
      brands.isNotEmpty ||
      inStockOnly ||
      onSaleOnly;

  void clearFilters() {
    // This would be implemented in the provider
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'categories': categories,
      'minRating': minRating,
      'brands': brands,
      'sortBy': sortBy,
      'sortAscending': sortAscending,
      'inStockOnly': inStockOnly,
      'onSaleOnly': onSaleOnly,
    };
  }

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      query: json['query'] ?? '',
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      categories: List<String>.from(json['categories'] ?? []),
      minRating: json['minRating']?.toDouble(),
      brands: List<String>.from(json['brands'] ?? []),
      sortBy: json['sortBy'] ?? 'relevance',
      sortAscending: json['sortAscending'] ?? false,
      inStockOnly: json['inStockOnly'] ?? false,
      onSaleOnly: json['onSaleOnly'] ?? false,
    );
  }
}

class SearchHistoryItem {
  final String query;
  final DateTime timestamp;
  final int resultCount;

  const SearchHistoryItem({
    required this.query,
    required this.timestamp,
    this.resultCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
    };
  }

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      query: json['query'],
      timestamp: DateTime.parse(json['timestamp']),
      resultCount: json['resultCount'] ?? 0,
    );
  }
}

class SortOption {
  final String value;
  final String label;
  final String icon;

  const SortOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  static const List<SortOption> options = [
    SortOption(value: 'relevance', label: 'Relevance', icon: '🔍'),
    SortOption(value: 'price_low', label: 'Price: Low to High', icon: '💰'),
    SortOption(value: 'price_high', label: 'Price: High to Low', icon: '💎'),
    SortOption(value: 'rating', label: 'Highest Rated', icon: '⭐'),
    SortOption(value: 'newest', label: 'Newest First', icon: '🆕'),
    SortOption(value: 'popular', label: 'Most Popular', icon: '🔥'),
  ];
}
