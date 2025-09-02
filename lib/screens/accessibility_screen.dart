import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  final FocusNode _mainFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AccessibilityProvider>().autoFocusEnabled) {
        _mainFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _mainFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          Consumer<AccessibilityProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'reset':
                      _showResetConfirmation(context, provider);
                      break;
                    case 'report':
                      _showAccessibilityReport(context, provider);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.analytics, size: 20),
                        SizedBox(width: 12),
                        Text('View Report'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.restore, size: 20),
                        SizedBox(width: 12),
                        Text('Reset to Defaults'),
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
      body: Consumer<AccessibilityProvider>(
        builder: (context, provider, child) {
          return Semantics(
            label: 'Accessibility settings screen',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Focus(
                focusNode: _mainFocusNode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(provider),
                    const SizedBox(height: 24),

                    // Vision Settings
                    _buildVisionSection(provider),
                    const SizedBox(height: 24),

                    // Motor Settings
                    _buildMotorSection(provider),
                    const SizedBox(height: 24),

                    // Audio Settings
                    _buildAudioSection(provider),
                    const SizedBox(height: 24),

                    // Voice Commands
                    _buildVoiceSection(provider),
                    const SizedBox(height: 24),

                    // Keyboard Shortcuts
                    _buildKeyboardSection(provider),
                    const SizedBox(height: 32),

                    // Help Section
                    _buildHelpSection(provider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(AccessibilityProvider provider) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Welcome to accessibility settings',
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.accessibility_new,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Accessibility Settings',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 20) * provider.fontScale,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Customize your experience to make the app more accessible and easier to use.',
                style: TextStyle(
                  fontSize: 14 * provider.fontScale,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisionSection(AccessibilityProvider provider) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Vision accessibility settings',
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎨 Vision',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (theme.textTheme.titleLarge?.fontSize ?? 18) * provider.fontScale,
                ),
              ),
              const SizedBox(height: 16),

              // Font Size
              _buildSettingRow(
                icon: Icons.text_fields,
                title: 'Text Size',
                subtitle: 'Adjust font size for better readability',
                trailing: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (provider.fontSize.index > 0) {
                          provider.setFontSize(FontSize.values[provider.fontSize.index - 1]);
                          provider.announce('Font size decreased');
                        }
                      },
                      icon: const Icon(Icons.remove),
                      tooltip: 'Decrease font size',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        provider.fontSize.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12 * provider.fontScale,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (provider.fontSize.index < FontSize.values.length - 1) {
                          provider.setFontSize(FontSize.values[provider.fontSize.index + 1]);
                          provider.announce('Font size increased');
                        }
                      },
                      icon: const Icon(Icons.add),
                      tooltip: 'Increase font size',
                    ),
                  ],
                ),
              ),

              const Divider(),

              // High Contrast
              _buildSettingRow(
                icon: Icons.contrast,
                title: 'High Contrast',
                subtitle: 'Increase contrast for better visibility',
                trailing: Switch(
                  value: provider.contrastMode == ContrastMode.high,
                  onChanged: (value) {
                    provider.setContrastMode(
                      value ? ContrastMode.high : ContrastMode.normal
                    );
                    provider.announce(
                      value ? 'High contrast enabled' : 'High contrast disabled'
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotorSection(AccessibilityProvider provider) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Motor accessibility settings',
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🖱️ Motor Skills',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (theme.textTheme.titleLarge?.fontSize ?? 18) * provider.fontScale,
                ),
              ),
              const SizedBox(height: 16),

              // Large Touch Targets
              _buildSettingRow(
                icon: Icons.touch_app,
                title: 'Large Touch Targets',
                subtitle: 'Make buttons and interactive elements bigger',
                trailing: Switch(
                  value: provider.largeTouchTargets,
                  onChanged: (value) {
                    provider.setLargeTouchTargets(value);
                    provider.announce(
                      value ? 'Large touch targets enabled' : 'Large touch targets disabled'
                    );
                  },
                ),
              ),

              const Divider(),

              // Reduce Motion
              _buildSettingRow(
                icon: Icons.slow_motion_video,
                title: 'Reduce Motion',
                subtitle: 'Minimize animations and transitions',
                trailing: Switch(
                  value: provider.shouldReduceMotion,
                  onChanged: (value) {
                    provider.setMotionPreference(
                      value ? MotionPreference.reduced : MotionPreference.normal
                    );
                    provider.announce(
                      value ? 'Motion reduced' : 'Motion set to normal'
                    );
                  },
                ),
              ),

              const Divider(),

              // Auto Focus
              _buildSettingRow(
                icon: Icons.center_focus_strong,
                title: 'Auto Focus',
                subtitle: 'Automatically focus on main content',
                trailing: Switch(
                  value: provider.autoFocusEnabled,
                  onChanged: (value) {
                    provider.setAutoFocusEnabled(value);
                    provider.announce(
                      value ? 'Auto focus enabled' : 'Auto focus disabled'
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioSection(AccessibilityProvider provider) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Audio accessibility settings',
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔊 Audio',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (theme.textTheme.titleLarge?.fontSize ?? 18) * provider.fontScale,
                ),
              ),
              const SizedBox(height: 16),

              // Screen Reader
              _buildSettingRow(
                icon: Icons.record_voice_over,
                title: 'Screen Reader',
                subtitle: 'Enable audio announcements for screen elements',
                trailing: Switch(
                  value: provider.screenReaderEnabled,
                  onChanged: (value) {
                    provider.setScreenReaderEnabled(value);
                    provider.announce(
                      value ? 'Screen reader enabled' : 'Screen reader disabled'
                    );
                  },
                ),
              ),

              if (provider.screenReaderEnabled && provider.announcements.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Announcements:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12 * provider.fontScale,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...provider.announcements.map((announcement) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '• $announcement',
                          style: TextStyle(
                            fontSize: 11 * provider.fontScale,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceSection(AccessibilityProvider provider) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Voice commands settings',
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎤 Voice Commands',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (theme.textTheme.titleLarge?.fontSize ?? 18) * provider.fontScale,
                ),
              ),
              const SizedBox(height: 16),

              // Voice Commands Toggle
              _buildSettingRow(
                icon: Icons.mic,
                title: 'Enable Voice Commands',
                subtitle: 'Control the app using voice commands',
                trailing: Switch(
                  value: provider.voiceCommandsEnabled,
                  onChanged: (value) {
                    provider.setVoiceCommandsEnabled(value);
                    provider.announce(
                      value ? 'Voice commands enabled' : 'Voice commands disabled'
                    );
                  },
                ),
              ),

              if (provider.voiceCommandsEnabled) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Commands:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12 * provider.fontScale,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCommandList(provider),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboardSection(AccessibilityProvider provider) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Keyboard shortcuts settings',
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⌨️ Keyboard Shortcuts',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (theme.textTheme.titleLarge?.fontSize ?? 18) * provider.fontScale,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Press these keys anywhere in the app:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12 * provider.fontScale,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildShortcutRow('C', 'Toggle high contrast mode'),
                    _buildShortcutRow('T', 'Cycle through text sizes'),
                    _buildShortcutRow('S', 'Toggle screen reader'),
                    _buildShortcutRow('M', 'Toggle motion reduction'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(AccessibilityProvider provider) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Help and support section',
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '❓ Help & Support',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (theme.textTheme.titleLarge?.fontSize ?? 18) * provider.fontScale,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Accessibility features make the app easier to use for everyone. These settings are saved automatically and will be remembered when you return to the app.',
                style: TextStyle(
                  fontSize: 14 * provider.fontScale,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      'WCAG 2.1 AA Compliant',
                      style: TextStyle(fontSize: 11 * provider.fontScale),
                    ),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  Chip(
                    label: Text(
                      'Screen Reader Ready',
                      style: TextStyle(fontSize: 11 * provider.fontScale),
                    ),
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                  ),
                  Chip(
                    label: Text(
                      'Keyboard Accessible',
                      style: TextStyle(fontSize: 11 * provider.fontScale),
                    ),
                    backgroundColor: theme.colorScheme.tertiary.withOpacity(0.1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    final provider = context.watch<AccessibilityProvider>();
    final theme = Theme.of(context);

    return Semantics(
      label: '$title setting, $subtitle',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16 * provider.fontScale,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12 * provider.fontScale,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutRow(String key, String description) {
    final provider = context.watch<AccessibilityProvider>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              key,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11 * provider.fontScale,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12 * provider.fontScale,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandList(AccessibilityProvider provider) {
    final theme = Theme.of(context);
    final commands = [
      '"Increase text" or "Larger text"',
      '"Decrease text" or "Smaller text"',
      '"High contrast" or "Contrast mode"',
      '"Screen reader"',
      '"Reduce motion" or "Stop motion"',
      '"Normal motion"',
      '"Large touch" or "Big buttons"',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: commands.map((command) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          command,
          style: TextStyle(
            fontSize: 11 * provider.fontScale,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontFamily: 'monospace',
          ),
        ),
      )).toList(),
    );
  }

  void _showResetConfirmation(BuildContext context, AccessibilityProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Accessibility Settings'),
          content: const Text(
            'This will reset all accessibility settings to their default values. This action cannot be undone.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.resetToDefaults();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Accessibility settings reset to defaults'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showAccessibilityReport(BuildContext context, AccessibilityProvider provider) {
    final report = provider.getAccessibilityReport();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accessibility Report'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReportItem('Text Size', report['fontSize']),
                _buildReportItem('Contrast Mode', report['contrastMode']),
                _buildReportItem('Motion Preference', report['motionPreference']),
                _buildReportItem('Screen Reader', report['screenReaderEnabled'] ? 'Enabled' : 'Disabled'),
                _buildReportItem('Large Touch Targets', report['largeTouchTargets'] ? 'Enabled' : 'Disabled'),
                _buildReportItem('Auto Focus', report['autoFocusEnabled'] ? 'Enabled' : 'Disabled'),
                _buildReportItem('Voice Commands', report['voiceCommandsEnabled'] ? 'Enabled' : 'Disabled'),
                _buildReportItem('Font Scale', report['fontScale'].toStringAsFixed(2)),
                _buildReportItem('Min Touch Target', '${report['minimumTouchTargetSize']}px'),
                _buildReportItem('Motion Reduced', report['shouldReduceMotion'] ? 'Yes' : 'No'),
                _buildReportItem('Active Announcements', report['announcementsCount'].toString()),
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

  Widget _buildReportItem(String label, String value) {
    final provider = context.watch<AccessibilityProvider>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14 * provider.fontScale,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12 * provider.fontScale,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
