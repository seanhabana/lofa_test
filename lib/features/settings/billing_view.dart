import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// View Model
final billingPeriodProvider = StateProvider<String>((ref) => 'Monthly');

class BillingView extends ConsumerWidget {
  const BillingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingPeriod = ref.watch(billingPeriodProvider);

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
      body: SingleChildScrollView(
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
                      foreground:  Paint()
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
            
            // Discount Banner
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
                          billingPeriod == 'Monthly'
                              ? 'Monthly: 10.0% Discount • Annual: 20.0% Discount'
                              : 'Annual: 20.0% Discount',
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
            if (billingPeriod == 'Monthly')
              _buildMonthlyPlans()
            else
              _buildAnnualPlans(),
            
            const SizedBox(height: 40),
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

  Widget _buildMonthlyPlans() {
    return Column(
      children: [
        _buildPlanCard(
          title: 'Core',
          subtitle: 'Essential learning resource for NDIS support',
          originalPrice: 'A\$17',
          price: 'A\$13',
          period: '/month',
          savings: 'Save A\$2 per month',
          features: [
            'Access to Core-level lessons',
            'Basic progress tracking',
            'Community support',
            'Email notifications',
            'Mobile-friendly access',
          ],
          color: Colors.grey.shade700,
          isPopular: false,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          title: 'Pro',
          subtitle: 'Advanced learning with priority support',
          originalPrice: 'A\$30',
          price: 'A\$27',
          period: '/month',
          savings: 'Save A\$3 per month',
          features: [
            'All Core features',
            'Access to Pro-level lessons',
            'Advanced progress analytics',
            'Priority support',
            'Downloadable resources',
            'Certificate generation',
            'Early access to new content',
            'Webinar recordings',
          ],
          color: const Color(0xFF581C87),
          isPopular: true,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          title: 'Elite',
          subtitle: 'Complete professional development suite',
          originalPrice: 'A\$60',
          price: 'A\$54',
          period: '/month',
          savings: 'Save A\$6 per month',
          features: [
            'All Pro features',
            'Elite-level exclusive content',
            'One-on-one mentoring sessions',
            'Custom learning paths',
            'Advanced certifications',
            'Priority course requests',
            'Live Q&A sessions',
            'Professional networking access',
            'Continuing education credits',
          ],
          color: Colors.amber.shade700,
          isPopular: false,
          isFeatured: true,
        ),
      ],
    );
  }

  Widget _buildAnnualPlans() {
    return Column(
      children: [
        _buildPlanCard(
          title: 'Core',
          subtitle: 'Essential learning resource for NDIS support',
          originalPrice: 'A\$150',
          price: 'A\$120',
          period: '/year',
          savings: 'Save A\$42 per year',
          subtext: 'A\$10/month equivalent',
          features: [
            'Access to Core-level lessons',
            'Basic progress tracking',
            'Community support',
            'Email notifications',
            'Mobile-friendly access',
          ],
          color: Colors.grey.shade700,
          isPopular: false,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          title: 'Pro',
          subtitle: 'Advanced learning with priority support',
          originalPrice: 'A\$300',
          price: 'A\$240',
          period: '/year',
          savings: 'Save A\$84 per year',
          subtext: 'A\$20/month equivalent',
          features: [
            'All Core features',
            'Access to Pro-level lessons',
            'Advanced progress analytics',
            'Priority support',
            'Downloadable resources',
            'Certificate generation',
            'Early access to new content',
            'Webinar recordings',
          ],
          color: const Color(0xFF581C87),
          isPopular: true,
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          title: 'Elite',
          subtitle: 'Complete professional development suite',
          originalPrice: 'A\$600',
          price: 'A\$480',
          period: '/year',
          savings: 'Save A\$168 per year',
          subtext: 'A\$40/month equivalent',
          features: [
            'All Pro features',
            'Elite-level exclusive content',
            'One-on-one mentoring sessions',
            'Custom learning paths',
            'Advanced certifications',
            'Priority course requests',
            'Live Q&A sessions',
            'Professional networking access',
            'Continuing education credits',
          ],
          color: Colors.amber.shade700,
          isPopular: false,
          isFeatured: true,
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String subtitle,
    required String originalPrice,
    required String price,
    required String period,
    required String savings,
    String? subtext,
    required List<String> features,
    required Color color,
    required bool isPopular,
    bool isFeatured = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? const Color(0xFF581C87) : Colors.grey.shade200,
          width: isPopular ? 2 : 1,
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
                          title == 'Core'
                              ? Icons.star_outline
                              : title == 'Pro'
                                  ? Icons.bolt
                                  : Icons.workspace_premium,
                          color: color,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    if (isPopular)
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
                    if (isFeatured)
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
                  subtitle,
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
                      originalPrice,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      price,
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
                        period,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
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
                        savings,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (subtext != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtext,
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
                ...features.map((feature) => Padding(
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
                      // TODO: Navigate to payment
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
                        const Icon(Icons.credit_card, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Subscribe for $price$period',
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
}