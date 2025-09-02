import 'package:flutter/material.dart';

enum PaymentMethod {
  creditCard,
  debitCard,
  paypal,
  applePay,
  googlePay,
  bankTransfer,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

class PaymentCard {
  final String id;
  final String cardNumber;
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String cardType;
  final bool isDefault;

  const PaymentCard({
    required this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.cardType,
    this.isDefault = false,
  });

  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  bool get isExpired {
    final now = DateTime.now();
    final expiryDate = DateTime(int.parse('20$expiryYear'), int.parse(expiryMonth));
    return expiryDate.isBefore(now);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'cardType': cardType,
      'isDefault': isDefault,
    };
  }

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'],
      cardNumber: json['cardNumber'],
      cardHolderName: json['cardHolderName'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      cvv: json['cvv'],
      cardType: json['cardType'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  PaymentCard copyWith({
    String? id,
    String? cardNumber,
    String? cardHolderName,
    String? expiryMonth,
    String? expiryYear,
    String? cvv,
    String? cardType,
    bool? isDefault,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cvv: cvv ?? this.cvv,
      cardType: cardType ?? this.cardType,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class ShippingAddress {
  final String id;
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phoneNumber;
  final bool isDefault;

  const ShippingAddress({
    required this.id,
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
    this.isDefault = false,
  });

  String get formattedAddress {
    return '$addressLine1${addressLine2 != null ? ', $addressLine2' : ''}\n$city, $state $postalCode\n$country';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
    };
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'],
      fullName: json['fullName'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      phoneNumber: json['phoneNumber'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double total;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      price: json['price'],
      quantity: json['quantity'],
      total: json['total'],
    );
  }
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final double total;
  final ShippingAddress shippingAddress;
  final PaymentMethod paymentMethod;
  final PaymentCard? paymentCard;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? estimatedDeliveryDate;
  final String? trackingNumber;
  final int? earnedPoints;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.total,
    required this.shippingAddress,
    required this.paymentMethod,
    this.paymentCard,
    this.status = OrderStatus.pending,
    required this.orderDate,
    this.estimatedDeliveryDate,
    this.trackingNumber,
    this.earnedPoints,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.grey;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'discount': discount,
      'total': total,
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethod': paymentMethod.toString(),
      'paymentCard': paymentCard?.toJson(),
      'status': status.toString(),
      'orderDate': orderDate.toIso8601String(),
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      'trackingNumber': trackingNumber,
      'earnedPoints': earnedPoints,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'],
      tax: json['tax'],
      shipping: json['shipping'],
      discount: json['discount'],
      total: json['total'],
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress']),
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.toString() == json['paymentMethod'],
        orElse: () => PaymentMethod.creditCard,
      ),
      paymentCard: json['paymentCard'] != null
          ? PaymentCard.fromJson(json['paymentCard'])
          : null,
      status: OrderStatus.values.firstWhere(
        (status) => status.toString() == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      orderDate: DateTime.parse(json['orderDate']),
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
          ? DateTime.parse(json['estimatedDeliveryDate'])
          : null,
      trackingNumber: json['trackingNumber'],
      earnedPoints: json['earnedPoints'],
    );
  }
}

class PaymentTransaction {
  final String id;
  final String orderId;
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final DateTime transactionDate;
  final String? transactionId;
  final String? failureReason;

  const PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.transactionDate,
    this.transactionId,
    this.failureReason,
  });

  String get statusText {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  Color get statusColor {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.purple;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'paymentMethod': paymentMethod.toString(),
      'status': status.toString(),
      'transactionDate': transactionDate.toIso8601String(),
      'transactionId': transactionId,
      'failureReason': failureReason,
    };
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'],
      orderId: json['orderId'],
      amount: json['amount'],
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.toString() == json['paymentMethod'],
        orElse: () => PaymentMethod.creditCard,
      ),
      status: PaymentStatus.values.firstWhere(
        (status) => status.toString() == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionDate: DateTime.parse(json['transactionDate']),
      transactionId: json['transactionId'],
      failureReason: json['failureReason'],
    );
  }
}

// Utility functions for payment simulation
class PaymentUtils {
  static String detectCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) return 'MasterCard';
    if (cardNumber.startsWith('3')) return 'American Express';
    if (cardNumber.startsWith('6')) return 'Discover';
    return 'Unknown';
  }

  static bool isValidCardNumber(String cardNumber) {
    // Simple Luhn algorithm check for demo purposes
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) return false;

    int sum = 0;
    bool alternate = false;
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  static bool isValidExpiryDate(String month, String year) {
    final now = DateTime.now();
    final expiryDate = DateTime(2000 + int.parse(year), int.parse(month));
    return expiryDate.isAfter(now);
  }

  static bool isValidCVV(String cvv, String cardType) {
    if (cardType == 'American Express') {
      return cvv.length == 4 && RegExp(r'^\d{4}$').hasMatch(cvv);
    } else {
      return cvv.length == 3 && RegExp(r'^\d{3}$').hasMatch(cvv);
    }
  }

  static String formatCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleanNumber.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleanNumber[i]);
    }
    return buffer.toString();
  }

  // Simulate payment processing with different outcomes
  static Future<PaymentStatus> simulatePayment(double amount, PaymentMethod method) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    // Random success/failure for demo (90% success rate)
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 90) {
      return PaymentStatus.completed;
    } else if (random < 95) {
      return PaymentStatus.failed;
    } else {
      return PaymentStatus.processing;
    }
  }

  static double calculateTax(double subtotal, String state) {
    // Simple tax calculation - in real app would use proper tax rates
    const taxRates = {
      'CA': 0.0825, // California
      'NY': 0.04,   // New York
      'TX': 0.0625, // Texas
      'FL': 0.06,   // Florida
    };
    return subtotal * (taxRates[state] ?? 0.08);
  }

  static double calculateShipping(double subtotal, String state) {
    // Simple shipping calculation
    if (subtotal >= 50) return 0; // Free shipping over $50
    return state == 'AK' || state == 'HI' ? 15.0 : 5.0;
  }
}
