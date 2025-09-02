enum NotificationType {
  success,
  error,
  warning,
  info,
  cart,
  wishlist,
  order,
  promotion,
  system,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final bool isPersistent;
  final String? actionLabel;
  final VoidCallback? actionCallback;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.normal,
    DateTime? timestamp,
    this.isRead = false,
    this.isPersistent = false,
    this.actionLabel,
    this.actionCallback,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    bool? isPersistent,
    String? actionLabel,
    VoidCallback? actionCallback,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isPersistent: isPersistent ?? this.isPersistent,
      actionLabel: actionLabel ?? this.actionLabel,
      actionCallback: actionCallback ?? this.actionCallback,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'priority': priority.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isPersistent': isPersistent,
      'actionLabel': actionLabel,
      'data': data,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.info,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      isPersistent: json['isPersistent'] ?? false,
      actionLabel: json['actionLabel'],
      data: json['data'],
    );
  }

  // Helper methods for notification types
  bool get isSuccess => type == NotificationType.success;
  bool get isError => type == NotificationType.error;
  bool get isWarning => type == NotificationType.warning;
  bool get isInfo => type == NotificationType.info;
  bool get isCart => type == NotificationType.cart;
  bool get isWishlist => type == NotificationType.wishlist;
  bool get isOrder => type == NotificationType.order;
  bool get isPromotion => type == NotificationType.promotion;
  bool get isSystem => type == NotificationType.system;

  bool get isHighPriority => priority == NotificationPriority.high || priority == NotificationPriority.urgent;
  bool get isUrgent => priority == NotificationPriority.urgent;

  String get typeIcon {
    switch (type) {
      case NotificationType.success:
        return '✅';
      case NotificationType.error:
        return '❌';
      case NotificationType.warning:
        return '⚠️';
      case NotificationType.info:
        return 'ℹ️';
      case NotificationType.cart:
        return '🛒';
      case NotificationType.wishlist:
        return '❤️';
      case NotificationType.order:
        return '📦';
      case NotificationType.promotion:
        return '🎉';
      case NotificationType.system:
        return '🔧';
    }
  }

  Duration get autoHideDuration {
    switch (priority) {
      case NotificationPriority.low:
        return const Duration(seconds: 2);
      case NotificationPriority.normal:
        return const Duration(seconds: 3);
      case NotificationPriority.high:
        return const Duration(seconds: 4);
      case NotificationPriority.urgent:
        return const Duration(seconds: 5);
    }
  }
}

// Predefined notification templates
class NotificationTemplates {
  static AppNotification cartItemAdded(String productName) {
    return AppNotification(
      id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Added to Cart',
      message: '$productName has been added to your cart',
      type: NotificationType.cart,
      priority: NotificationPriority.normal,
      actionLabel: 'View Cart',
    );
  }

  static AppNotification wishlistItemAdded(String productName) {
    return AppNotification(
      id: 'wishlist_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Added to Wishlist',
      message: '$productName has been added to your wishlist',
      type: NotificationType.wishlist,
      priority: NotificationPriority.normal,
      actionLabel: 'View Wishlist',
    );
  }

  static AppNotification orderPlaced(String orderId) {
    return AppNotification(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Order Placed Successfully',
      message: 'Your order #$orderId has been placed successfully',
      type: NotificationType.order,
      priority: NotificationPriority.high,
      isPersistent: true,
      actionLabel: 'Track Order',
    );
  }

  static AppNotification paymentSuccess(double amount) {
    return AppNotification(
      id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Payment Successful',
      message: 'Payment of \$${amount.toStringAsFixed(2)} has been processed',
      type: NotificationType.success,
      priority: NotificationPriority.high,
    );
  }

  static AppNotification promotion(String title, String message) {
    return AppNotification(
      id: 'promo_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: NotificationType.promotion,
      priority: NotificationPriority.normal,
      isPersistent: true,
      actionLabel: 'Shop Now',
    );
  }

  static AppNotification error(String title, String message) {
    return AppNotification(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: NotificationType.error,
      priority: NotificationPriority.high,
    );
  }

  static AppNotification success(String title, String message) {
    return AppNotification(
      id: 'success_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: NotificationType.success,
      priority: NotificationPriority.normal,
    );
  }
}
