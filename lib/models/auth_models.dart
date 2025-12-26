class LoginResponse {
  final String token;
  final String message;
  final User user;

  LoginResponse({
    required this.token,
    required this.message,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      message: json['message'] as String,
      user: User.fromJson(json),
    );
  }
}

class RegisterResponse {
  final int? id;
  final String? email;
  final String? role;
  final String? roleDisplayName;
  final String message;

  RegisterResponse({
    this.id,
    this.email,
    this.role,
    this.roleDisplayName,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    // Handle multiple possible payload shapes, e.g. {"data": {...}, "message": "..."}
    final Map<String, dynamic> root = Map<String, dynamic>.from(json);
    final String message = (root['message'] != null && root['message'].toString().isNotEmpty)
      ? root['message'].toString()
      : 'Registration successful';

    Map<String, dynamic> payload = {};
    if (root.containsKey('data') && root['data'] is Map<String, dynamic>) {
      payload = Map<String, dynamic>.from(root['data']);
    } else {
      payload = root;
    }

    // If payload has nested 'user' object, prefer that
    if (payload.containsKey('user') && payload['user'] is Map<String, dynamic>) {
      payload = Map<String, dynamic>.from(payload['user']);
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    return RegisterResponse(
      id: parseInt(payload['id'] ?? payload['user_id'] ?? payload['role_id']),
      email: payload['email'] as String?,
      role: payload['role'] as String?,
      roleDisplayName: payload['role_display_name'] as String?,
      message: message,
    );
  }
}

class User {
  final int? id;
  final String? email;
  final String? name;
  final String? role;
  final String? roleDisplayName;
  final int? roleId;
  final String? subscriptionPlan;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;
  final String? stripeSubscriptionStatus;
  final DateTime? subscriptionEndsAt;
  final int? subscriptionTierLevel;
  final DateTime? lastActiveAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    this.email,
    this.name,
    this.role,
    this.roleDisplayName,
    this.roleId,
    this.subscriptionPlan,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
    this.stripeSubscriptionStatus,
    this.subscriptionEndsAt,
    this.subscriptionTierLevel,
    this.lastActiveAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
      roleDisplayName: json['role_display_name'] as String?,
      roleId: json['role_id'] as int?,
      subscriptionPlan: json['subscription_plan'] as String?,
      stripeCustomerId: json['stripe_customer_id'] as String?,
      stripeSubscriptionId: json['stripe_subscription_id'] as String?,
      stripeSubscriptionStatus: json['stripe_subscription_status'] as String?,
      subscriptionEndsAt: json['subscription_ends_at'] != null
          ? DateTime.parse(json['subscription_ends_at'])
          : null,
      subscriptionTierLevel: json['subscription_tier_level'] as int?,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'role_display_name': roleDisplayName,
      'role_id': roleId,
      'subscription_plan': subscriptionPlan,
      'stripe_customer_id': stripeCustomerId,
      'stripe_subscription_id': stripeSubscriptionId,
      'stripe_subscription_status': stripeSubscriptionStatus,
      'subscription_ends_at': subscriptionEndsAt?.toIso8601String(),
      'subscription_tier_level': subscriptionTierLevel,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}