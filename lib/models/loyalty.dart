import 'package:flutter/material.dart';

enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum,
}

enum PointTransactionType {
  purchase,
  review,
  referral,
  birthday,
  milestone,
  redemption,
  expiry,
}

class LoyaltyPoints {
  final int currentPoints;
  final int lifetimePoints;
  final LoyaltyTier currentTier;
  final int pointsToNextTier;
  final DateTime lastUpdated;

  const LoyaltyPoints({
    required this.currentPoints,
    required this.lifetimePoints,
    required this.currentTier,
    required this.pointsToNextTier,
    required this.lastUpdated,
  });

  LoyaltyPoints copyWith({
    int? currentPoints,
    int? lifetimePoints,
    LoyaltyTier? currentTier,
    int? pointsToNextTier,
    DateTime? lastUpdated,
  }) {
    return LoyaltyPoints(
      currentPoints: currentPoints ?? this.currentPoints,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      currentTier: currentTier ?? this.currentTier,
      pointsToNextTier: pointsToNextTier ?? this.pointsToNextTier,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPoints': currentPoints,
      'lifetimePoints': lifetimePoints,
      'currentTier': currentTier.toString(),
      'pointsToNextTier': pointsToNextTier,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      currentPoints: json['currentPoints'] ?? 0,
      lifetimePoints: json['lifetimePoints'] ?? 0,
      currentTier: LoyaltyTier.values.firstWhere(
        (tier) => tier.toString() == json['currentTier'],
        orElse: () => LoyaltyTier.bronze,
      ),
      pointsToNextTier: json['pointsToNextTier'] ?? 1000,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Helper methods
  double get tierProgress => currentTier == LoyaltyTier.platinum
      ? 1.0
      : (lifetimePoints % 1000) / 1000.0;

  String get tierName {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
    }
  }

  Color get tierColor {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return const Color(0xFFCD7F32);
      case LoyaltyTier.silver:
        return const Color(0xFFC0C0C0);
      case LoyaltyTier.gold:
        return const Color(0xFFFFD700);
      case LoyaltyTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  String get tierIcon {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return '🥉';
      case LoyaltyTier.silver:
        return '🥈';
      case LoyaltyTier.gold:
        return '🥇';
      case LoyaltyTier.platinum:
        return '💎';
    }
  }

  int get pointsForNextTier {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return 1000 - (lifetimePoints % 1000);
      case LoyaltyTier.silver:
        return 2500 - (lifetimePoints % 2500);
      case LoyaltyTier.gold:
        return 5000 - (lifetimePoints % 5000);
      case LoyaltyTier.platinum:
        return 0; // Max tier
    }
  }

  static int getTierThreshold(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 0;
      case LoyaltyTier.silver:
        return 1000;
      case LoyaltyTier.gold:
        return 2500;
      case LoyaltyTier.platinum:
        return 5000;
    }
  }
}

class PointTransaction {
  final String id;
  final int points;
  final PointTransactionType type;
  final String description;
  final DateTime timestamp;
  final String? orderId;
  final String? productId;

