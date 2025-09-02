import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/recommendation_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../models/recommendation.dart';
import '../models/product.dart';
import '../widgets/micro_interactions.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Refresh recommendations when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recommendationProvider = context.read<RecommendationProvider>();
      recommendationProvider.refreshRecommendations();
    });
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
        title: const Text('For You'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Personalized'),
            Tab(text: 'Trending'),
            Tab(text: 'Similar'),
          ],
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        actions: [
          Consumer<RecommendationProvider>(
            builder: (context, recommendationProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'refresh':
                      recommendationProvider.refreshRecommendations();
                      break;
                    case 'stats':
                      _showRecommendationStats(context, recommendationProvider);
                      break;
                    case 'clear':
                      _showClearConfirmation(context, recommendationProvider);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 12),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'stats',
                    child: Row(
                      children: [
                        Icon(Icons.analytics, size: 20),
                        SizedBox(width: 12),
                        Text('View Stats'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, size: 20),
                        SizedBox(width: 12),
                        Text('Clear Data'),
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
      body: Consumer<RecommendationProvider>(
        builder: (context, recommendationProvider, child) {
          if (recommendationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (recommendationProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load recommendations',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recommendationProvider.errorMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => recommendationProvider.refreshRecommendations(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllRecommendations(recommendationProvider),
              _buildPersonalizedRecommendations(recommendationProvider),
              _buildTrendingRecommendations(recommendationProvider),
              _buildSimilarRecommendations(recommendationProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllRecommendations(RecommendationProvider provider) {
    final recommendations = provider.getTopRecommendations(limit: 20);

    if (recommendations.isEmpty) {
      return _buildEmptyState('No recommendations available', 'Start exploring products to get personalized recommendations!');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        return _buildRecommendationCard(recommendations[index]);
      },
    );
  }

  Widget _buildPersonalizedRecommendations(RecommendationProvider provider) {
    final recommendations = provider.getRecommendationsByType(RecommendationType.personalized);

    if (recommendations.isEmpty) {
      return _buildEmptyState('No personalized recommendations yet', 'Keep exploring products and we\'ll learn your preferences!');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        return _buildRecommendationCard(recommendations[index]);
      },
    );
  }

  Widget _buildTrendingRecommendations(RecommendationProvider provider) {
    final recommendations = provider.getRecommendationsByType(RecommendationType.trending);

    if (recommendations.isEmpty) {
      return _buildEmptyState('No trending products', 'Check back later for trending recommendations!');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        return _buildCompactRecommendationCard(recommendations[index]);
      },
    );
  }

  Widget _buildSimilarRecommendations(RecommendationProvider provider) {
    final recommendations = provider.getRecommendationsByType(RecommendationType.similarCategory);

    if (recommendations.isEmpty) {
      return _buildEmptyState('No similar products', 'Explore different categories to see similar recommendations!');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        return _buildCompactRecommendationCard(recommendations[index]);
      },
    );
  }

  Widget _buildRecommendationCard(Recommendation recommendation) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToProduct(recommendation.product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(recommendation.product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recommendation badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            recommendation.typeIcon,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recommendation.typeDisplayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Product name
                    Text(
                      recommendation.product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Price
                    Text(
                      '\$${recommendation.product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Reason
                    if (recommendation.reason.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        recommendation.reason,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Score indicator
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(recommendation.score * 100).round()}% match',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Add to cart button
                  MicroInteractions.animatedIconButton(
                    icon: Icons.add_shopping_cart,
                    onPressed: () => _addToCart(recommendation.product),
                    size: 20,
                  ),

                  // Add to wishlist button
                  Consumer<WishlistProvider>(
                    builder: (context, wishlistProvider, child) {
                      final isInWishlist = wishlistProvider.isInWishlist(recommendation.product.id);
                      return MicroInteractions.animatedIconButton(
                        icon: isInWishlist ? Icons.favorite : Icons.favorite_border,
                        onPressed: () => _toggleWishlist(recommendation.product, wishlistProvider),
                        size: 20,
                        color: isInWishlist ? Colors.red : null,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactRecommendationCard(Recommendation recommendation) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToProduct(recommendation.product),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(
                    image: AssetImage(recommendation.product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Recommendation badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          recommendation.typeIcon,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    // Score indicator
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(recommendation.score * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.product.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${recommendation.product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MicroInteractions.animatedIconButton(
                          icon: Icons.add_shopping_cart,
                          onPressed: () => _addToCart(recommendation.product),
                          size: 18,
                        ),
                        Consumer<WishlistProvider>(
                          builder: (context, wishlistProvider, child) {
                            final isInWishlist = wishlistProvider.isInWishlist(recommendation.product.id);
                            return MicroInteractions.animatedIconButton(
                              icon: isInWishlist ? Icons.favorite : Icons.favorite_border,
                              onPressed: () => _toggleWishlist(recommendation.product, wishlistProvider),
                              size: 18,
                              color: isInWishlist ? Colors.red : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              size: 60,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          MicroInteractions.animatedButton(
            onPressed: () {
              // Navigate to products
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Explore Products',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProduct(Product product) {
    final recommendationProvider = context.read<RecommendationProvider>();
    recommendationProvider.trackProductClick(product.id);

    // Navigate to product details (you can implement this navigation)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to ${product.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addToCart(Product product) {
    final cartProvider = context.read<CartProvider>();
    final recommendationProvider = context.read<RecommendationProvider>();

    cartProvider.addItem(product);
    recommendationProvider.trackAddToCart(product.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Navigate to cart
            Navigator.of(context).pushNamed('/cart');
          },
        ),
      ),
    );
  }

  void _toggleWishlist(Product product, WishlistProvider wishlistProvider) {
    final recommendationProvider = context.read<RecommendationProvider>();

    if (wishlistProvider.isInWishlist(product.id)) {
      wishlistProvider.removeFromWishlist(product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} removed from wishlist'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      wishlistProvider.addToWishlist(product);
      recommendationProvider.trackAddToWishlist(product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to wishlist'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showRecommendationStats(BuildContext context, RecommendationProvider provider) {
    final stats = provider.getRecommendationStats();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recommendation Stats'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Recommendations: ${stats['totalRecommendations']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('User Interactions: ${stats['userInteractions']}'),
                Text('Behavior Events: ${stats['behaviorEvents']}'),
                const SizedBox(height: 16),
                const Text('Recommendation Types:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(stats['typeBreakdown'] as Map<String, int>).entries.map((entry) {
                  final avgScore = (stats['averageScores'] as Map<String, double>)[entry.key] ?? 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• ${entry.key}: ${entry.value} items (avg ${(avgScore * 100).round()}% match)'),
                  );
                }),
                if (stats['lastUpdated'] != null) ...[
                  const SizedBox(height: 16),
                  Text('Last Updated: ${DateTime.parse(stats['lastUpdated']).toLocal()}'),
                ],
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

  void _showClearConfirmation(BuildContext context, RecommendationProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Recommendation Data'),
          content: const Text(
            'This will clear all recommendation data and user behavior history. This action cannot be undone.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.clearRecommendationData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recommendation data cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Clear Data'),
            ),
          ],
        );
      },
    );
  }
}
