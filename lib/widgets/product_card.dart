import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../screens/product_details_screen.dart';
import '../screens/cart_screen.dart';
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
    final isInCart = cartProvider.isInCart(product.id);
    final theme = Theme.of(context);

    return MicroInteractions.rippleContainer(
      onTap: onTap ?? () {
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
              ],
            ),

            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF1F2937),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: product.rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 14,
                          ignoreGestures: true,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD700),
                          ),
                          onRatingUpdate: (rating) {},
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${product.reviewCount})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Price and Add to Cart
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isInCart 
                                ? [Colors.red.shade400, Colors.red.shade600]
                                : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (isInCart ? Colors.red : const Color(0xFF6366F1)).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: MicroInteractions.animatedIconButton(
                            icon: isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                            onPressed: () {
                              if (isInCart) {
                                cartProvider.removeItem(product.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} removed from cart'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: Colors.red.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              } else {
                                cartProvider.addItem(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} added to cart'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: const Color(0xFF6366F1),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    action: SnackBarAction(
                                      label: 'View Cart',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const CartScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
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
  }
}
