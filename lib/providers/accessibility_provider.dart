import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum FontSize { small, medium, large, extraLarge }
enum ContrastMode { normal, high, dark }
enum MotionPreference { normal, reduced, none }

class AccessibilityProvider with ChangeNotifier {
  static const String _fontSizeKey = 'accessibility_font_size';
  static const String _contrastKey = 'accessibility_contrast';
  static const String _motionKey = 'accessibility_motion';
  static const String _screenReaderKey = 'accessibility_screen_reader';
  static const String _largeTouchKey = 'accessibility_large_touch';
  static const String _autoFocusKey = 'accessibility_auto_focus';
  static const String _voiceCommandsKey = 'accessibility_voice_commands';

  // Settings
  FontSize _fontSize = FontSize.medium;
  ContrastMode _contrastMode = ContrastMode.normal;
  MotionPreference _motionPreference = MotionPreference.normal;
  bool _screenReaderEnabled = false;
  bool _largeTouchTargets = false;
  bool _autoFocusEnabled = true;
  bool _voiceCommandsEnabled = false;

  // Announcement system
  final List<String> _announcements = [];
  bool _isAnnouncing = false;

  AccessibilityProvider() {
    _loadSettings();
  }

  // Getters
  FontSize get fontSize => _fontSize;
  ContrastMode get contrastMode => _contrastMode;
  MotionPreference get motionPreference => _motionPreference;
  bool get screenReaderEnabled => _screenReaderEnabled;
  bool get largeTouchTargets => _largeTouchTargets;
  bool get autoFocusEnabled => _autoFocusEnabled;
  bool get voiceCommandsEnabled => _voiceCommandsEnabled;
  List<String> get announcements => List.unmodifiable(_announcements);
  bool get isAnnouncing => _isAnnouncing;

  // Font size scaling
  double get fontScale {
    switch (_fontSize) {
      case FontSize.small:
        return 0.875;
      case FontSize.medium:
        return 1.0;
      case FontSize.large:
        return 1.25;
      case FontSize.extraLarge:
        return 1.5;
    }
  }

  // Touch target size
  double get minimumTouchTargetSize => _largeTouchTargets ? 48.0 : 44.0;

  // Contrast settings
  Color get highContrastColor(Color baseColor) {
    if (_contrastMode == ContrastMode.high) {
      return baseColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }
    return baseColor;
  }

  bool get shouldReduceMotion {
    return _motionPreference != MotionPreference.normal;
  }

  // Settings setters
  void setFontSize(FontSize size) {
    if (_fontSize != size) {
      _fontSize = size;
      _saveSettings();
      notifyListeners();
    }
  }

  void setContrastMode(ContrastMode mode) {
    if (_contrastMode != mode) {
      _contrastMode = mode;
      _saveSettings();
      notifyListeners();
    }
  }

  void setMotionPreference(MotionPreference preference) {
    if (_motionPreference != preference) {
      _motionPreference = preference;
      _saveSettings();
      notifyListeners();
    }
  }

  void setScreenReaderEnabled(bool enabled) {
    if (_screenReaderEnabled != enabled) {
      _screenReaderEnabled = enabled;
      _saveSettings();
      notifyListeners();
    }
  }

  void setLargeTouchTargets(bool enabled) {
    if (_largeTouchTargets != enabled) {
      _largeTouchTargets = enabled;
      _saveSettings();
      notifyListeners();
    }
  }

  void setAutoFocusEnabled(bool enabled) {
    if (_autoFocusEnabled != enabled) {
      _autoFocusEnabled = enabled;
      _saveSettings();
      notifyListeners();
    }
  }

  void setVoiceCommandsEnabled(bool enabled) {
    if (_voiceCommandsEnabled != enabled) {
      _voiceCommandsEnabled = enabled;
      _saveSettings();
      notifyListeners();
    }
  }

  // Announcement system for screen readers
  void announce(String message, {bool interrupt = false}) {
    if (_screenReaderEnabled) {
      if (interrupt) {
        _announcements.clear();
        _isAnnouncing = false;
      }

      _announcements.add(message);
      _isAnnouncing = true;

      // Auto-clear after announcement
      Future.delayed(const Duration(seconds: 3), () {
        if (_announcements.isNotEmpty) {
          _announcements.removeAt(0);
          if (_announcements.isEmpty) {
            _isAnnouncing = false;
          }
          notifyListeners();
        }
      });

      notifyListeners();
    }
  }

  void clearAnnouncements() {
    _announcements.clear();
    _isAnnouncing = false;
    notifyListeners();
  }

  // Accessibility shortcuts
  void toggleHighContrast() {
    setContrastMode(
      _contrastMode == ContrastMode.high ? ContrastMode.normal : ContrastMode.high
    );
    announce(
      _contrastMode == ContrastMode.high
        ? 'High contrast mode enabled'
        : 'High contrast mode disabled'
    );
  }

  void toggleLargeText() {
    final nextSize = FontSize.values[(_fontSize.index + 1) % FontSize.values.length];
    setFontSize(nextSize);
    announce('Font size changed to ${nextSize.name}');
  }

  void toggleScreenReader() {
    setScreenReaderEnabled(!_screenReaderEnabled);
    announce(
      _screenReaderEnabled
        ? 'Screen reader mode enabled'
        : 'Screen reader mode disabled'
    );
  }

  // Keyboard shortcuts
  void handleKeyboardShortcut(String key) {
    switch (key.toLowerCase()) {
      case 'c':
        toggleHighContrast();
        break;
      case 't':
        toggleLargeText();
        break;
      case 's':
        toggleScreenReader();
        break;
      case 'm':
        setMotionPreference(
          _motionPreference == MotionPreference.normal
            ? MotionPreference.reduced
            : MotionPreference.normal
        );
        announce(
          _motionPreference == MotionPreference.reduced
            ? 'Motion reduced'
            : 'Motion normal'
        );
        break;
    }
  }

