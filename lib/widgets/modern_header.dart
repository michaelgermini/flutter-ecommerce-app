import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';
import 'micro_interactions.dart';

class ModernHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showCart;

  const ModernHeader({
    super.key,
    required this.title,
    this.actions,
    this.showCart = true,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItemCount = cartProvider.items.length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.05),
            const Color(0xFFEC4899).withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (showCart) ...[
            Stack(
              children: [
                MicroInteractions.animatedIconButton(
                  icon: Icons.shopping_cart_outlined,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                  color: const Color(0xFF6366F1),
                ),
                if (cartItemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEC4899).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cartItemCount.toString(),
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
            ),
            const SizedBox(width: 8),
          ],
          if (actions != null) ...actions!,
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchSubmitted;

  const SearchHeader({
    super.key,
    required this.title,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.05),
            const Color(0xFFEC4899).withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F2937).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            onSubmitted: (_) => onSearchSubmitted?.call(),
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF6366F1),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        actions: const [
          SizedBox(width: 16),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
