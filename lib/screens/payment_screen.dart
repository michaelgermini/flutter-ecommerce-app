import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../providers/cart_provider.dart';
import '../models/payment.dart';
import '../widgets/micro_interactions.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();

  final _addressNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  final _promoCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load demo data for testing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentProvider = context.read<PaymentProvider>();
      final cartProvider = context.read<CartProvider>();
      paymentProvider.startCheckout(cartProvider.items);
      paymentProvider.loadDemoData();
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    _addressNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isProcessingPayment) {
            return _buildProcessingScreen(paymentProvider);
          }

          return Stepper(
            currentStep: _currentStep,
            onStepContinue: _canContinue(paymentProvider) ? () => _continue(paymentProvider) : null,
            onStepCancel: _currentStep > 0 ? () => _cancel(paymentProvider) : null,
            onStepTapped: (step) => _goToStep(step, paymentProvider),
            controlsBuilder: (context, details) => _buildStepControls(details, paymentProvider),
            steps: [
              Step(
                title: const Text('Order Summary'),
                content: _buildOrderSummary(paymentProvider),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const Text('Shipping Address'),
                content: _buildShippingAddress(paymentProvider),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : _currentStep == 1 ? StepState.editing : StepState.indexed,
              ),
              Step(
                title: const Text('Payment Method'),
                content: _buildPaymentMethod(paymentProvider),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : _currentStep == 2 ? StepState.editing : StepState.indexed,
              ),
              Step(
                title: const Text('Review & Pay'),
                content: _buildOrderReview(paymentProvider),
                isActive: _currentStep >= 3,
                state: _currentStep == 3 ? StepState.editing : StepState.indexed,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProcessingScreen(PaymentProvider paymentProvider) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: paymentProvider.processingProgress,
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
                Icon(
                  Icons.payment,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            paymentProvider.processingMessage,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: paymentProvider.processingProgress,
            backgroundColor: theme.colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            '${(paymentProvider.processingProgress * 100).round()}% Complete',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(PaymentProvider paymentProvider) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Items list
        ...paymentProvider.checkoutItems.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(item.product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${item.quantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        )),

        const SizedBox(height: 16),

        // Promo code
        _buildPromoCodeSection(paymentProvider),

        const SizedBox(height: 16),

        // Order totals
        _buildOrderTotals(paymentProvider),
      ],
    );
  }

  Widget _buildPromoCodeSection(PaymentProvider paymentProvider) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promo Code',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoCodeController,
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_promoCodeController.text.isNotEmpty) {
                    paymentProvider.applyPromoCode(_promoCodeController.text);
                  }
                },
                child: const Text('Apply'),
              ),
            ],
          ),
          if (paymentProvider.promoCode.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Applied: ${paymentProvider.promoCode.toUpperCase()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    paymentProvider.removePromoCode();
                    _promoCodeController.clear();
                  },
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderTotals(PaymentProvider paymentProvider) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', paymentProvider.subtotal),
          _buildTotalRow('Shipping', paymentProvider.shipping),
          _buildTotalRow('Tax', paymentProvider.tax),
          if (paymentProvider.discountAmount > 0)
            _buildTotalRow('Discount', -paymentProvider.discountAmount, isDiscount: true),
          const Divider(height: 16),
          _buildTotalRow('Total', paymentProvider.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isDiscount = false, bool isTotal = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? theme.colorScheme.error : theme.colorScheme.onSurface,
            ),
          ),
          Text(
            '${isDiscount && amount > 0 ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? theme.colorScheme.error : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(PaymentProvider paymentProvider) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saved addresses
        if (paymentProvider.savedAddresses.isNotEmpty) ...[
          Text(
            'Select Shipping Address',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...paymentProvider.savedAddresses.map((address) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<ShippingAddress>(
              value: address,
              groupValue: paymentProvider.selectedShippingAddress,
              onChanged: (value) {
                if (value != null) {
                  paymentProvider.setShippingAddress(value);
                }
              },
              title: Text(address.fullName),
              subtitle: Text(address.formattedAddress),
              secondary: address.isDefault ? Icon(
                Icons.star,
                color: theme.colorScheme.primary,
                size: 20,
              ) : null,
            ),
          )),
          const SizedBox(height: 16),
        ],

        // Add new address button
        Center(
          child: ElevatedButton.icon(
            onPressed: () => _showAddAddressDialog(context, paymentProvider),
            icon: const Icon(Icons.add),
            label: const Text('Add New Address'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),

        if (paymentProvider.errorMessage.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              paymentProvider.errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentMethod(PaymentProvider paymentProvider) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment method selection
        Text(
          'Select Payment Method',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        ...PaymentMethod.values.map((method) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: RadioListTile<PaymentMethod>(
            value: method,
            groupValue: paymentProvider.selectedPaymentMethod,
            onChanged: (value) {
              if (value != null) {
                paymentProvider.setPaymentMethod(value);
              }
            },
            title: Text(_getPaymentMethodName(method)),
            secondary: Icon(_getPaymentMethodIcon(method)),
          ),
        )),

        const SizedBox(height: 16),

        // Card selection (if credit/debit card is selected)
        if (paymentProvider.selectedPaymentMethod == PaymentMethod.creditCard ||
            paymentProvider.selectedPaymentMethod == PaymentMethod.debitCard) ...[
          if (paymentProvider.savedCards.isNotEmpty) ...[
            Text(
              'Select Payment Card',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...paymentProvider.savedCards.map((card) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<PaymentCard>(
                value: card,
                groupValue: paymentProvider.selectedPaymentCard,
                onChanged: (value) {
                  if (value != null) {
                    paymentProvider.setPaymentCard(value);
                  }
                },
                title: Text('${card.cardType} **** ${card.cardNumber.substring(card.cardNumber.length - 4)}'),
                subtitle: Text('Expires ${card.expiryMonth}/${card.expiryYear}'),
                secondary: card.isDefault ? Icon(
                  Icons.star,
                  color: theme.colorScheme.primary,
                  size: 20,
                ) : null,
              ),
            )),
          ],

          const SizedBox(height: 16),

          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showAddCardDialog(context, paymentProvider),
              icon: const Icon(Icons.add),
              label: const Text('Add New Card'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],

        if (paymentProvider.errorMessage.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              paymentProvider.errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrderReview(PaymentProvider paymentProvider) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order summary
        Text(
          'Order Summary',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Shipping address
        _buildReviewSection(
          'Shipping Address',
          paymentProvider.selectedShippingAddress?.formattedAddress ?? 'No address selected',
        ),

        // Payment method
        _buildReviewSection(
          'Payment Method',
          _getPaymentMethodName(paymentProvider.selectedPaymentMethod),
          subtitle: paymentProvider.selectedPaymentCard != null
              ? '${paymentProvider.selectedPaymentCard!.cardType} **** ${paymentProvider.selectedPaymentCard!.cardNumber.substring(paymentProvider.selectedPaymentCard!.cardNumber.length - 4)}'
              : null,
        ),

        // Order items
        _buildReviewSection(
          'Items (${paymentProvider.checkoutItems.length})',
          paymentProvider.checkoutItems.map((item) =>
            '${item.product.name} x${item.quantity} - \$${item.total.toStringAsFixed(2)}'
          ).join('\n'),
        ),

        // Final totals
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildTotalRow('Subtotal', paymentProvider.subtotal),
              _buildTotalRow('Shipping', paymentProvider.shipping),
              _buildTotalRow('Tax', paymentProvider.tax),
              if (paymentProvider.discountAmount > 0)
                _buildTotalRow('Discount', -paymentProvider.discountAmount, isDiscount: true),
              const Divider(height: 16),
              _buildTotalRow('Total', paymentProvider.total, isTotal: true),
            ],
          ),
        ),

        if (paymentProvider.errorMessage.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              paymentProvider.errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewSection(String title, String content, {String? subtitle}) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepControls(ControlsDetails details, PaymentProvider paymentProvider) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: details.onStepCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canContinue(paymentProvider) ? details.onStepContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(_currentStep == 3 ? 'Place Order' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue(PaymentProvider paymentProvider) {
    switch (_currentStep) {
      case 0:
        return true; // Order summary always valid
      case 1:
        return paymentProvider.selectedShippingAddress != null;
      case 2:
        return (paymentProvider.selectedPaymentMethod == PaymentMethod.creditCard ||
                paymentProvider.selectedPaymentMethod == PaymentMethod.debitCard)
            ? paymentProvider.selectedPaymentCard != null
            : true;
      case 3:
        return paymentProvider.canCheckout();
      default:
        return false;
    }
  }

  void _continue(PaymentProvider paymentProvider) {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      // Process payment
      _processPayment(paymentProvider);
    }
  }

  void _cancel(PaymentProvider paymentProvider) {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _goToStep(int step, PaymentProvider paymentProvider) {
    if (step <= _currentStep || _canContinue(paymentProvider)) {
      setState(() => _currentStep = step);
    }
  }

  void _processPayment(PaymentProvider paymentProvider) async {
    final order = await paymentProvider.processPayment(context);

    if (order != null) {
      // Navigate to order confirmation
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(order: order),
        ),
      );
    }
  }

  void _showAddAddressDialog(BuildContext context, PaymentProvider paymentProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Shipping Address'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _addressNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressLine1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Address Line 1',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressLine2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Address Line 2 (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _postalCodeController,
                          decoration: const InputDecoration(
                            labelText: 'ZIP Code',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final address = ShippingAddress(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    fullName: _addressNameController.text,
                    addressLine1: _addressLine1Controller.text,
                    addressLine2: _addressLine2Controller.text.isNotEmpty ? _addressLine2Controller.text : null,
                    city: _cityController.text,
                    state: _stateController.text,
                    postalCode: _postalCodeController.text,
                    country: 'United States',
                    phoneNumber: _phoneController.text,
                    isDefault: paymentProvider.savedAddresses.isEmpty,
                  );

                  paymentProvider.addShippingAddress(address);
                  paymentProvider.setShippingAddress(address);

                  // Clear form
                  _addressNameController.clear();
                  _addressLine1Controller.clear();
                  _addressLine2Controller.clear();
                  _cityController.clear();
                  _stateController.clear();
                  _postalCodeController.clear();
                  _phoneController.clear();

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Address'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCardDialog(BuildContext context, PaymentProvider paymentProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Payment Card'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                      hintText: '1234 5678 9012 3456',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final formatted = PaymentUtils.formatCardNumber(value.replaceAll(' ', ''));
                      if (formatted != value) {
                        _cardNumberController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (!PaymentUtils.isValidCardNumber(value!)) return 'Invalid card number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cardHolderController,
                    decoration: const InputDecoration(
                      labelText: 'Cardholder Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryMonthController,
                          decoration: const InputDecoration(
                            labelText: 'MM',
                            border: OutlineInputBorder(),
                            hintText: '12',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            final month = int.tryParse(value!);
                            if (month == null || month < 1 || month > 12) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _expiryYearController,
                          decoration: const InputDecoration(
                            labelText: 'YY',
                            border: OutlineInputBorder(),
                            hintText: '25',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            if (!PaymentUtils.isValidExpiryDate(_expiryMonthController.text, value!)) {
                              return 'Expired';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            border: OutlineInputBorder(),
                            hintText: '123',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            final cardType = PaymentUtils.detectCardType(_cardNumberController.text);
                            if (!PaymentUtils.isValidCVV(value!, cardType)) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final cardType = PaymentUtils.detectCardType(_cardNumberController.text);

                  final card = PaymentCard(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    cardNumber: _cardNumberController.text.replaceAll(' ', ''),
                    cardHolderName: _cardHolderController.text,
                    expiryMonth: _expiryMonthController.text,
                    expiryYear: _expiryYearController.text,
                    cvv: _cvvController.text,
                    cardType: cardType,
                    isDefault: paymentProvider.savedCards.isEmpty,
                  );

                  paymentProvider.addPaymentCard(card);
                  paymentProvider.setPaymentCard(card);

                  // Clear form
                  _cardNumberController.clear();
                  _cardHolderController.clear();
                  _expiryMonthController.clear();
                  _expiryYearController.clear();
                  _cvvController.clear();

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Card'),
            ),
          ],
        );
      },
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.paypal:
        return Icons.payment;
      case PaymentMethod.applePay:
        return Icons.apple;
      case PaymentMethod.googlePay:
        return Icons.g_mobiledata;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
    }
  }
}
