import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/payment.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/notification_service.dart';
import '../providers/loyalty_provider.dart';

class PaymentProvider with ChangeNotifier {
  static const String _savedCardsKey = 'saved_payment_cards';
  static const String _savedAddressesKey = 'saved_shipping_addresses';
  static const String _ordersKey = 'user_orders';
  static const String _transactionsKey = 'payment_transactions';

  // Current checkout state
  List<CartItem> _checkoutItems = [];
  ShippingAddress? _selectedShippingAddress;
  PaymentCard? _selectedPaymentCard;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  String _promoCode = '';
  double _discountAmount = 0.0;

  // Saved data
  List<PaymentCard> _savedCards = [];
  List<ShippingAddress> _savedAddresses = [];
  List<Order> _orders = [];
  List<PaymentTransaction> _transactions = [];

  // UI state
  bool _isProcessingPayment = false;
  String _processingMessage = '';
  String _errorMessage = '';
  double _processingProgress = 0.0;

  // Getters
  List<CartItem> get checkoutItems => _checkoutItems;
  ShippingAddress? get selectedShippingAddress => _selectedShippingAddress;
  PaymentCard? get selectedPaymentCard => _selectedPaymentCard;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  String get promoCode => _promoCode;
  double get discountAmount => _discountAmount;

  List<PaymentCard> get savedCards => _savedCards;
  List<ShippingAddress> get savedAddresses => _savedAddresses;
  List<Order> get orders => _orders;
  List<PaymentTransaction> get transactions => _transactions;

  bool get isProcessingPayment => _isProcessingPayment;
  String get processingMessage => _processingMessage;
  String get errorMessage => _errorMessage;
  double get processingProgress => _processingProgress;

  // Calculated totals
  double get subtotal => _checkoutItems.fold(0, (sum, item) => sum + item.total);
  double get tax => _selectedShippingAddress != null
      ? PaymentUtils.calculateTax(subtotal, _selectedShippingAddress!.state)
      : 0.0;
  double get shipping => _selectedShippingAddress != null
      ? PaymentUtils.calculateShipping(subtotal, _selectedShippingAddress!.state)
      : 0.0;
  double get total => subtotal + tax + shipping - discountAmount;

  PaymentProvider() {
    _loadSavedData();
  }

  // Checkout setup
  void startCheckout(List<CartItem> cartItems) {
    _checkoutItems = List.from(cartItems);
    _discountAmount = 0.0;
    _promoCode = '';
    notifyListeners();
  }

  // Address management
  void setShippingAddress(ShippingAddress address) {
    _selectedShippingAddress = address;
    notifyListeners();
  }

  void addShippingAddress(ShippingAddress address) {
    // If it's the default, remove default from others
    if (address.isDefault) {
      for (var addr in _savedAddresses) {
        if (addr.isDefault && addr.id != address.id) {
          final index = _savedAddresses.indexWhere((a) => a.id == addr.id);
          _savedAddresses[index] = addr.copyWith(isDefault: false);
        }
      }
    }

    final existingIndex = _savedAddresses.indexWhere((a) => a.id == address.id);
    if (existingIndex != -1) {
      _savedAddresses[existingIndex] = address;
    } else {
      _savedAddresses.add(address);
    }

    _saveAddresses();
    notifyListeners();
  }

  void removeShippingAddress(String addressId) {
    _savedAddresses.removeWhere((address) => address.id == addressId);
    if (_selectedShippingAddress?.id == addressId) {
      _selectedShippingAddress = null;
    }
    _saveAddresses();
    notifyListeners();
  }

