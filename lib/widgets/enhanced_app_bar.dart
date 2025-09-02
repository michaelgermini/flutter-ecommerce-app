import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/accessibility_provider.dart';
import '../screens/wishlist_screen.dart';
import '../screens/recommendations_screen.dart';
import '../screens/accessibility_screen.dart';
import 'micro_interactions.dart';

class EnhancedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EnhancedAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Logo/Brand Section
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shopping_bag,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ShopHub',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Premium Shopping',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                children: [
                  // Search Button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: MicroInteractions.animatedIconButton(
                      icon: Icons.search,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdvancedSearchScreen(),
                          ),
                        );
                      },
                      size: 20,
                    ),
                  ),

                  // Wishlist Button with Badge
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlistProvider, child) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: MicroInteractions.animatedIconButton(
                                icon: Icons.favorite_border,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const WishlistScreen(),
                                    ),
                                  );
                                },
                                size: 20,
                              ),
                            ),
                            if (wishlistProvider.itemCount > 0)
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    wishlistProvider.itemCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Cart Button with Badge
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: MicroInteractions.animatedIconButton(
                                icon: Icons.shopping_cart_outlined,
                                onPressed: () {
                                  appProvider.navigateToCart();
                                },
                                size: 20,
                              ),
                            ),
                            if (cartProvider.itemCount > 0)
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    cartProvider.itemCount.toString(),
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Recently Viewed
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Consumer<RecentlyViewedProvider>(
                      builder: (context, recentlyViewedProvider, child) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: MicroInteractions.animatedIconButton(
                                icon: Icons.history,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const RecentlyViewedScreen(),
                                    ),
                                  );
                                },
                                size: 20,
                              ),
                            ),
                            if (recentlyViewedProvider.count > 0)
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    recentlyViewedProvider.count > 99
                                        ? '99+'
                                        : recentlyViewedProvider.count.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Product Comparison
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Consumer<ProductComparisonProvider>(
                      builder: (context, comparisonProvider, child) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: MicroInteractions.animatedIconButton(
                                icon: Icons.compare_arrows,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ProductComparisonScreen(),
                                    ),
                                  );
                                },
                                size: 20,
                              ),
                            ),
                            if (comparisonProvider.count > 0)
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    comparisonProvider.count.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Loyalty Program
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Consumer<LoyaltyProvider>(
                      builder: (context, loyaltyProvider, child) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: MicroInteractions.animatedIconButton(
                                icon: Icons.loyalty,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const LoyaltyScreen(),
                                    ),
                                  );
                                },
                                size: 20,
                              ),
                            ),
                            if (loyaltyProvider.loyaltyPoints.currentPoints > 0)
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: loyaltyProvider.loyaltyPoints.tierColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    loyaltyProvider.loyaltyPoints.currentPoints > 999
                                        ? '999+'
                                        : loyaltyProvider.loyaltyPoints.currentPoints.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Recommendations (For You)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Consumer<RecommendationProvider>(
                      builder: (context, recommendationProvider, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: MicroInteractions.animatedIconButton(
                            icon: Icons.lightbulb,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RecommendationsScreen(),
                                ),
                              );
                            },
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),

                  // Accessibility Settings
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Consumer<AccessibilityProvider>(
                      builder: (context, accessibilityProvider, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: MicroInteractions.animatedIconButton(
                            icon: Icons.accessibility,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AccessibilityScreen(),
                                ),
                              );
                            },
                            size: 20,
                            tooltip: 'Accessibility Settings',
                          ),
                        );
                      },
                    ),
                  ),

                  // Notification Bell
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, child) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: MicroInteractions.animatedIconButton(
                                icon: Icons.notifications_none,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const NotificationCenterScreen(),
                                    ),
                                  );
                                },
                                size: 20,
                              ),
                            ),
                            if (notificationProvider.unreadCount > 0)
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    notificationProvider.unreadCount > 99
                                        ? '99+'
                                        : notificationProvider.unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Theme Toggle Button
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: MicroInteractions.animatedIconButton(
                            icon: themeProvider.isDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            onPressed: () {
                              themeProvider.toggleTheme();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    themeProvider.isDarkMode
                                        ? '🌙 Switched to Dark Mode'
                                        : '☀️ Switched to Light Mode',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),

                  // Profile Menu
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'profile':
                            appProvider.navigateToProfile();
                            break;
                          case 'orders':
                            appProvider.navigateToOrders();
                            break;
                          case 'help':
                            // Navigate to help screen
                            break;
                          case 'settings':
                            // Navigate to settings screen
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person, size: 20),
                              SizedBox(width: 12),
                              Text('Profile'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'orders',
                          child: Row(
                            children: [
                              Icon(Icons.receipt, size: 20),
                              SizedBox(width: 12),
                              Text('My Orders'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'help',
                          child: Row(
                            children: [
                              Icon(Icons.help, size: 20),
                              SizedBox(width: 12),
                              Text('Help & Support'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings, size: 20),
                              SizedBox(width: 12),
                              Text('Settings'),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
