import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Settings
            Text(
              'Appearance',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            _buildSettingCard(
              context,
              'Theme Mode',
              'Choose your preferred theme',
              Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                activeColor: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 32),

            // Account Settings
            Text(
              'Account',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            _buildSettingCard(
              context,
              'Profile Information',
              'Update your personal details',
              const Icon(Icons.person),
            ),

            _buildSettingCard(
              context,
              'Privacy Settings',
              'Manage your privacy preferences',
              const Icon(Icons.privacy_tip),
            ),

            _buildSettingCard(
              context,
              'Notification Preferences',
              'Choose what notifications to receive',
              const Icon(Icons.notifications),
            ),

            const SizedBox(height: 32),

            // App Settings
            Text(
              'Application',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            _buildSettingCard(
              context,
              'Language',
              'English (US)',
              const Icon(Icons.language),
            ),

            _buildSettingCard(
              context,
              'Currency',
              'USD (\$)',
              const Icon(Icons.attach_money),
            ),

            _buildSettingCard(
              context,
              'Clear Cache',
              'Free up storage space',
              const Icon(Icons.cleaning_services),
            ),

            const SizedBox(height: 32),

            // Support
            Text(
              'Support',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            _buildSettingCard(
              context,
              'Help & FAQ',
              'Find answers to common questions',
              const Icon(Icons.help),
            ),

            _buildSettingCard(
              context,
              'Contact Support',
              'Get help from our team',
              const Icon(Icons.support),
            ),

            _buildSettingCard(
              context,
              'Rate App',
              'Leave a review on the app store',
              const Icon(Icons.star),
            ),

            const SizedBox(height: 32),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'ShopHub v1.0.0',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 ShopHub. All rights reserved.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    String subtitle,
    Icon icon, {
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium,
        ),
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: trailing == null ? () {
          // Handle tap for navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title tapped')),
          );
        } : null,
      ),
    );
  }
}
