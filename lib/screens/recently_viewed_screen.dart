import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/micro_interactions.dart';
import '../services/notification_service.dart';

class RecentlyViewedScreen extends StatefulWidget {
  const RecentlyViewedScreen({super.key});

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Viewed'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
          ],
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        actions: [
          Consumer<RecentlyViewedProvider>(
            builder: (context, recentlyViewedProvider, child) {
              if (recentlyViewedProvider.recentlyViewedProducts.isEmpty) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear_all':
                      _showClearAllDialog(context, recentlyViewedProvider);
                      break;
                    case 'view_stats':
                      _showStatsDialog(context, recentlyViewedProvider);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'view_stats',
                    child: Row(
                      children: [
                        Icon(Icons.analytics, size: 20),
                        SizedBox(width: 12),
                        Text('View Statistics'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, size: 20),
                        SizedBox(width: 12),
                        Text('Clear All'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<RecentlyViewedProvider>(
        builder: (context, recentlyViewedProvider, child) {
          if (recentlyViewedProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRecentlyViewedList(recentlyViewedProvider.recentlyViewedProducts),
              _buildRecentlyViewedList(_getTodayProducts(recentlyViewedProvider)),
              _buildRecentlyViewedList(_getThisWeekProducts(recentlyViewedProvider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentlyViewedList(List products) {
    final theme = Theme.of(context);

    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(const Duration(seconds: 1));
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(product: product);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.history,
              size: 40,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No recently viewed products',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Products you view will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/products');
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Browse Products'),
            style: ElevatedButton.styleFrom(
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

  List _getTodayProducts(RecentlyViewedProvider provider) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Since we don't have timestamps in the current product model,
    // we'll just return the first few products as a simulation
    return provider.recentlyViewedProducts.take(5).toList();
  }

  List _getThisWeekProducts(RecentlyViewedProvider provider) {
    // Since we don't have timestamps in the current product model,
    // we'll just return the first 10 products as a simulation
    return provider.recentlyViewedProducts.take(10).toList();
  }

  void _showClearAllDialog(BuildContext context, RecentlyViewedProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Recently Viewed'),
          content: const Text(
            'Are you sure you want to clear all recently viewed products? This action cannot be undone.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.clearRecentlyViewed();
                Navigator.of(context).pop();
                _notificationService.showSuccess(
                  context,
                  'Cleared',
                  'Recently viewed products have been cleared',
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _showStatsDialog(BuildContext context, RecentlyViewedProvider provider) {
    final stats = provider.getCategoryStats();
    final avgPrice = provider.getAveragePrice();
    final popularCategories = provider.getPopularCategories(limit: 3);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Viewing Statistics'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Products Viewed: ${provider.count}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Average Price: \$${avgPrice.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                const Text(
                  'Popular Categories:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...popularCategories.map((category) {
                  final count = stats[category] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $category ($count products)'),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
