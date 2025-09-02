import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loyalty_provider.dart';
import '../models/loyalty.dart';
import '../widgets/micro_interactions.dart';
import '../services/notification_service.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Program'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Rewards'),
            Tab(text: 'History'),
          ],
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        actions: [
          Consumer<LoyaltyProvider>(
            builder: (context, loyaltyProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'stats':
                      _showLoyaltyStats(context, loyaltyProvider);
                      break;
                    case 'reset_demo':
                      _showResetConfirmation(context, loyaltyProvider);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'stats',
                    child: Row(
                      children: [
                        Icon(Icons.analytics, size: 20),
                        SizedBox(width: 12),
                        Text('View Statistics'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'reset_demo',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 12),
                        Text('Reset Demo Data'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<LoyaltyProvider>(
        builder: (context, loyaltyProvider, child) {
          if (loyaltyProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(loyaltyProvider),
              _buildRewardsTab(loyaltyProvider),
              _buildHistoryTab(loyaltyProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(LoyaltyProvider loyaltyProvider) {
    final loyaltyPoints = loyaltyProvider.loyaltyPoints;
    final recentTransactions = loyaltyProvider.getRecentTransactions(limit: 5);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loyalty Tier Card
          _buildTierCard(loyaltyPoints),

          const SizedBox(height: 24),

          // Points Summary
          _buildPointsSummary(loyaltyPoints),

          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(loyaltyProvider),

          const SizedBox(height: 24),

          // Recent Activity
          if (recentTransactions.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(2),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recentTransactions.map((transaction) => _buildTransactionItem(transaction)),
          ] else ...[
            _buildEmptyActivityState(),
          ],
        ],
      ),
    );
  }

  Widget _buildTierCard(LoyaltyPoints loyaltyPoints) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            loyaltyPoints.tierColor,
            loyaltyPoints.tierColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: loyaltyPoints.tierColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loyaltyPoints.tierName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    loyaltyPoints.tierIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${loyaltyPoints.currentPoints} pts',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress to next tier
          if (loyaltyPoints.currentTier != LoyaltyTier.platinum) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${loyaltyPoints.pointsToNextTier} points to ${loyaltyPoints.currentTier == LoyaltyTier.bronze ? 'Silver' : loyaltyPoints.currentTier == LoyaltyTier.silver ? 'Gold' : 'Platinum'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: loyaltyPoints.tierProgress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '💎 Max Tier Achieved!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPointsSummary(LoyaltyPoints loyaltyPoints) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildPointsCard(
            'Current Points',
            loyaltyPoints.currentPoints.toString(),
            Icons.star,
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPointsCard(
            'Lifetime Points',
            loyaltyPoints.lifetimePoints.toString(),
            Icons.history,
            theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(LoyaltyProvider loyaltyProvider) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                'Earn Points',
                Icons.add_circle,
                theme.colorScheme.primary,
                () => _showEarnPointsDialog(context, loyaltyProvider),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                'Redeem',
                Icons.redeem,
                theme.colorScheme.secondary,
                () => _tabController.animateTo(1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(PointTransaction transaction) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.isPositive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                transaction.typeIcon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(transaction.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isPositive ? '+' : ''}${transaction.points}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: transaction.isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.timeline,
              size: 40,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No activity yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start earning points by making purchases and reviews',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsTab(LoyaltyProvider loyaltyProvider) {
    final availableRewards = loyaltyProvider.availableRewards;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableRewards.length,
      itemBuilder: (context, index) {
        final reward = availableRewards[index];
        return _buildRewardCard(reward, loyaltyProvider);
      },
    );
  }

  Widget _buildRewardCard(Reward reward, LoyaltyProvider loyaltyProvider) {
    final theme = Theme.of(context);
    final canRedeem = loyaltyProvider.canRedeemReward(reward);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${reward.pointsRequired} points required',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (canRedeem)
                  ElevatedButton(
                    onPressed: () => _showRedeemConfirmation(context, reward, loyaltyProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: const Text('Redeem'),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${reward.pointsRequired - loyaltyProvider.loyaltyPoints.currentPoints} more pts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              reward.description,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(LoyaltyProvider loyaltyProvider) {
    final transactions = loyaltyProvider.transactions;
    final redemptions = loyaltyProvider.redemptions;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Transactions'),
              Tab(text: 'Redemptions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                transactions.isEmpty
                    ? _buildEmptyHistory('No transactions yet')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          return _buildTransactionItem(transactions[index]);
                        },
                      ),
                redemptions.isEmpty
                    ? _buildEmptyHistory('No redemptions yet')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: redemptions.length,
                        itemBuilder: (context, index) {
                          return _buildRedemptionItem(redemptions[index]);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionItem(RewardRedemption redemption) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('🎁', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reward Redeemed',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(redemption.redeemedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: redemption.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    redemption.statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: redemption.statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${redemption.pointsUsed}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(String message) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEarnPointsDialog(BuildContext context, LoyaltyProvider loyaltyProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Earn Points'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEarnOption(
                'Make a Purchase',
                'Earn 1 point per \$1 spent',
                Icons.shopping_cart,
                () {
                  Navigator.of(context).pop();
                  loyaltyProvider.earnPurchasePoints(150.0);
                  _notificationService.showSuccess(
                    context,
                    'Points Earned!',
                    'Earned points for a mock purchase',
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildEarnOption(
                'Write a Review',
                'Earn 50 points per review',
                Icons.star,
                () {
                  Navigator.of(context).pop();
                  loyaltyProvider.earnReviewPoints('Demo Product');
                  _notificationService.showSuccess(
                    context,
                    'Points Earned!',
                    'Earned 50 points for writing a review',
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildEarnOption(
                'Refer a Friend',
                'Earn 100 points per referral',
                Icons.person_add,
                () {
                  Navigator.of(context).pop();
                  loyaltyProvider.earnReferralPoints('John Doe');
                  _notificationService.showSuccess(
                    context,
                    'Points Earned!',
                    'Earned 100 points for referring a friend',
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEarnOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemConfirmation(BuildContext context, Reward reward, LoyaltyProvider loyaltyProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Redeem Reward'),
          content: Text(
            'Are you sure you want to redeem "${reward.title}" for ${reward.pointsRequired} points?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                loyaltyProvider.redeemReward(reward);
                Navigator.of(context).pop();
                _notificationService.showSuccess(
                  context,
                  'Reward Redeemed!',
                  'Your reward has been redeemed successfully',
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Redeem'),
            ),
          ],
        );
      },
    );
  }

  void _showLoyaltyStats(BuildContext context, LoyaltyProvider loyaltyProvider) {
    final stats = loyaltyProvider.getLoyaltyStats();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Loyalty Statistics'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Current Tier: ${stats['currentTier']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Current Points: ${stats['currentPoints']}'),
                Text('Lifetime Points: ${stats['lifetimePoints']}'),
                Text('Total Transactions: ${stats['transactionCount']}'),
                Text('Total Redemptions: ${stats['redemptionCount']}'),
                const SizedBox(height: 16),
                const Text('Points by Activity:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(stats['pointsByType'] as Map<String, int>).entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• ${entry.key}: ${entry.value} points'),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmation(BuildContext context, LoyaltyProvider loyaltyProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Loyalty Data'),
          content: const Text(
            'This will reset all your points, transactions, and redemptions. This action cannot be undone.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                loyaltyProvider.resetLoyaltyData();
                Navigator.of(context).pop();
                _notificationService.showSuccess(
                  context,
                  'Data Reset',
                  'Loyalty data has been reset',
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
