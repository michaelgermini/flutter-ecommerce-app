import 'package:flutter/material.dart';

enum AppPage {
  home,
  products,
  cart,
  profile,
  orders,
  wishlist,
  search,
  notifications,
  recentlyViewed,
  comparison,
  loyalty,
  recommendations,
  accessibility,
  help,
  settings,
}

class AppProvider with ChangeNotifier {
  AppPage _currentPage = AppPage.home;
  bool _isLoading = false;
  String? _errorMessage;

  AppPage get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setCurrentPage(AppPage page) {
    _currentPage = page;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Navigation helpers
  bool get isHomePage => _currentPage == AppPage.home;
  bool get isProductsPage => _currentPage == AppPage.products;
  bool get isCartPage => _currentPage == AppPage.cart;
  bool get isProfilePage => _currentPage == AppPage.profile;
  bool get isOrdersPage => _currentPage == AppPage.orders;
  bool get isWishlistPage => _currentPage == AppPage.wishlist;
  bool get isSearchPage => _currentPage == AppPage.search;
  bool get isNotificationsPage => _currentPage == AppPage.notifications;
  bool get isRecentlyViewedPage => _currentPage == AppPage.recentlyViewed;
  bool get isComparisonPage => _currentPage == AppPage.comparison;
  bool get isLoyaltyPage => _currentPage == AppPage.loyalty;
  bool get isRecommendationsPage => _currentPage == AppPage.recommendations;
  bool get isAccessibilityPage => _currentPage == AppPage.accessibility;
  bool get isHelpPage => _currentPage == AppPage.help;
  bool get isSettingsPage => _currentPage == AppPage.settings;

  void navigateToHome() => setCurrentPage(AppPage.home);
  void navigateToProducts() => setCurrentPage(AppPage.products);
  void navigateToCart() => setCurrentPage(AppPage.cart);
  void navigateToProfile() => setCurrentPage(AppPage.profile);
  void navigateToOrders() => setCurrentPage(AppPage.orders);
  void navigateToWishlist() => setCurrentPage(AppPage.wishlist);
  void navigateToSearch() => setCurrentPage(AppPage.search);
  void navigateToNotifications() => setCurrentPage(AppPage.notifications);
  void navigateToRecentlyViewed() => setCurrentPage(AppPage.recentlyViewed);
  void navigateToComparison() => setCurrentPage(AppPage.comparison);
  void navigateToLoyalty() => setCurrentPage(AppPage.loyalty);
  void navigateToRecommendations() => setCurrentPage(AppPage.recommendations);
  void navigateToAccessibility() => setCurrentPage(AppPage.accessibility);
  void navigateToHelp() => setCurrentPage(AppPage.help);
  void navigateToSettings() => setCurrentPage(AppPage.settings);
}
