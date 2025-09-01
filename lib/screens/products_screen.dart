import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/modern_header.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final filteredProducts = productProvider.filteredProducts;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: ModernHeader(
        title: 'Products',
        showCart: true,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F2937).withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                suffixIcon: productProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                        onPressed: () {
                          _searchController.clear();
                          productProvider.setSearchQuery('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                productProvider.setSearchQuery(value);
              },
            ),
          ),

          // Categories with modern design
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F2937).withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CategoryChips(
              categories: productProvider.categories,
              selectedCategory: productProvider.selectedCategory,
              onCategorySelected: productProvider.setSelectedCategory,
            ),
          ),

          // Results count and filters
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${filteredProducts.length} products',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ),
                const Spacer(),
                if (productProvider.selectedCategory != 'All' ||
                    productProvider.searchQuery.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      productProvider.clearFilters();
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear filters'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Products grid
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : _buildProductsGrid(filteredProducts),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2937).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters to find what you\'re looking for',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ProductProvider>().clearFilters();
              _searchController.clear();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(List filteredProducts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        crossAxisCount: _getCrossAxisCount(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return ProductCard(
            product: product,
            onTap: () {
              // TODO: Navigate to product details
            },
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }
}
