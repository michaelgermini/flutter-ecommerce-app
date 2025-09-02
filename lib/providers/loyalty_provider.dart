import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/loyalty.dart';

class LoyaltyProvider with ChangeNotifier {
  static const String _loyaltyPointsKey = 'loyalty_points';
  static const String _transactionsKey = 'point_transactions';
  static const String _redemptionsKey = 'reward_redemptions';
  static const int _maxTransactions = 100;

  LoyaltyPoints _loyaltyPoints = const LoyaltyPoints(
    currentPoints: 0,
    lifetimePoints: 0,
    currentTier: LoyaltyTier.bronze,
    pointsToNextTier: 1000,
    lastUpdated: null,
  );

  List<PointTransaction> _transactions = [];
  List<RewardRedemption> _redemptions = [];
  List<Reward> _availableRewards = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  LoyaltyPoints get loyaltyPoints => _loyaltyPoints;
  List<PointTransaction> get transactions => _transactions;
  List<RewardRedemption> get redemptions => _redemptions;
  List<Reward> get availableRewards => _availableRewards;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Filtered getters
  List<PointTransaction> get positiveTransactions =>
      _transactions.where((t) => t.isPositive).toList();

  List<PointTransaction> get negativeTransactions =>
      _transactions.where((t) => !t.isPositive).toList();

  List<PointTransaction> getRecentTransactions({int limit = 10}) =>
      _transactions.take(limit).toList();

  List<RewardRedemption> getPendingRedemptions =>
      _redemptions.where((r) => r.status == RedemptionStatus.pending).toList();

  LoyaltyProvider() {
    _loadLoyaltyData();
    _loadSampleRewards();
  }

  // Points management
  void addPoints(int points, PointTransactionType type, String description,
      {String? orderId, String? productId}) {
    final transaction = PointTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      points: points,
      type: type,
      description: description,
      timestamp: DateTime.now(),
      orderId: orderId,
      productId: productId,
    );

    _transactions.insert(0, transaction);

    // Limit transactions
    if (_transactions.length > _maxTransactions) {
      _transactions = _transactions.sublist(0, _maxTransactions);
    }

    // Update points
    final newLifetimePoints = _loyaltyPoints.lifetimePoints + points;
    final newCurrentPoints = _loyaltyPoints.currentPoints + points;
    final newTier = _calculateTier(newLifetimePoints);

    _loyaltyPoints = _loyaltyPoints.copyWith(
      currentPoints: newCurrentPoints,
      lifetimePoints: newLifetimePoints,
      currentTier: newTier,
      pointsToNextTier: _calculatePointsToNextTier(newLifetimePoints, newTier),
      lastUpdated: DateTime.now(),
    );