  // Payment method management
  void setPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    // Clear selected card if switching to non-card method
    if (method != PaymentMethod.creditCard && method != PaymentMethod.debitCard) {
      _selectedPaymentCard = null;
    }
    notifyListeners();
  }

  void setPaymentCard(PaymentCard? card) {
    _selectedPaymentCard = card;
    if (card != null) {
      _selectedPaymentMethod = PaymentMethod.creditCard;
    }
    notifyListeners();
  }

  void addPaymentCard(PaymentCard card) {
    // If it's the default, remove default from others
    if (card.isDefault) {
      for (var c in _savedCards) {
        if (c.isDefault && c.id != card.id) {
          final index = _savedCards.indexWhere((crd) => crd.id == c.id);
          _savedCards[index] = c.copyWith(isDefault: false);
        }
      }
    }

    final existingIndex = _savedCards.indexWhere((c) => c.id == card.id);
    if (existingIndex != -1) {
      _savedCards[existingIndex] = card;
    } else {
      _savedCards.add(card);
    }

    _saveCards();
    notifyListeners();
  }

  void removePaymentCard(String cardId) {
    _savedCards.removeWhere((card) => card.id == cardId);
    if (_selectedPaymentCard?.id == cardId) {
      _selectedPaymentCard = null;
    }
    _saveCards();
    notifyListeners();
  }

  // Promo code
  void applyPromoCode(String code) {
    _promoCode = code;
    // Simple promo code logic for demo
    if (code.toLowerCase() == 'save10') {
      _discountAmount = subtotal * 0.1; // 10% off
    } else if (code.toLowerCase() == 'free20') {
      _discountAmount = 20.0; // $20 off
    } else {
      _discountAmount = 0.0;
    }
    notifyListeners();
  }

  void removePromoCode() {
    _promoCode = '';
    _discountAmount = 0.0;
    notifyListeners();
  }

  // Payment processing
  Future<Order?> processPayment(BuildContext context) async {
    if (_selectedShippingAddress == null) {
      _errorMessage = 'Please select a shipping address';
      notifyListeners();
      return null;
    }

    if (_selectedPaymentMethod == PaymentMethod.creditCard ||
        _selectedPaymentMethod == PaymentMethod.debitCard) {
      if (_selectedPaymentCard == null) {
        _errorMessage = 'Please select or add a payment card';
        notifyListeners();
        return null;
      }
    }

    _isProcessingPayment = true;
    _errorMessage = '';
    _processingProgress = 0.0;
    notifyListeners();

    try {
      // Step 1: Validate payment
      _processingMessage = 'Validating payment information...';
      _processingProgress = 0.2;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));

      // Step 2: Process payment
      _processingMessage = 'Processing payment...';
      _processingProgress = 0.4;
      notifyListeners();

      final paymentStatus = await PaymentUtils.simulatePayment(total, _selectedPaymentMethod);
      await Future.delayed(const Duration(seconds: 1));

      if (paymentStatus == PaymentStatus.failed) {
        throw Exception('Payment was declined. Please try again or use a different payment method.');
      }

      // Step 3: Create order
      _processingMessage = 'Creating your order...';
      _processingProgress = 0.6;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));

      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      final order = await _createOrder(orderId);

      // Step 4: Process transaction
      _processingMessage = 'Finalizing transaction...';
      _processingProgress = 0.8;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));

      final transaction = PaymentTransaction(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        amount: total,
        paymentMethod: _selectedPaymentMethod,
        status: paymentStatus,
        transactionDate: DateTime.now(),
        transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      );

      _transactions.add(transaction);

      // Step 5: Success
      _processingMessage = 'Order completed successfully!';
      _processingProgress = 1.0;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));

      // Award loyalty points
      final loyaltyProvider = Provider.of<LoyaltyProvider>(context, listen: false);
      loyaltyProvider.earnPurchasePoints(total, orderId: orderId);

      _orders.add(order);
      _saveOrders();
      _saveTransactions();

      // Show success notification
      NotificationService().showSuccess(
        context,
        'Order Placed!',
        'Your order #${order.id} has been placed successfully',
      );

      return order;

    } catch (e) {
      _errorMessage = e.toString();
      _processingMessage = 'Payment failed';
      _processingProgress = 0.0;

      // Show error notification
      NotificationService().showError(
        context,
        'Payment Failed',
        e.toString(),
      );

      return null;
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }

  Future<Order> _createOrder(String orderId) async {
    final orderItems = _checkoutItems.map((item) => OrderItem(
      productId: item.product.id,
      productName: item.product.name,
      productImage: item.product.imageUrl,
      price: item.product.price,
      quantity: item.quantity,
      total: item.total,
    )).toList();

    final earnedPoints = PointEarningRules.calculatePurchasePoints(subtotal).round();

    return Order(
      id: orderId,
      items: orderItems,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      discount: discountAmount,
      total: total,
      shippingAddress: _selectedShippingAddress!,
      paymentMethod: _selectedPaymentMethod,
      paymentCard: _selectedPaymentCard,
      status: OrderStatus.confirmed,
      orderDate: DateTime.now(),
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
      earnedPoints: earnedPoints,
    );
  }

  // Utility methods
  bool canCheckout() {
    return _checkoutItems.isNotEmpty &&
           _selectedShippingAddress != null &&
           ((_selectedPaymentMethod == PaymentMethod.creditCard ||
             _selectedPaymentMethod == PaymentMethod.debitCard)
            ? _selectedPaymentCard != null : true);
  }

  void clearCheckout() {
    _checkoutItems.clear();
    _selectedShippingAddress = null;
    _selectedPaymentCard = null;
    _selectedPaymentMethod = PaymentMethod.creditCard;
    _promoCode = '';
    _discountAmount = 0.0;
    _errorMessage = '';
    notifyListeners();
  }

  // Data persistence
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved cards
      final cardsJson = prefs.getString(_savedCardsKey);
      if (cardsJson != null) {
        final cardsList = json.decode(cardsJson) as List;
        _savedCards = cardsList.map((card) => PaymentCard.fromJson(card)).toList();
        // Set default card if exists
        final defaultCard = _savedCards.firstWhere(
          (card) => card.isDefault,
          orElse: () => _savedCards.isNotEmpty ? _savedCards.first : PaymentCard(
            id: '',
            cardNumber: '',
            cardHolderName: '',
            expiryMonth: '',
            expiryYear: '',
            cvv: '',
            cardType: '',
          ),
        );
        if (defaultCard.id.isNotEmpty) {
          _selectedPaymentCard = defaultCard;
        }
      }

      // Load saved addresses
      final addressesJson = prefs.getString(_savedAddressesKey);
      if (addressesJson != null) {
        final addressesList = json.decode(addressesJson) as List;
        _savedAddresses = addressesList.map((addr) => ShippingAddress.fromJson(addr)).toList();
        // Set default address if exists
        final defaultAddress = _savedAddresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => _savedAddresses.isNotEmpty ? _savedAddresses.first : ShippingAddress(
            id: '',
            fullName: '',
            addressLine1: '',
            city: '',
            state: '',
            postalCode: '',
            country: '',
            phoneNumber: '',
          ),
        );
        if (defaultAddress.id.isNotEmpty) {
          _selectedShippingAddress = defaultAddress;
        }
      }

      // Load orders
      final ordersJson = prefs.getString(_ordersKey);
      if (ordersJson != null) {
        final ordersList = json.decode(ordersJson) as List;
        _orders = ordersList.map((order) => Order.fromJson(order)).toList();
      }

      // Load transactions
      final transactionsJson = prefs.getString(_transactionsKey);
      if (transactionsJson != null) {
        final transactionsList = json.decode(transactionsJson) as List;
        _transactions = transactionsList.map((txn) => PaymentTransaction.fromJson(txn)).toList();
      }

    } catch (e) {
      debugPrint('Error loading payment data: $e');
    }
  }

  Future<void> _saveCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardsJson = json.encode(_savedCards.map((card) => card.toJson()).toList());
      await prefs.setString(_savedCardsKey, cardsJson);
    } catch (e) {
      debugPrint('Error saving cards: $e');
    }
  }

  Future<void> _saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = json.encode(_savedAddresses.map((addr) => addr.toJson()).toList());
      await prefs.setString(_savedAddressesKey, addressesJson);
    } catch (e) {
      debugPrint('Error saving addresses: $e');
    }
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = json.encode(_orders.map((order) => order.toJson()).toList());
      await prefs.setString(_ordersKey, ordersJson);
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = json.encode(_transactions.map((txn) => txn.toJson()).toList());
      await prefs.setString(_transactionsKey, transactionsJson);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  // Demo data for testing
  void loadDemoData() {
    // Add demo cards
    addPaymentCard(PaymentCard(
      id: 'demo_card_1',
      cardNumber: '4111111111111111',
      cardHolderName: 'John Doe',
      expiryMonth: '12',
      expiryYear: '26',
      cvv: '123',
      cardType: 'Visa',
      isDefault: true,
    ));

    // Add demo address
    addShippingAddress(ShippingAddress(
      id: 'demo_address_1',
      fullName: 'John Doe',
      addressLine1: '123 Main Street',
      addressLine2: 'Apt 4B',
      city: 'San Francisco',
      state: 'CA',
      postalCode: '94102',
      country: 'United States',
      phoneNumber: '+1 (555) 123-4567',
      isDefault: true,
    ));

    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
