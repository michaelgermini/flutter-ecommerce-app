import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/search_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/recently_viewed_provider.dart';
import 'providers/product_comparison_provider.dart';
import 'providers/loyalty_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/accessibility_provider.dart';
import 'screens/adaptive_home_screen.dart';
import 'widgets/keyboard_shortcut_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
        ChangeNotifierProvider(create: (_) => ProductComparisonProvider()),
        ChangeNotifierProvider(create: (_) => LoyaltyProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProxyProvider5<ProductProvider, RecentlyViewedProvider, WishlistProvider, CartProvider, LoyaltyProvider, RecommendationProvider>(
          create: (context) => RecommendationProvider(
            productProvider: context.read<ProductProvider>(),
            recentlyViewedProvider: context.read<RecentlyViewedProvider>(),
            wishlistProvider: context.read<WishlistProvider>(),
            cartProvider: context.read<CartProvider>(),
          ),
          update: (context, productProvider, recentlyViewedProvider, wishlistProvider, cartProvider, loyaltyProvider, recommendationProvider) => recommendationProvider ?? RecommendationProvider(
            productProvider: productProvider,
            recentlyViewedProvider: recentlyViewedProvider,
            wishlistProvider: wishlistProvider,
            cartProvider: cartProvider,
          ),
        ),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return KeyboardShortcutHandler(
            child: MaterialApp(
              title: 'E-Commerce Shop',
              theme: themeProvider.currentTheme,
              home: const AppInitializer(),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}

class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce App'),
      ),
      body: const Center(
        child: Text(
          'Application chargée avec succès !',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Load sample data and wishlist with proper error handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final productProvider = context.read<ProductProvider>();
          final searchProvider = context.read<SearchProvider>();
          final wishlistProvider = context.read<WishlistProvider>();

          productProvider.loadSampleProducts();

          // Wait for products to load, then set them in search provider
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              searchProvider.setProducts(productProvider.products);
            }
          });

          wishlistProvider.loadWishlistFromStorage();
        } catch (e) {
          // Handle any initialization errors gracefully
          debugPrint('Error initializing app: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const AdaptiveHomeScreen();
  }
}