    _saveLoyaltyData();
    notifyListeners();
  }

  void redeemPoints(int pointsUsed, String rewardId) {
    final redemption = RewardRedemption(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rewardId: rewardId,
      pointsUsed: pointsUsed,
      redeemedAt: DateTime.now(),
    );

    _redemptions.insert(0, redemption);

    // Update points
    final newCurrentPoints = _loyaltyPoints.currentPoints - pointsUsed;
    _loyaltyPoints = _loyaltyPoints.copyWith(
      currentPoints: newCurrentPoints,
      lastUpdated: DateTime.now(),
    );

    // Add transaction record
    final transaction = PointTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_redemption',
      points: -pointsUsed,
      type: PointTransactionType.redemption,
      description: 'Points redeemed for reward',
      timestamp: DateTime.now(),
    );

    _transactions.insert(0, transaction);

    _saveLoyaltyData();
    notifyListeners();
  }

  // Quick action methods
  void earnPurchasePoints(double purchaseAmount, {String? orderId}) {
    final points = PointEarningRules.calculatePurchasePoints(purchaseAmount);
    final tierMultiplier = PointEarningRules.calculateTierMultiplier(_loyaltyPoints.currentTier);
    final totalPoints = points * tierMultiplier;

    addPoints(
      totalPoints,
      PointTransactionType.purchase,
      'Earned ${totalPoints} points for \$${purchaseAmount.toStringAsFixed(2)} purchase',
      orderId: orderId,
    );
  }

  void earnReviewPoints(String productName, {String? productId}) {
    final points = PointEarningRules.pointsPerReview;
    addPoints(
      points,
      PointTransactionType.review,
      'Earned $points points for reviewing $productName',
      productId: productId,
    );
  }

  void earnReferralPoints(String friendName) {
    final points = PointEarningRules.pointsPerReferral;
    addPoints(
      points,
      PointTransactionType.referral,
      'Earned $points points for referring $friendName',
    );
  }

  void earnBirthdayPoints() {
    final points = PointEarningRules.pointsBirthdayBonus;
    addPoints(
      points,
      PointTransactionType.birthday,
      'Earned $points points for birthday bonus!',
    );
  }

  void earnMilestonePoints(String milestone) {
    final points = PointEarningRules.pointsMilestoneBonus;
    addPoints(
      points,
      PointTransactionType.milestone,
      'Earned $points points for $milestone milestone!',
    );
  }

  // Reward redemption
  bool canRedeemReward(Reward reward) {
    return _loyaltyPoints.currentPoints >= reward.pointsRequired && reward.canRedeem;
  }

  void redeemReward(Reward reward) {
    if (!canRedeemReward(reward)) return;

    redeemPoints(reward.pointsRequired, reward.id);

    // Update reward redemptions
    final rewardIndex = _availableRewards.indexWhere((r) => r.id == reward.id);
    if (rewardIndex != -1) {
      final updatedReward = reward.copyWith(
        currentRedemptions: reward.currentRedemptions + 1,
      );
      _availableRewards[rewardIndex] = updatedReward;
    }
  }

  // Helper methods
  LoyaltyTier _calculateTier(int lifetimePoints) {
    if (lifetimePoints >= 5000) return LoyaltyTier.platinum;
    if (lifetimePoints >= 2500) return LoyaltyTier.gold;
    if (lifetimePoints >= 1000) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }

  int _calculatePointsToNextTier(int lifetimePoints, LoyaltyTier currentTier) {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return 1000 - lifetimePoints;
      case LoyaltyTier.silver:
        return 2500 - lifetimePoints;
      case LoyaltyTier.gold:
        return 5000 - lifetimePoints;
      case LoyaltyTier.platinum:
        return 0;
    }
  }

  void _loadSampleRewards() {
    _availableRewards = [
      Reward(
        id: 'discount_10',
        title: '\$10 Off Next Purchase',
        description: 'Get \$10 off your next purchase of \$50 or more',
        pointsRequired: 500,
        imageUrl: 'assets/images/products/macbook.svg',
        type: RewardType.discount,
      ),
      Reward(
        id: 'free_shipping',
        title: 'Free Shipping',
        description: 'Free shipping on your next order',
        pointsRequired: 300,
        imageUrl: 'assets/images/products/iphone.svg',
        type: RewardType.freeShipping,
      ),
      Reward(
        id: 'birthday_bonus',
        title: 'Birthday Bonus',
        description: 'Double points on your birthday month',
        pointsRequired: 1000,
        imageUrl: 'assets/images/products/samsung.svg',
        type: RewardType.exclusive,
      ),
      Reward(
        id: 'exclusive_access',
        title: 'Exclusive Early Access',
        description: 'Get early access to new products and sales',
        pointsRequired: 750,
        imageUrl: 'assets/images/products/nike-shoes.svg',
        type: RewardType.exclusive,
      ),
      Reward(
        id: 'cashback_5',
        title: '5% Cashback',
        description: 'Earn 5% cashback on your next purchase',
        pointsRequired: 400,
        imageUrl: 'assets/images/products/adidas-tshirt.svg',
        type: RewardType.cashback,
      ),
    ];
  }

  // Persistence methods
  Future<void> _loadLoyaltyData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      // Load loyalty points
      final loyaltyJson = prefs.getString(_loyaltyPointsKey);
      if (loyaltyJson != null) {
        _loyaltyPoints = LoyaltyPoints.fromJson(json.decode(loyaltyJson));
      }

      // Load transactions
      final transactionsJson = prefs.getString(_transactionsKey);
      if (transactionsJson != null) {
        final transactionsList = json.decode(transactionsJson) as List;
        _transactions = transactionsList
            .map((item) => PointTransaction.fromJson(item))
            .toList();
      }

      // Load redemptions
      final redemptionsJson = prefs.getString(_redemptionsKey);
      if (redemptionsJson != null) {
        final redemptionsList = json.decode(redemptionsJson) as List;
        _redemptions = redemptionsList
            .map((item) => RewardRedemption.fromJson(item))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load loyalty data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveLoyaltyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save loyalty points
      await prefs.setString(_loyaltyPointsKey, json.encode(_loyaltyPoints.toJson()));

      // Save transactions
      await prefs.setString(_transactionsKey, json.encode(
        _transactions.map((t) => t.toJson()).toList(),
      ));

      // Save redemptions
      await prefs.setString(_redemptionsKey, json.encode(
        _redemptions.map((r) => r.toJson()).toList(),
      ));
    } catch (e) {
      debugPrint('Error saving loyalty data: $e');
    }
  }

  // Statistics methods
  Map<String, dynamic> getLoyaltyStats() {
    final totalEarned = _transactions
        .where((t) => t.isPositive)
        .fold(0, (sum, t) => sum + t.points);

    final totalSpent = _transactions
        .where((t) => !t.isPositive)
        .fold(0, (sum, t) => sum + t.points.abs());

    final transactionCount = _transactions.length;
    final redemptionCount = _redemptions.length;

    // Points by type
    final pointsByType = <String, int>{};
    for (final transaction in _transactions) {
      final typeKey = transaction.type.toString().split('.').last;
      pointsByType[typeKey] = (pointsByType[typeKey] ?? 0) + transaction.points;
    }

    return {
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'currentPoints': _loyaltyPoints.currentPoints,
      'lifetimePoints': _loyaltyPoints.lifetimePoints,
      'transactionCount': transactionCount,
      'redemptionCount': redemptionCount,
      'currentTier': _loyaltyPoints.tierName,
      'pointsByType': pointsByType,
      'tierProgress': _loyaltyPoints.tierProgress,
    };
  }

  // Reset method (for testing/demo purposes)
  void resetLoyaltyData() {
    _loyaltyPoints = const LoyaltyPoints(
      currentPoints: 0,
      lifetimePoints: 0,
      currentTier: LoyaltyTier.bronze,
      pointsToNextTier: 1000,
      lastUpdated: null,
    );
    _transactions.clear();
    _redemptions.clear();
    _saveLoyaltyData();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
