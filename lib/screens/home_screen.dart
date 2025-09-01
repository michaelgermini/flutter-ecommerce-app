import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/product_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/micro_interactions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero banner
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SvgPicture.asset(
                  'assets/images/banners/welcome-banner.svg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      'Shop Now',
                      Icons.shopping_bag,
                      () => appProvider.navigateToProducts(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      'Categories',
                      Icons.category,
                      () => appProvider.navigateToProducts(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Categories
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: CategoryChips(
                categories: productProvider.categories,
                selectedCategory: productProvider.selectedCategory,
                onCategorySelected: (category) {
                  productProvider.setSelectedCategory(category);
                  appProvider.navigateToProducts();
                },
              ),
            ),
          ),

          // Featured Products
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Featured Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final products = productProvider.getFeaturedProducts();
                  if (index >= products.length) return null;

                  return ProductCard(
                    product: products[index],
                    onTap: () {
                      // TODO: Navigate to product details
                    },
                  );
                },
                childCount: productProvider.getFeaturedProducts().length,
              ),
            ),
          ),

          // New Arrivals
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'New Arrivals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
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

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return MicroInteractions.animatedButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
