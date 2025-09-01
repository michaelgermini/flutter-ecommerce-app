import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/micro_interactions.dart';
import 'home_screen.dart';
import 'products_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';

class AdaptiveHomeScreen extends StatelessWidget {
  const AdaptiveHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return AdaptiveScaffold(
      // App Bar - adapts to screen size  
      appBar: AppBar(
        title: const Text('E-Commerce Shop'),
        actions: [
          // Cart icon with badge
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  MicroInteractions.animatedIconButton(
                    icon: Icons.shopping_cart,
                    onPressed: () {
                      appProvider.navigateToCart();
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: MicroInteractions.animatedCounter(
                        count: cartProvider.itemCount,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              );
            },
          ),
          MicroInteractions.animatedIconButton(
            icon: Icons.search,
            onPressed: () {
              appProvider.navigateToProducts();
            },
          ),
        ],
      ),

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
    }
  }
}