  const PointTransaction({
    required this.id,
    required this.points,
    required this.type,
    required this.description,
    required this.timestamp,
    this.orderId,
    this.productId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points,
      'type': type.toString(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'orderId': orderId,
      'productId': productId,
    };
  }

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'],
      points: json['points'],
      type: PointTransactionType.values.firstWhere(
        (type) => type.toString() == json['type'],
        orElse: () => PointTransactionType.purchase,
      ),
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      orderId: json['orderId'],
      productId: json['productId'],
    );
  }

  String get typeIcon {
    switch (type) {
      case PointTransactionType.purchase:
        return '🛒';
      case PointTransactionType.review:
        return '⭐';
      case PointTransactionType.referral:
        return '👥';
      case PointTransactionType.birthday:
        return '🎂';
      case PointTransactionType.milestone:
        return '🎯';
      case PointTransactionType.redemption:
        return '🎁';
      case PointTransactionType.expiry:
        return '⏰';
    }
  }

  bool get isPositive => points > 0;
}

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String imageUrl;
  final RewardType type;
  final bool isAvailable;
  final int? maxRedemptions;
  final int currentRedemptions;
  final DateTime? expiryDate;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.imageUrl,
    required this.type,
    this.isAvailable = true,
    this.maxRedemptions,
    this.currentRedemptions = 0,
    this.expiryDate,
  });

  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get canRedeem => isAvailable && !isExpired && (maxRedemptions == null || currentRedemptions < maxRedemptions!);
  int get remainingRedemptions => maxRedemptions != null ? maxRedemptions! - currentRedemptions : -1;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsRequired': pointsRequired,
      'imageUrl': imageUrl,
      'type': type.toString(),
      'isAvailable': isAvailable,
      'maxRedemptions': maxRedemptions,
      'currentRedemptions': currentRedemptions,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pointsRequired: json['pointsRequired'],
      imageUrl: json['imageUrl'],
      type: RewardType.values.firstWhere(
        (type) => type.toString() == json['type'],
        orElse: () => RewardType.discount,
      ),
      isAvailable: json['isAvailable'] ?? true,
      maxRedemptions: json['maxRedemptions'],
      currentRedemptions: json['currentRedemptions'] ?? 0,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    );
  }
}

enum RewardType {
  discount,
  freeShipping,
  freeProduct,
  cashback,
  exclusive,
}

class RewardRedemption {
  final String id;
  final String rewardId;
  final int pointsUsed;
  final DateTime redeemedAt;
  final RedemptionStatus status;
  final String? trackingCode;
  final DateTime? fulfilledAt;

  const RewardRedemption({
    required this.id,
    required this.rewardId,
    required this.pointsUsed,
    required this.redeemedAt,
    this.status = RedemptionStatus.pending,
    this.trackingCode,
    this.fulfilledAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rewardId': rewardId,
      'pointsUsed': pointsUsed,
      'redeemedAt': redeemedAt.toIso8601String(),
      'status': status.toString(),
      'trackingCode': trackingCode,
      'fulfilledAt': fulfilledAt?.toIso8601String(),
    };
  }

  factory RewardRedemption.fromJson(Map<String, dynamic> json) {
    return RewardRedemption(
      id: json['id'],
      rewardId: json['rewardId'],
      pointsUsed: json['pointsUsed'],
      redeemedAt: DateTime.parse(json['redeemedAt']),
      status: RedemptionStatus.values.firstWhere(
        (status) => status.toString() == json['status'],
        orElse: () => RedemptionStatus.pending,
      ),
      trackingCode: json['trackingCode'],
      fulfilledAt: json['fulfilledAt'] != null ? DateTime.parse(json['fulfilledAt']) : null,
    );
  }

  String get statusText {
    switch (status) {
      case RedemptionStatus.pending:
        return 'Processing';
      case RedemptionStatus.approved:
        return 'Approved';
      case RedemptionStatus.fulfilled:
        return 'Fulfilled';
      case RedemptionStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case RedemptionStatus.pending:
        return const Color(0xFFFF9800);
      case RedemptionStatus.approved:
        return const Color(0xFF2196F3);
      case RedemptionStatus.fulfilled:
        return const Color(0xFF4CAF50);
      case RedemptionStatus.cancelled:
        return const Color(0xFFF44336);
    }
  }
}

enum RedemptionStatus {
  pending,
  approved,
  fulfilled,
  cancelled,
}

// Point earning configuration
class PointEarningRules {
  static const int pointsPerDollar = 1; // 1 point per $1 spent
  static const int pointsPerReview = 50; // 50 points per product review
  static const int pointsPerReferral = 100; // 100 points per successful referral
  static const int pointsBirthdayBonus = 200; // 200 points on birthday
  static const int pointsMilestoneBonus = 500; // 500 points for milestones

  static int calculatePurchasePoints(double amount) {
    return (amount * pointsPerDollar).round();
  }

  static int calculateTierMultiplier(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 1;
      case LoyaltyTier.silver:
        return 2;
      case LoyaltyTier.gold:
        return 3;
      case LoyaltyTier.platinum:
        return 5;
    }
  }
}
