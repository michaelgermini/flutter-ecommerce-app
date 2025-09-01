import 'cart_item.dart';
import 'user.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final User user;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String? shippingAddress;
  final String? paymentMethod;

  const Order({
    required this.id,
    required this.user,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.shippingAddress,
    this.paymentMethod,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.values[json['status'] as int? ?? 0],
      createdAt: DateTime.parse(json['createdAt'] as String),
      shippingAddress: json['shippingAddress'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
    };
  }

  @override
  String toString() {
    return 'Order(id: $id, total: $total, status: $status)';
  }
}
