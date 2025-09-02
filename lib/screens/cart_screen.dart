import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/micro_interactions.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    if (cartProvider.isEmpty) {
      return Scaffold(
        body: _buildEmptyCart(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart (${cartProvider.itemCount})'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Cart items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartProvider.items.length,
              itemBuilder: (context, index) {
                final cartItem = cartProvider.items[index];
                return CartItemWidget(cartItem: cartItem);
              },
            ),
          ),

          // Cart summary and checkout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('\$${cartProvider.totalAmount.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),

                // Shipping
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Shipping'),
                    Text(
                      cartProvider.shippingCost == 0
                          ? 'Free'
                          : '\$${cartProvider.shippingCost.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tax
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax'),
                    Text('\$${cartProvider.taxAmount.toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(height: 24),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${cartProvider.finalTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Checkout button
                SizedBox(
                  width: double.infinity,
                  child: MicroInteractions.animatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PaymentScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Column(
      children: [
        AppBar(
          title: const Text('Shopping Cart (0)'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some products to get started',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MicroInteractions.animatedButton(
                      onPressed: () {
                        _addDemoItemsToCart(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Add Demo Items',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    MicroInteractions.animatedButton(
                      onPressed: () {
                        appProvider.navigateToProducts();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Start Shopping',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ],
    );
  }

  void _addDemoItemsToCart(BuildContext context) {
    final cartProvider = context.read<CartProvider>();

    // Add some demo products to the cart
    final demoProducts = [
      Product(
        id: '1',
        name: 'iPhone 15 Pro',
        description: 'The latest iPhone with A17 Pro chip and 48MP camera',
        price: 1199.99,
        imageUrl: 'assets/images/products/iphone.svg',
        category: 'Electronics',
        rating: 4.8,
        reviewCount: 1247,
      ),
      Product(
        id: '3',
        name: 'Nike Air Max',
        description: 'Comfortable and stylish sports shoes',
        price: 129.99,
        imageUrl: 'assets/images/products/nike-shoes.svg',
        category: 'Fashion',
        rating: 4.6,
        reviewCount: 567,
      ),
      Product(
        id: '5',
        name: 'Adidas T-Shirt',
        description: 'Sports t-shirt in organic cotton',
        price: 29.99,
        imageUrl: 'assets/images/products/adidas-tshirt.svg',
        category: 'Fashion',
        rating: 4.5,
        reviewCount: 234,
      ),
    ];

    // Add products to cart
    for (final product in demoProducts) {
      cartProvider.addItem(product);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo items added to cart!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: const Text(
          'Checkout functionality will be implemented in the next step. '
          'This would typically navigate to a checkout form.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
