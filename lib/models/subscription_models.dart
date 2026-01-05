// Models for Subscription Plans

class SubscriptionPlansResponse {
  final List<SubscriptionPlan> plans;
  final AvailableIntervals availableIntervals;
  final GlobalDiscount? globalDiscount;

  SubscriptionPlansResponse({
    required this.plans,
    required this.availableIntervals,
    this.globalDiscount,
  });

  factory SubscriptionPlansResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlansResponse(
      plans: (json['plans'] as List)
          .map((plan) => SubscriptionPlan.fromJson(plan))
          .toList(),
      availableIntervals: AvailableIntervals.fromJson(json['available_intervals']),
      globalDiscount: json['global_discount'] != null
          ? GlobalDiscount.fromJson(json['global_discount'])
          : null,
    );
  }
}

class SubscriptionPlan {
  final int id;
  final String name;
  final String displayName;
  final String description;
  final String shortDescription;
  final double price;
  final String originalPrice;
  final double monthlyPrice;
  final double annualPrice;
  final String billingInterval;
  final double annualSavings;
  final double monthlyEquivalent;
  final List<String> features;
  final int tierLevel;
  final int? maxCourses;
  final int? maxLessonsPerCourse;
  final bool isFeatured;
  final bool isPopular;
  final String colorScheme;
  final String currency;
  final bool hasDiscount;
  final double discountPercentage;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.shortDescription,
    required this.price,
    required this.originalPrice,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.billingInterval,
    required this.annualSavings,
    required this.monthlyEquivalent,
    required this.features,
    required this.tierLevel,
    this.maxCourses,
    this.maxLessonsPerCourse,
    required this.isFeatured,
    required this.isPopular,
    required this.colorScheme,
    required this.currency,
    required this.hasDiscount,
    required this.discountPercentage,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      description: json['description'],
      shortDescription: json['short_description'],
      price: (json['price'] as num).toDouble(),
      originalPrice: json['original_price'].toString(),
      monthlyPrice: (json['monthly_price'] as num).toDouble(),
      annualPrice: (json['annual_price'] as num).toDouble(),
      billingInterval: json['billing_interval'],
      annualSavings: (json['annual_savings'] as num).toDouble(),
      monthlyEquivalent: (json['monthly_equivalent'] as num).toDouble(),
      features: List<String>.from(json['features']),
      tierLevel: json['tier_level'],
      maxCourses: json['max_courses'],
      maxLessonsPerCourse: json['max_lessons_per_course'],
      isFeatured: json['is_featured'],
      isPopular: json['is_popular'],
      colorScheme: json['color_scheme'],
      currency: json['currency'],
      hasDiscount: json['has_discount'],
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
    );
  }
}

class AvailableIntervals {
  final List<String> available;
  final bool supportsBoth;
  final String current;

  AvailableIntervals({
    required this.available,
    required this.supportsBoth,
    required this.current,
  });

  factory AvailableIntervals.fromJson(Map<String, dynamic> json) {
    return AvailableIntervals(
      available: List<String>.from(json['available']),
      supportsBoth: json['supports_both'],
      current: json['current'],
    );
  }
}

class GlobalDiscount {
  final double percentage;
  final String description;

  GlobalDiscount({
    required this.percentage,
    required this.description,
  });

  factory GlobalDiscount.fromJson(Map<String, dynamic> json) {
    return GlobalDiscount(
      percentage: (json['percentage'] as num).toDouble(),
      description: json['description'],
    );
  }
}

// State for the provider
class SubscriptionPlansState {
  final List<SubscriptionPlan> plans;
  final AvailableIntervals? availableIntervals;
  final GlobalDiscount? globalDiscount;
  final bool isLoading;
  final String? errorMessage;

  SubscriptionPlansState({
    this.plans = const [],
    this.availableIntervals,
    this.globalDiscount,
    this.isLoading = false,
    this.errorMessage,
  });

  SubscriptionPlansState copyWith({
    List<SubscriptionPlan>? plans,
    AvailableIntervals? availableIntervals,
    GlobalDiscount? globalDiscount,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubscriptionPlansState(
      plans: plans ?? this.plans,
      availableIntervals: availableIntervals ?? this.availableIntervals,
      globalDiscount: globalDiscount ?? this.globalDiscount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}