import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification.dart';

class NotificationProvider with ChangeNotifier {
  static const String _notificationsKey = 'notifications';
  static const String _settingsKey = 'notification_settings';
  static const int _maxNotifications = 50;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Settings
  bool _showToastNotifications = true;
  bool _showPersistentNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Getters
  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  List<AppNotification> get persistentNotifications =>
      _notifications.where((n) => n.isPersistent).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Settings getters
  bool get showToastNotifications => _showToastNotifications;
  bool get showPersistentNotifications => _showPersistentNotifications;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  NotificationProvider() {
    _loadNotifications();
    _loadSettings();
  }

  // Add notification
  void addNotification(AppNotification notification) {
    // Check if notification with same ID already exists
    final existingIndex = _notifications.indexWhere((n) => n.id == notification.id);
    if (existingIndex != -1) {
      _notifications[existingIndex] = notification;
    } else {
      _notifications.insert(0, notification);

      // Limit the number of notifications
      if (_notifications.length > _maxNotifications) {
        _notifications = _notifications.sublist(0, _maxNotifications);
      }
    }

    _saveNotifications();
    notifyListeners();
  }

  // Remove notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _saveNotifications();
    notifyListeners();
  }

  // Mark as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _saveNotifications();
      notifyListeners();
    }
  }

  // Mark all as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _saveNotifications();
    notifyListeners();
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    _saveNotifications();
    notifyListeners();
  }

  // Clear read notifications
  void clearReadNotifications() {
    _notifications.removeWhere((n) => n.isRead);
    _saveNotifications();
    notifyListeners();
  }

  // Quick actions using templates
  void showCartNotification(String productName) {
    addNotification(NotificationTemplates.cartItemAdded(productName));
  }

  void showWishlistNotification(String productName) {
    addNotification(NotificationTemplates.wishlistItemAdded(productName));
  }

  void showOrderNotification(String orderId) {
    addNotification(NotificationTemplates.orderPlaced(orderId));
  }

  void showPaymentNotification(double amount) {
    addNotification(NotificationTemplates.paymentSuccess(amount));
  }

  void showPromotionNotification(String title, String message) {
    addNotification(NotificationTemplates.promotion(title, message));
  }

  void showSuccessNotification(String title, String message) {
    addNotification(NotificationTemplates.success(title, message));
  }

  void showErrorNotification(String title, String message) {
    addNotification(NotificationTemplates.error(title, message));
  }

  // Settings management
  void updateSettings({
    bool? showToastNotifications,
    bool? showPersistentNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    if (showToastNotifications != null) {
      _showToastNotifications = showToastNotifications;
    }
    if (showPersistentNotifications != null) {
      _showPersistentNotifications = showPersistentNotifications;
    }
    if (soundEnabled != null) {
      _soundEnabled = soundEnabled;
    }
    if (vibrationEnabled != null) {
      _vibrationEnabled = vibrationEnabled;
    }
    _saveSettings();
    notifyListeners();
  }

  // Filter notifications
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  List<AppNotification> getNotificationsByPriority(NotificationPriority priority) {
    return _notifications.where((n) => n.priority == priority).toList();
  }

  List<AppNotification> getRecentNotifications({int limit = 10}) {
    return _notifications.take(limit).toList();
  }

  // Persistence
  Future<void> _loadNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      if (notificationsJson != null) {
        final notificationsList = json.decode(notificationsJson) as List;
        _notifications = notificationsList
            .map((item) => AppNotification.fromJson(item))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load notifications: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = json.encode(
        _notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        final settings = json.decode(settingsJson);
        _showToastNotifications = settings['showToastNotifications'] ?? true;
        _showPersistentNotifications = settings['showPersistentNotifications'] ?? true;
        _soundEnabled = settings['soundEnabled'] ?? true;
        _vibrationEnabled = settings['vibrationEnabled'] ?? true;
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode({
        'showToastNotifications': _showToastNotifications,
        'showPersistentNotifications': _showPersistentNotifications,
        'soundEnabled': _soundEnabled,
        'vibrationEnabled': _vibrationEnabled,
      });
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  // Utility methods
  bool hasUnreadNotifications() => unreadCount > 0;

  bool hasHighPriorityNotifications() =>
      _notifications.any((n) => n.isHighPriority && !n.isRead);

  bool hasUrgentNotifications() =>
      _notifications.any((n) => n.isUrgent && !n.isRead);

  // Get notification statistics
  Map<String, int> getNotificationStats() {
    final stats = <String, int>{};
    for (final notification in _notifications) {
      final typeKey = notification.type.toString().split('.').last;
      stats[typeKey] = (stats[typeKey] ?? 0) + 1;
    }
    return stats;
  }
}
