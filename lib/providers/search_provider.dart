import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';
import '../models/search_filters.dart';

class SearchProvider with ChangeNotifier {
  static const String _searchHistoryKey = 'search_history';
  static const String _recentFiltersKey = 'recent_filters';

  List<Product> _searchResults = [];
  List<Product> _allProducts = [];
  bool _isLoading = false;
  String _errorMessage = '';
  SearchFilters _currentFilters = const SearchFilters();
  List<SearchHistoryItem> _searchHistory = [];
  bool _showFilters = false;
  bool _showSuggestions = false;
  List<String> _suggestions = [];

  // Getters
  List<Product> get searchResults => _searchResults;
  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  SearchFilters get currentFilters => _currentFilters;
  List<SearchHistoryItem> get searchHistory => _searchHistory;
  bool get showFilters => _showFilters;
  bool get showSuggestions => _showSuggestions;
  List<String> get suggestions => _suggestions;

  SearchProvider() {
    _loadSearchHistory();
    _loadRecentFilters();
    _generateSuggestions();
  }

  // Load products from ProductProvider
  void setProducts(List<Product> products) {
    _allProducts = products;
    notifyListeners();
  }

  // Search functionality
  Future<void> search(String query, {SearchFilters? filters}) async {
    if (query.isEmpty && !(filters?.hasActiveFilters ?? false)) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      SearchFilters effectiveFilters = filters ?? _currentFilters;

      // Apply search query
      List<Product> results = _allProducts.where((product) {
        if (query.isNotEmpty) {
          final queryLower = query.toLowerCase();
          final nameMatch = product.name.toLowerCase().contains(queryLower);
          final descriptionMatch = product.description.toLowerCase().contains(queryLower);
          final categoryMatch = product.category.toLowerCase().contains(queryLower);

          if (!nameMatch && !descriptionMatch && !categoryMatch) {
            return false;
          }
        }

        // Apply filters
        if (effectiveFilters.minPrice != null && product.price < effectiveFilters.minPrice!) {
          return false;
        }
        if (effectiveFilters.maxPrice != null && product.price > effectiveFilters.maxPrice!) {
          return false;
        }
        if (effectiveFilters.categories.isNotEmpty && !effectiveFilters.categories.contains(product.category)) {
          return false;
        }
        if (effectiveFilters.minRating != null && product.rating < effectiveFilters.minRating!) {
          return false;
        }
        if (effectiveFilters.brands.isNotEmpty && !effectiveFilters.brands.contains(product.brand)) {
          return false;
        }
        if (effectiveFilters.inStockOnly && !product.inStock) {
          return false;
        }
        if (effectiveFilters.onSaleOnly && !product.onSale) {
          return false;
        }

        return true;
      }).toList();

      // Apply sorting
      _sortResults(results, effectiveFilters.sortBy, effectiveFilters.sortAscending);

      _searchResults = results;

      // Add to search history if query is not empty
      if (query.isNotEmpty) {
        _addToSearchHistory(query, results.length);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Search failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _sortResults(List<Product> results, String sortBy, bool ascending) {
    switch (sortBy) {
      case 'price_low':
        results.sort((a, b) => ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
        break;
      case 'price_high':
        results.sort((a, b) => ascending ? b.price.compareTo(a.price) : a.price.compareTo(b.price));
        break;
      case 'rating':
        results.sort((a, b) => ascending ? b.rating.compareTo(a.rating) : a.rating.compareTo(b.rating));
        break;
      case 'newest':
        // Assuming products have a date field, for now we'll sort by ID
        results.sort((a, b) => ascending ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
        break;
      case 'popular':
        // For now, sort by rating as a proxy for popularity
        results.sort((a, b) => ascending ? b.rating.compareTo(a.rating) : a.rating.compareTo(b.rating));
        break;
      default:
        // Relevance or default sorting
        break;
    }
  }

  // Filter management
  void updateFilters(SearchFilters newFilters) {
    _currentFilters = newFilters;
    _saveRecentFilters();
    notifyListeners();
  }

  void clearFilters() {
    _currentFilters = const SearchFilters();
    notifyListeners();
  }

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  // Search history
  void _addToSearchHistory(String query, int resultCount) {
    final existingIndex = _searchHistory.indexWhere((item) => item.query == query);

    if (existingIndex != -1) {
      // Update existing entry
      final existingItem = _searchHistory[existingIndex];
      _searchHistory[existingIndex] = SearchHistoryItem(
        query: query,
        timestamp: DateTime.now(),
        resultCount: resultCount,
      );
      _searchHistory.removeAt(existingIndex);
    } else {
      // Add new entry
      _searchHistory.insert(0, SearchHistoryItem(
        query: query,
        timestamp: DateTime.now(),
        resultCount: resultCount,
      ));

      // Keep only last 10 searches
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    }

    _saveSearchHistory();
    notifyListeners();
  }

  void removeFromSearchHistory(String query) {
    _searchHistory.removeWhere((item) => item.query == query);
    _saveSearchHistory();
    notifyListeners();
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    _saveSearchHistory();
    notifyListeners();
  }

  // Suggestions
  void _generateSuggestions() {
    final allQueries = _searchHistory.map((item) => item.query).toSet();
    final allCategories = _allProducts.map((product) => product.category).toSet();
    final allBrands = _allProducts.map((product) => product.brand).toSet();

    _suggestions = [
      ...allQueries,
      ...allCategories,
      ...allBrands,
    ].toList();
  }

  void updateSuggestions(String query) {
    if (query.isEmpty) {
      _showSuggestions = false;
    } else {
      _showSuggestions = true;
      _suggestions = _searchHistory
          .where((item) => item.query.toLowerCase().contains(query.toLowerCase()))
          .map((item) => item.query)
          .toList();
    }
    notifyListeners();
  }

  void hideSuggestions() {
    _showSuggestions = false;
    notifyListeners();
  }

  // Persistence
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_searchHistoryKey);
      if (historyJson != null) {
        final historyList = json.decode(historyJson) as List;
        _searchHistory = historyList.map((item) => SearchHistoryItem.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(_searchHistory.map((item) => item.toJson()).toList());
      await prefs.setString(_searchHistoryKey, historyJson);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  Future<void> _loadRecentFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_recentFiltersKey);
      if (filtersJson != null) {
        _currentFilters = SearchFilters.fromJson(json.decode(filtersJson));
      }
    } catch (e) {
      debugPrint('Error loading recent filters: $e');
    }
  }

  Future<void> _saveRecentFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = json.encode(_currentFilters.toJson());
      await prefs.setString(_recentFiltersKey, filtersJson);
    } catch (e) {
      debugPrint('Error saving recent filters: $e');
    }
  }

  // Clear all data
  void clearAllData() {
    _searchResults.clear();
    _searchHistory.clear();
    _currentFilters = const SearchFilters();
    _showFilters = false;
    _showSuggestions = false;
    _errorMessage = '';

    _saveSearchHistory();
    _saveRecentFilters();
    notifyListeners();
  }
}
