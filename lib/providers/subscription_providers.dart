import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_models.dart';
import '../services/subscription_service.dart';

// Provider for billing period (Monthly/Annual)
final billingPeriodProvider = StateProvider<String>((ref) => 'Monthly');

// Provider for subscription plans
final subscriptionPlansProvider =
    StateNotifierProvider<SubscriptionPlansNotifier, SubscriptionPlansState>(
  (ref) => SubscriptionPlansNotifier(),
);

class SubscriptionPlansNotifier extends StateNotifier<SubscriptionPlansState> {
  SubscriptionPlansNotifier() : super(SubscriptionPlansState());

  Future<void> fetchPlans() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await SubscriptionService.getPlans();
      
      state = state.copyWith(
        plans: response.plans,
        availableIntervals: response.availableIntervals,
        globalDiscount: response.globalDiscount,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Optional: Fetch with authentication
  Future<void> fetchPlansWithAuth(String token) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await SubscriptionService.getPlansWithAuth(token);
      
      state = state.copyWith(
        plans: response.plans,
        availableIntervals: response.availableIntervals,
        globalDiscount: response.globalDiscount,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Get plans filtered by billing interval
  List<SubscriptionPlan> getPlansForInterval(String interval) {
    return state.plans
        .where((plan) => plan.billingInterval.toLowerCase() == interval.toLowerCase())
        .toList();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = SubscriptionPlansState();
  }
}