  // Accessibility assessment
  Map<String, dynamic> getAccessibilityReport() {
    return {
      'fontSize': _fontSize.name,
      'contrastMode': _contrastMode.name,
      'motionPreference': _motionPreference.name,
      'screenReaderEnabled': _screenReaderEnabled,
      'largeTouchTargets': _largeTouchTargets,
      'autoFocusEnabled': _autoFocusEnabled,
      'voiceCommandsEnabled': _voiceCommandsEnabled,
      'fontScale': fontScale,
      'minimumTouchTargetSize': minimumTouchTargetSize,
      'shouldReduceMotion': shouldReduceMotion,
      'announcementsCount': _announcements.length,
    };
  }

  // Reset to defaults
  void resetToDefaults() {
    _fontSize = FontSize.medium;
    _contrastMode = ContrastMode.normal;
    _motionPreference = MotionPreference.normal;
    _screenReaderEnabled = false;
    _largeTouchTargets = false;
    _autoFocusEnabled = true;
    _voiceCommandsEnabled = false;
    _announcements.clear();
    _isAnnouncing = false;

    _saveSettings();
    notifyListeners();

    announce('Accessibility settings reset to defaults');
  }

  // Data persistence
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _fontSize = FontSize.values[prefs.getInt(_fontSizeKey) ?? FontSize.medium.index];
      _contrastMode = ContrastMode.values[prefs.getInt(_contrastKey) ?? ContrastMode.normal.index];
      _motionPreference = MotionPreference.values[prefs.getInt(_motionKey) ?? MotionPreference.normal.index];
      _screenReaderEnabled = prefs.getBool(_screenReaderKey) ?? false;
      _largeTouchTargets = prefs.getBool(_largeTouchKey) ?? false;
      _autoFocusEnabled = prefs.getBool(_autoFocusKey) ?? true;
      _voiceCommandsEnabled = prefs.getBool(_voiceCommandsKey) ?? false;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading accessibility settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(_fontSizeKey, _fontSize.index);
      await prefs.setInt(_contrastKey, _contrastMode.index);
      await prefs.setInt(_motionKey, _motionPreference.index);
      await prefs.setBool(_screenReaderKey, _screenReaderEnabled);
      await prefs.setBool(_largeTouchKey, _largeTouchTargets);
      await prefs.setBool(_autoFocusKey, _autoFocusEnabled);
      await prefs.setBool(_voiceCommandsKey, _voiceCommandsEnabled);
    } catch (e) {
      debugPrint('Error saving accessibility settings: $e');
    }
  }

  // Voice command processing
  void processVoiceCommand(String command) {
    if (!_voiceCommandsEnabled) return;

    final cmd = command.toLowerCase().trim();

    if (cmd.contains('increase text') || cmd.contains('larger text')) {
      toggleLargeText();
    } else if (cmd.contains('decrease text') || cmd.contains('smaller text')) {
      if (_fontSize.index > 0) {
        setFontSize(FontSize.values[_fontSize.index - 1]);
        announce('Font size decreased');
      }
    } else if (cmd.contains('high contrast') || cmd.contains('contrast mode')) {
      toggleHighContrast();
    } else if (cmd.contains('screen reader')) {
      toggleScreenReader();
    } else if (cmd.contains('reduce motion') || cmd.contains('stop motion')) {
      setMotionPreference(MotionPreference.reduced);
      announce('Motion reduced');
    } else if (cmd.contains('normal motion')) {
      setMotionPreference(MotionPreference.normal);
      announce('Motion set to normal');
    } else if (cmd.contains('large touch') || cmd.contains('big buttons')) {
      setLargeTouchTargets(!_largeTouchTargets);
      announce(_largeTouchTargets ? 'Large touch targets enabled' : 'Large touch targets disabled');
    } else {
      announce('Voice command not recognized. Try: "increase text", "high contrast", "screen reader", "reduce motion"');
    }
  }

  // Accessibility widget helpers
  Widget buildAccessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    String? semanticLabel,
    String? tooltip,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      child: SizedBox(
        width: _largeTouchTargets ? 56.0 : 44.0,
        height: _largeTouchTargets ? 56.0 : 44.0,
        child: IconButton(
          onPressed: () {
            onPressed();
            if (_screenReaderEnabled && semanticLabel != null) {
              announce('$semanticLabel pressed');
            }
          },
          icon: child,
          tooltip: tooltip,
          focusNode: focusNode,
          autofocus: autofocus,
        ),
      ),
    );
  }

  Widget buildAccessibleText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    bool selectable = false,
  }) {
    final scaledStyle = style?.copyWith(
      fontSize: (style.fontSize ?? 14.0) * fontScale,
    ) ?? TextStyle(fontSize: 14.0 * fontScale);

    return Semantics(
      label: text,
      child: selectable
        ? SelectableText(
            text,
            style: scaledStyle,
            textAlign: textAlign,
            maxLines: maxLines,
          )
        : Text(
            text,
            style: scaledStyle,
            textAlign: textAlign,
            maxLines: maxLines,
          ),
    );
  }

  Widget buildAccessibleCard({
    required Widget child,
    String? semanticLabel,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      enabled: onTap != null,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: InkWell(
          onTap: onTap != null ? () {
            onTap();
            if (_screenReaderEnabled && semanticLabel != null) {
              announce('$semanticLabel selected');
            }
          } : null,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
