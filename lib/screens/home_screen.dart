import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/micro_interactions.dart';
import '../widgets/hero_section.dart';
import '../widgets/modern_header.dart';
import '../widgets/loading_states.dart';
import '../widgets/footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadSampleProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final appProvider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: CustomScrollView(
        slivers: [
          // Modern header
          SliverAppBar(
            expandedHeight: 90,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Welcome Back!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.05),
                      const Color(0xFFEC4899).withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Hero section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: HeroSection(
                title: 'Discover Amazing Products',
                subtitle: 'Shop the latest trends with our curated collection of premium products',
                buttonText: 'Explore Now',
                onButtonPressed: () => appProvider.navigateToProducts(),
              ),
            ),
          ),

          // Categories section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop by Category',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CategoryCard(
                          title: 'Electronics',
                          icon: Icons.phone_android,
                          color: const Color(0xFF6366F1),
                          onTap: () {
                            productProvider.setSelectedCategory('Electronics');
                            appProvider.navigateToProducts();
                          },
                        ),
                        const SizedBox(width: 12),
                        CategoryCard(
                          title: 'Fashion',
                          icon: Icons.checkroom,
                          color: const Color(0xFFEC4899),
                          onTap: () {
                            productProvider.setSelectedCategory('Fashion');
                            appProvider.navigateToProducts();
                          },
                        ),
                        const SizedBox(width: 12),
                        CategoryCard(
                          title: 'Home',
                          icon: Icons.home,
                          color: const Color(0xFF10B981),
                          onTap: () {
                            productProvider.setSelectedCategory('Home');
                            appProvider.navigateToProducts();
                          },
                        ),
                        const SizedBox(width: 12),
                        CategoryCard(
                          title: 'Sports',
                          icon: Icons.sports_soccer,
                          color: const Color(0xFFF59E0B),
                          onTap: () {
                            productProvider.setSelectedCategory('Sports');
                            appProvider.navigateToProducts();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Features section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why Choose Us',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FeatureCard(
                    title: 'Free Shipping',
                    description: 'Free shipping on orders over \$50',
                    icon: Icons.local_shipping,
                    color: Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 12),
                  const FeatureCard(
                    title: 'Secure Payment',
                    description: '100% secure payment processing',
                    icon: Icons.security,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(height: 12),
                  const FeatureCard(
                    title: '24/7 Support',
                    description: 'Round the clock customer support',
                    icon: Icons.support_agent,
                    color: Color(0xFFEC4899),
                  ),
                ],
              ),
            ),
          ),

          // Featured Products
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Products',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => appProvider.navigateToProducts(),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: const Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Products Grid with Loading States
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: Builder(
              builder: (context) {
                if (productProvider.isLoading) {
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 2 : 3,
                      childAspectRatio: isSmallScreen ? 1.2 : 1.0,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => LoadingStates.productSkeleton(),
                      childCount: isSmallScreen ? 4 : 6, // Adapt count based on screen size
                    ),
                  );
                }

                if (productProvider.hasError) {
                  return SliverToBoxAdapter(
                    child: LoadingStates.errorState(
                      message: 'Failed to load products',
                      subMessage: productProvider.errorMessage ?? 'Please check your connection and try again.',
                      onRetry: () => productProvider.refreshProducts(),
                    ),
                  );
                }

                if (productProvider.isEmpty) {
                  return SliverToBoxAdapter(
                    child: LoadingStates.emptyState(
                      message: 'No products found',
                      subMessage: 'We\'re working on adding new products.',
                      icon: Icons.inventory_2_outlined,
                    ),
                  );
                }

                final products = productProvider.getFeaturedProducts();
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen ? 2 : 3,
                    childAspectRatio: isSmallScreen ? 1.2 : 1.0,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= products.length) return null;
                      return ProductCard(
                        product: products[index],
                        onTap: () {
                          // TODO: Navigate to product details
                        },
                      );
                    },
                    childCount: products.length,
                  ),
                );
              },
            ),
          ),

          // New Arrivals (only show if not loading or error)
          if (!productProvider.isLoading && !productProvider.hasError && !productProvider.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'New Arrivals',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFF1F2937),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => appProvider.navigateToProducts(),
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: const Color(0xFF6366F1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // New Arrivals Grid
          if (!productProvider.isLoading && !productProvider.hasError && !productProvider.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isSmallScreen ? 2 : 3,
                  childAspectRatio: isSmallScreen ? 1.2 : 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final products = productProvider.getNewArrivals();
                    if (index >= products.length) return null;

                    return ProductCard(
                      product: products[index],
                      onTap: () {
                        // TODO: Navigate to product details
                      },
                    );
                  },
                  childCount: productProvider.getNewArrivals().length,
                ),
              ),
            ),

          // Footer
          const SliverToBoxAdapter(
            child: Footer(),
          ),
        ],
        ),
      ),
    );
  }
}
