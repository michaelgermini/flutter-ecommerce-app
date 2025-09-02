import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/micro_interactions.dart';
import '../widgets/enhanced_app_bar.dart';
import 'home_screen.dart';
import 'products_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'help_screen.dart';
import 'settings_screen.dart';
import 'advanced_search_screen.dart';
import 'notification_center_screen.dart';
import 'recently_viewed_screen.dart';
import 'product_comparison_screen.dart';
import 'loyalty_screen.dart';
import 'recommendations_screen.dart';
import 'accessibility_screen.dart';

class AdaptiveHomeScreen extends StatelessWidget {
  const AdaptiveHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return AdaptiveScaffold(
      // Enhanced App Bar with modern design
      appBar: const EnhancedAppBar(),

      // Navigation destinations
      destinations: _getDestinations(),
      selectedIndex: _getCurrentIndex(appProvider.currentPage),
      onSelectedIndexChange: (index) {
        appProvider.setCurrentPage(_getPageFromIndex(index));
      },

      // Main body content
      body: (_) => _getCurrentScreen(appProvider.currentPage),
    );
  }

  List<NavigationDestination> _getDestinations() {
    return const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: 'Products',
      ),
      NavigationDestination(
        icon: Icon(Icons.shopping_cart_outlined),
        selectedIcon: Icon(Icons.shopping_cart),
        label: 'Cart',
      ),
      NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'Orders',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outlined),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
      NavigationDestination(
        icon: Icon(Icons.favorite_border),
        selectedIcon: Icon(Icons.favorite),
        label: 'Wishlist',
      ),
    ];
  }

  int _getCurrentIndex(AppPage page) {
    switch (page) {
      case AppPage.home:
        return 0;
      case AppPage.products:
        return 1;
      case AppPage.cart:
        return 2;
      case AppPage.orders:
        return 3;
      case AppPage.profile:
        return 4;
      case AppPage.wishlist:
        return 5;
      case AppPage.search:
        return 6;
      case AppPage.notifications:
        return 7;
      case AppPage.recentlyViewed:
        return 8;
      case AppPage.comparison:
        return 9;
      case AppPage.loyalty:
        return 10;
      case AppPage.recommendations:
        return 11;
      case AppPage.accessibility:
        return 12;
      case AppPage.help:
        return 13;
      case AppPage.settings:
        return 14;
    }
  }

  AppPage _getPageFromIndex(int index) {
    switch (index) {
      case 0:
        return AppPage.home;
      case 1:
        return AppPage.products;
      case 2:
        return AppPage.cart;
      case 3:
        return AppPage.orders;
      case 4:
        return AppPage.profile;
      case 5:
        return AppPage.wishlist;
      default:
        return AppPage.home;
    }
  }

  Widget _getCurrentScreen(AppPage page) {
    switch (page) {
      case AppPage.home:
        return const HomeScreen();
      case AppPage.products:
        return const ProductsScreen();
      case AppPage.cart:
        return const CartScreen();
      case AppPage.orders:
        return const OrdersScreen();
      case AppPage.profile:
        return const ProfileScreen();
      case AppPage.wishlist:
        return const WishlistScreen();
      case AppPage.search:
        return const AdvancedSearchScreen();
      case AppPage.notifications:
        return const NotificationCenterScreen();
      case AppPage.recentlyViewed:
        return const RecentlyViewedScreen();
      case AppPage.comparison:
        return const ProductComparisonScreen();
      case AppPage.loyalty:
        return const LoyaltyScreen();
      case AppPage.recommendations:
        return const RecommendationsScreen();
      case AppPage.accessibility:
        return const AccessibilityScreen();
      case AppPage.help:
        return const HelpScreen();
      case AppPage.settings:
        return const SettingsScreen();
    }
  }
}