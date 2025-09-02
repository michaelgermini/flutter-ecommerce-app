import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../providers/product_comparison_provider.dart';
import '../providers/accessibility_provider.dart';
import '../screens/product_details_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/product_comparison_screen.dart';
import '../services/notification_service.dart';
import 'micro_interactions.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final recentlyViewedProvider = context.read<RecentlyViewedProvider>();
    final comparisonProvider = context.watch<ProductComparisonProvider>();
    final notificationService = NotificationService();
    final accessibilityProvider = context.watch<AccessibilityProvider>();
    final isInCart = cartProvider.isInCart(product.id);
    final isInWishlist = wishlistProvider.isInWishlist(product.id);
    final isInComparison = comparisonProvider.isInComparison(product.id);
    final theme = Theme.of(context);

    return Semantics(
      label: '${product.name}, ${product.price.toStringAsFixed(2)} dollars, ${product.category} category',
      button: true,
      enabled: true,
      child: MicroInteractions.rippleContainer(
        onTap: onTap ?? () {
          // Add to recently viewed
          recentlyViewedProvider.addToRecentlyViewed(product);

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F2937).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF1F2937).withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with gradient overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: product.imageUrl.startsWith('assets/') 
                      ? (product.imageUrl.endsWith('.svg') 
                        ? SvgPicture.asset(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            placeholderBuilder: (context) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF6366F1).withOpacity(0.1),
                                    const Color(0xFFEC4899).withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ),
                          )
                        : Image.asset(
                            product.imageUrl,
                            fit: BoxFit.cover,
                          ))
                      : CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF6366F1).withOpacity(0.1),
                                  const Color(0xFFEC4899).withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF6366F1).withOpacity(0.1),
                                  const Color(0xFFEC4899).withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Color(0xFF6366F1),
                              size: 32,
                            ),
                          ),
                        ),
                  ),
                ),
                
                // Category badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Stock status badge
                if (!product.isInStock)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Out of Stock',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else if (product.stockQuantity < 10)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Only ${product.stockQuantity} left',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Wishlist button
                Positioned(
                  top: 8,
                  right: product.isInStock && product.stockQuantity >= 10 ? 8 : 70,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        final wasInWishlist = isInWishlist;
                        wishlistProvider.toggleWishlist(product);

                        if (!wasInWishlist) {
                          // Item was added to wishlist
                          notificationProvider.showWishlistNotification(product.name);
                        } else {
                          // Item was removed from wishlist
                          notificationService.showInfo(
                            context,
                            'Removed from Wishlist',
                            '${product.name} has been removed from your wishlist',
                          );
                        }
                      },
                      icon: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isInWishlist ? Colors.red : Colors.grey[600],
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Compare button
                Positioned(
                  top: product.isInStock && product.stockQuantity >= 10 ? 52 : 94,
                  right: product.isInStock && product.stockQuantity >= 10 ? 8 : 70,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (comparisonProvider.canAddMore) {
                          final success = comparisonProvider.toggleComparison(product);
                          if (success) {
                            notificationService.showSuccess(
                              context,
                              'Added to Comparison',
                              '${product.name} added to comparison',
                            );
                          } else {
                            notificationService.showError(
                              context,
                              'Cannot Add',
                              comparisonProvider.errorMessage,
                            );
                          }
                        } else {
                          // Show comparison screen if can't add more
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProductComparisonScreen(),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        isInComparison ? Icons.compare : Icons.compare_arrows,
                        color: isInComparison ? theme.colorScheme.primary : Colors.grey[600],
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: isInComparison ? 'Remove from comparison' : 'Add to comparison',
                    ),
                  ),
                ),
              ],
            ),

            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1F2937),
                        fontWeight: FontWeight.w600,
                        fontSize: 14 * accessibilityProvider.fontScale,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Rating
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: product.rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 12,
                          ignoreGestures: true,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD700),
                          ),
                          onRatingUpdate: (rating) {},
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewCount})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Price and Add to Cart
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6366F1),
                                  fontSize: 16 * accessibilityProvider.fontScale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isInCart
                                ? [Colors.red.shade400, Colors.red.shade600]
                                : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: (isInCart ? Colors.red : const Color(0xFF6366F1)).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: MicroInteractions.animatedIconButton(
                            icon: isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                            size: 18,
                            onPressed: () {
                              if (isInCart) {
                                cartProvider.removeItem(product.id);
                                notificationService.showError(
                                  context,
                                  'Removed from Cart',
                                  '${product.name} has been removed from your cart',
                                );
                              } else {
                                cartProvider.addItem(product);
                                notificationProvider.showCartNotification(product.name);
                              }
                            },
                            color: Colors.white,
                          ),
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
    );
  }
}
