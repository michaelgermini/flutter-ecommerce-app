import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../providers/notification_provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // Show toast notification
  void showToast({
    required BuildContext context,
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    NotificationPriority priority = NotificationPriority.normal,
    String? actionLabel,
    VoidCallback? actionCallback,
    bool showIcon = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;
    IconData? icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        icon = Icons.error;
        break;
      case NotificationType.warning:
        backgroundColor = colorScheme.secondary;
        foregroundColor = colorScheme.onSecondary;
        icon = Icons.warning;
        break;
      case NotificationType.cart:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        icon = Icons.shopping_cart;
        break;
      case NotificationType.wishlist:
        backgroundColor = Colors.pink;
        foregroundColor = Colors.white;
        icon = Icons.favorite;
        break;
      case NotificationType.order:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        icon = Icons.receipt;
        break;
      case NotificationType.promotion:
        backgroundColor = Colors.orange;
        foregroundColor = Colors.white;
        icon = Icons.local_offer;
        break;
      default:
        backgroundColor = colorScheme.surface;
        foregroundColor = colorScheme.onSurface;
        icon = Icons.info;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (showIcon && icon != null) ...[
              Icon(
                icon,
                color: foregroundColor,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      color: foregroundColor.withOpacity(0.9),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: priority == NotificationPriority.high
            ? const Duration(seconds: 4)
            : priority == NotificationPriority.urgent
                ? const Duration(seconds: 6)
                : const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: foregroundColor,
                onPressed: actionCallback ?? () {},
              )
            : null,
      ),
    );
  }

  // Show notification using provider
  void showNotification({
    required BuildContext context,
    required NotificationProvider notificationProvider,
    required AppNotification notification,
  }) {
    // Add to notification center
    notificationProvider.addNotification(notification);

    // Show toast if enabled
    if (notificationProvider.showToastNotifications) {
      showToast(
        context: context,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        priority: notification.priority,
        actionLabel: notification.actionLabel,
        actionCallback: notification.actionCallback,
      );
    }
  }

  // Quick notification methods using templates
  void showSuccess(BuildContext context, String title, String message) {
    showToast(
      context: context,
      title: title,
      message: message,
      type: NotificationType.success,
    );
  }

  void showError(BuildContext context, String title, String message) {
    showToast(
      context: context,
      title: title,
      message: message,
      type: NotificationType.error,
      priority: NotificationPriority.high,
    );
  }

  void showWarning(BuildContext context, String title, String message) {
    showToast(
      context: context,
      title: title,
      message: message,
      type: NotificationType.warning,
    );
  }

  void showInfo(BuildContext context, String title, String message) {
    showToast(
      context: context,
      title: title,
      message: message,
      type: NotificationType.info,
    );
  }

  // Cart specific notifications
  void showCartAdded(BuildContext context, String productName) {
    showToast(
      context: context,
      title: 'Added to Cart',
      message: '$productName has been added to your cart',
      type: NotificationType.cart,
      actionLabel: 'View Cart',
    );
  }

  void showWishlistAdded(BuildContext context, String productName) {
    showToast(
      context: context,
      title: 'Added to Wishlist',
      message: '$productName has been added to your wishlist',
      type: NotificationType.wishlist,
      actionLabel: 'View Wishlist',
    );
  }

  void showOrderPlaced(BuildContext context, String orderId) {
    showToast(
      context: context,
      title: 'Order Placed!',
      message: 'Your order #$orderId has been placed successfully',
      type: NotificationType.order,
      priority: NotificationPriority.high,
      actionLabel: 'Track Order',
    );
  }

  void showPaymentSuccess(BuildContext context, double amount) {
    showToast(
      context: context,
      title: 'Payment Successful',
      message: 'Payment of \$${amount.toStringAsFixed(2)} has been processed',
      type: NotificationType.success,
      priority: NotificationPriority.high,
    );
  }

  // Clear all current notifications
  void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  // Hide current notification
  void hideCurrent(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  // Show loading notification
  void showLoading(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 30),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Update loading notification
  void updateLoading(BuildContext context, String message) {
    hideCurrent(context);
    showLoading(context, message);
  }

  // Hide loading notification
  void hideLoading(BuildContext context) {
    hideCurrent(context);
  }
}
