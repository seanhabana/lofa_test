import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/subscription_models.dart';
import '../../providers/subscription_providers.dart';

class BillingView extends ConsumerStatefulWidget {
  const BillingView({super.key});

  @override
  ConsumerState<BillingView> createState() => _BillingViewState();
}

class _BillingViewState extends ConsumerState<BillingView> {
  @override
  void initState() {
    super.initState();
    // Fetch plans when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionPlansProvider.notifier).fetchPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final billingPeriod = ref.watch(billingPeriodProvider);
    final plansState = ref.watch(subscriptionPlansProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subscription Management',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: plansState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : plansState.errorMessage != null
              ? _buildErrorView(plansState.errorMessage!)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Manage your subscription and access to premium content',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Choose Your Plan Header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Choose Your Plan',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [Color(0xFF581C87), Colors.blue],
                                  ).createShader(const Rect.fromLTWH(0, 0, 300, 50)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Unlock more content with our flexible subscription plans\ndesigned to accelerate your learning journey',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Billing Period Toggle
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildPeriodButton(
                                    ref,
                                    'Monthly',
                                    billingPeriod == 'Monthly',
                                  ),
                                  _buildPeriodButton(
                                    ref,
                                    'Annual',
                                    billingPeriod == 'Annual',
                                    badge: 'Save More',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Global Discount Banner
                      if (plansState.globalDiscount != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.celebration, color: Colors.green.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Limited Time Discount Active!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      plansState.globalDiscount!.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Subscription Plans
                      _buildPlansList(plansState.plans, billingPeriod),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Plans',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(subscriptionPlansProvider.notifier).fetchPlans();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF581C87),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(WidgetRef ref, String period, bool isSelected, {String? badge}) {
    return GestureDetector(
      onTap: () {
        ref.read(billingPeriodProvider.notifier).state = period;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF581C87) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              period,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
            if (badge != null && isSelected)
              Positioned(
                top: -20,
                right: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList(List<SubscriptionPlan> plans, String billingPeriod) {
    // Sort by tier level - show all plans regardless of billing_interval
    final sortedPlans = [...plans];
    sortedPlans.sort((a, b) => a.tierLevel.compareTo(b.tierLevel));

    return Column(
      children: sortedPlans
          .map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPlanCard(plan, billingPeriod),
              ))
          .toList(),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, String billingPeriod) {
    final color = _getColorFromScheme(plan.colorScheme);
    final isAnnual = billingPeriod == 'Annual';
    
    // Use monthly or annual price based on selected period
    final displayPrice = isAnnual ? plan.annualPrice : plan.monthlyPrice;
    
    // For annual, calculate savings: (monthly * 12) - annual
    final annualSavings = isAnnual 
        ? (plan.monthlyPrice * 12) - plan.annualPrice 
        : 0.0;
    
    // Monthly equivalent for annual plans
    final monthlyEquivalent = isAnnual ? plan.annualPrice / 12 : 0.0;

    // Format currency
    final currencySymbol = _getCurrencySymbol(plan.currency);
    
    // Calculate savings text
    String savingsText = '';
    if (isAnnual && annualSavings > 0) {
      savingsText = 'Save $currencySymbol${annualSavings.toStringAsFixed(2)} per year';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isPopular ? const Color(0xFF581C87) : Colors.grey.shade200,
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getIconForPlan(plan.name),
                          color: color,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          plan.displayName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    if (plan.isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF581C87),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.star, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Most Popular',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (plan.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Featured',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.shortDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currencySymbol${displayPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        isAnnual ? '/year' : '/month',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                if (savingsText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_down, size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          savingsText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isAnnual && monthlyEquivalent > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$currencySymbol${monthlyEquivalent.toStringAsFixed(2)}/month equivalent',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Features
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...plan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _handleSubscription(plan, billingPeriod);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.credit_card, size: 20, color: Colors.white,),
                        const SizedBox(width: 8),
                        Text(
                          'Subscribe for $currencySymbol${displayPrice.toStringAsFixed(0)}${isAnnual ? '/year' : '/month'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromScheme(String colorScheme) {
    switch (colorScheme.toLowerCase()) {
      case 'blue':
        return Colors.blue.shade700;
      case 'purple':
        return const Color(0xFF581C87);
      case 'orange':
        return Colors.orange.shade700;
      case 'green':
        return Colors.green.shade700;
      case 'red':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getIconForPlan(String planName) {
    switch (planName.toLowerCase()) {
      case 'core':
        return Icons.star_outline;
      case 'pro':
        return Icons.bolt;
      case 'elite':
        return Icons.workspace_premium;
      default:
        return Icons.card_membership;
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'AUD':
        return 'A\$';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }

  void _handleSubscription(SubscriptionPlan plan, String billingPeriod) {
    final isAnnual = billingPeriod == 'Annual';
    final price = isAnnual ? plan.annualPrice : plan.monthlyPrice;
    
    // TODO: Implement navigation to payment page with plan details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscribe to ${plan.displayName}'),
        content: Text(
          'You selected the ${plan.displayName} plan.\n\n'
          'Plan ID: ${plan.id}\n'
          'Billing: ${isAnnual ? 'Annual' : 'Monthly'}\n'
          'Price: ${_getCurrencySymbol(plan.currency)}${price.toStringAsFixed(2)}'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to payment page with:
              // - plan.id
              // - billingPeriod (Monthly/Annual)
              // - price
            },
            child: const Text('Continue to Payment'),
          ),
        ],
      ),
    );
  }
}