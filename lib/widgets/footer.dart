import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withOpacity(0.95),
          ],
        ),
      ),
      child: Column(
        children: [
          // Newsletter Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
            ),
            child: isSmallScreen
                ? _buildMobileNewsletter(context)
                : _buildDesktopNewsletter(context),
          ),

          // Main Footer Content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: isSmallScreen
                ? _buildMobileFooter(context)
                : _buildDesktopFooter(context),
          ),

          // Divider
          Divider(
            color: theme.colorScheme.outline.withOpacity(0.3),
            thickness: 1,
            height: 1,
          ),

          // Bottom Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: _buildBottomSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNewsletter(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📧 Stay Informed',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Receive the latest news, exclusive offers and product updates directly in your mailbox.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: _buildNewsletterForm(context),
        ),
      ],
    );
  }

  Widget _buildMobileNewsletter(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📧 Stay Informed',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Receive the latest news and exclusive offers.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        _buildNewsletterForm(context),
      ],
    );
  }

  Widget _buildNewsletterForm(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Your email address',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🛍️ Flutter E-Commerce',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your modern shopping destination with exceptional user experience. Discover our quality products and enjoy fast delivery.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              _buildSocialLinks(context),
            ],
          ),
        ),

        const SizedBox(width: 60),

        // Quick Links
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Links',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildFooterLink(context, 'Home', () {}),
              _buildFooterLink(context, 'Products', () {}),
              _buildFooterLink(context, 'Categories', () {}),
              _buildFooterLink(context, 'New Arrivals', () {}),
              _buildFooterLink(context, 'Promotions', () {}),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Support
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Support',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildFooterLink(context, 'Help Center', () {}),
              _buildFooterLink(context, 'Contact', () {}),
              _buildFooterLink(context, 'Shipping', () {}),
              _buildFooterLink(context, 'Returns', () {}),
              _buildFooterLink(context, 'FAQ', () {}),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Contact Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildContactInfo(context, Icons.email, 'support@flutter-ecommerce.com'),
              _buildContactInfo(context, Icons.phone, '+33 1 23 45 67 89'),
              _buildContactInfo(context, Icons.location_on, 'Paris, France'),
              _buildContactInfo(context, Icons.access_time, 'Mon-Sun: 9am-6pm'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Info
        Text(
          '🛍️ Flutter E-Commerce',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your modern shopping destination with exceptional user experience.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        _buildSocialLinks(context),

        const SizedBox(height: 30),

        // Links in rows for mobile
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Links',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFooterLink(context, 'Home', () {}),
                  _buildFooterLink(context, 'Products', () {}),
                  _buildFooterLink(context, 'Categories', () {}),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFooterLink(context, 'Help Center', () {}),
                  _buildFooterLink(context, 'Contact', () {}),
                  _buildFooterLink(context, 'Shipping', () {}),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // Contact Info
        Text(
          'Contact',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactInfo(context, Icons.email, 'support@flutter-ecommerce.com'),
        _buildContactInfo(context, Icons.phone, '+33 1 23 45 67 89'),
        _buildContactInfo(context, Icons.location_on, 'Paris, France'),
        _buildContactInfo(context, Icons.access_time, 'Mon-Sun: 9am-6pm'),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _buildSocialButton(
          context,
          Icons.facebook,
          'Facebook',
          theme.colorScheme.primary,
          () {},
        ),
        const SizedBox(width: 12),
        _buildSocialButton(
          context,
          Icons.whatshot, // Using whatshot as Twitter/X icon
          'Twitter',
          theme.colorScheme.primary,
          () {},
        ),
        const SizedBox(width: 12),
        _buildSocialButton(
          context,
          Icons.camera_alt, // Using camera_alt as Instagram icon
          'Instagram',
          theme.colorScheme.primary,
          () {},
        ),
        const SizedBox(width: 12),
        _buildSocialButton(
          context,
          Icons.video_library, // Using video_library as YouTube icon
          'YouTube',
          theme.colorScheme.primary,
          () {},
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Payment Methods
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPaymentIcon(Icons.credit_card, 'Visa'),
            const SizedBox(width: 16),
            _buildPaymentIcon(Icons.account_balance_wallet, 'Mastercard'),
            const SizedBox(width: 16),
            _buildPaymentIcon(Icons.payments, 'PayPal'),
            const SizedBox(width: 16),
            _buildPaymentIcon(Icons.delivery_dining, 'Delivery'),
          ],
        ),

        const SizedBox(height: 20),

        // Copyright and Links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '© 2024 Flutter E-Commerce. All rights reserved.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 20),
            _buildBottomLink(context, 'Privacy Policy', () {}),
            const SizedBox(width: 20),
            _buildBottomLink(context, 'Terms of Use', () {}),
            const SizedBox(width: 20),
            _buildBottomLink(context, 'Legal Notice', () {}),
          ],
        ),

        const SizedBox(height: 16),

        // Made with love
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Made with',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.favorite,
              size: 14,
              color: Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              'using Flutter',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentIcon(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        size: 24,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildBottomLink(BuildContext context, String text, VoidCallback onTap) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          decoration: TextDecoration.underline,
          decorationColor: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.copyright,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '2024 Flutter E-Commerce. All rights reserved.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
