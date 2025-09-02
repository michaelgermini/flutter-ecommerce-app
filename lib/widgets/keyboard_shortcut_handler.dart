import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';

class KeyboardShortcutHandler extends StatefulWidget {
  final Widget child;

  const KeyboardShortcutHandler({
    super.key,
    required this.child,
  });

  @override
  State<KeyboardShortcutHandler> createState() => _KeyboardShortcutHandlerState();
}

class _KeyboardShortcutHandlerState extends State<KeyboardShortcutHandler> {
  final FocusNode _focusNode = FocusNode();
  bool _isAltPressed = false;
  bool _isControlPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityProvider>(
      builder: (context, accessibilityProvider, child) {
        return RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              _handleKeyDown(event, accessibilityProvider);
            } else if (event is RawKeyUpEvent) {
              _handleKeyUp(event);
            }
          },
          child: widget.child,
        );
      },
    );
  }

  void _handleKeyDown(RawKeyEvent event, AccessibilityProvider accessibilityProvider) {
    final key = event.logicalKey;

    // Track modifier keys
    if (key == LogicalKeyboardKey.altLeft || key == LogicalKeyboardKey.altRight) {
      _isAltPressed = true;
    } else if (key == LogicalKeyboardKey.controlLeft || key == LogicalKeyboardKey.controlRight) {
      _isControlPressed = true;
    }

    // Handle accessibility shortcuts
    if (_isAltPressed) {
      switch (key.keyLabel.toLowerCase()) {
        case 'c':
          accessibilityProvider.toggleHighContrast();
          _showShortcutFeedback('High contrast toggled');
          break;
        case 't':
          accessibilityProvider.toggleLargeText();
          _showShortcutFeedback('Text size changed');
          break;
        case 's':
          accessibilityProvider.toggleScreenReader();
          _showShortcutFeedback('Screen reader toggled');
          break;
        case 'm':
          accessibilityProvider.setMotionPreference(
            accessibilityProvider.motionPreference == MotionPreference.normal
              ? MotionPreference.reduced
              : MotionPreference.normal
          );
          _showShortcutFeedback('Motion preference changed');
          break;
        case 'a':
          // Toggle large touch targets
          accessibilityProvider.setLargeTouchTargets(!accessibilityProvider.largeTouchTargets);
          _showShortcutFeedback('Touch targets ${accessibilityProvider.largeTouchTargets ? 'enlarged' : 'normalized'}');
          break;
        case 'h':
          // Show help
          _showAccessibilityHelp();
          break;
      }
    }

    // Handle voice commands (if enabled)
    if (accessibilityProvider.voiceCommandsEnabled && !_isAltPressed && !_isControlPressed) {
      if (key == LogicalKeyboardKey.space) {
        // Space key could trigger voice command listening
        accessibilityProvider.announce('Voice command mode activated. Say a command like "increase text" or "high contrast"');
      }
    }
  }

  void _handleKeyUp(RawKeyEvent event) {
    final key = event.logicalKey;

    // Reset modifier keys
    if (key == LogicalKeyboardKey.altLeft || key == LogicalKeyboardKey.altRight) {
      _isAltPressed = false;
    } else if (key == LogicalKeyboardKey.controlLeft || key == LogicalKeyboardKey.controlRight) {
      _isControlPressed = false;
    }
  }

  void _showShortcutFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.keyboard, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showAccessibilityHelp() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accessibility Shortcuts'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildShortcutHelp('Alt + C', 'Toggle high contrast mode'),
                const SizedBox(height: 8),
                _buildShortcutHelp('Alt + T', 'Cycle through text sizes'),
                const SizedBox(height: 8),
                _buildShortcutHelp('Alt + S', 'Toggle screen reader'),
                const SizedBox(height: 8),
                _buildShortcutHelp('Alt + M', 'Toggle motion reduction'),
                const SizedBox(height: 8),
                _buildShortcutHelp('Alt + A', 'Toggle large touch targets'),
                const SizedBox(height: 8),
                _buildShortcutHelp('Alt + H', 'Show this help dialog'),
                const SizedBox(height: 16),
                const Text(
                  'Voice Commands (when enabled):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• "Increase text" or "Larger text"'),
                const Text('• "Decrease text" or "Smaller text"'),
                const Text('• "High contrast" or "Contrast mode"'),
                const Text('• "Screen reader"'),
                const Text('• "Reduce motion" or "Stop motion"'),
                const Text('• "Large touch" or "Big buttons"'),
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

  Widget _buildShortcutHelp(String shortcut, String description) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            shortcut,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: theme.colorScheme.primary,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
