import 'package:flutter/material.dart';

enum AppPage {
  home,
  products,
  cart,
  profile,
  orders,
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

  void navigateToHome() => setCurrentPage(AppPage.home);
  void navigateToProducts() => setCurrentPage(AppPage.products);
  void navigateToCart() => setCurrentPage(AppPage.cart);
  void navigateToProfile() => setCurrentPage(AppPage.profile);
  void navigateToOrders() => setCurrentPage(AppPage.orders);
}
