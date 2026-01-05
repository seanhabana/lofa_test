// Account Models

class AccountSettings {
  final String email;
  final String name;
  final UserRole role;
  final String roleDisplayName;
  final bool twoFactorEnabled;
  final String? twoFactorMethod;
  final bool isDeactivated;
  final String? phone;

  AccountSettings({
    required this.email,
    required this.name,
    required this.role,
    required this.roleDisplayName,
    required this.twoFactorEnabled,
    this.twoFactorMethod,
    required this.isDeactivated,
    this.phone,
  });

  factory AccountSettings.fromJson(Map<String, dynamic> json) {
    return AccountSettings(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: UserRole.fromJson(json['role'] ?? {}),
    roleDisplayName: json['role']['display_name'] ?? 'N/A',  // CHANGED to get from role object
      twoFactorEnabled: json['two_factor_enabled'] == 1,
      twoFactorMethod: json['two_factor_method'],
      isDeactivated: json['is_deactivated'] == 1,
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'role': role.toJson(),
      'role_display_name': roleDisplayName,
      'two_factor_enabled': twoFactorEnabled ? 1 : 0,
      'two_factor_method': twoFactorMethod,
      'is_deactivated': isDeactivated ? 1 : 0,
      'phone': phone,
    };
  }
}

class UserRole {
  final int id;
  final String name;
  final String displayName;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  UserRole({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UpdateProfileRequest {
  final String name;
  final String? phone;

  UpdateProfileRequest({
    required this.name,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (phone != null) 'phone': phone,
    };
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    };
  }
}

class RequestEmailChangeRequest {
  final String newEmail;

  RequestEmailChangeRequest({required this.newEmail});

  Map<String, dynamic> toJson() {
    return {
      'new_email': newEmail,
    };
  }
}

class VerifyEmailChangeRequest {
  final String token;

  VerifyEmailChangeRequest({required this.token});

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}

class EnableTwoFactorRequest {
  final String method; // 'email' or 'sms'

  EnableTwoFactorRequest({required this.method});

  Map<String, dynamic> toJson() {
    return {
      'method': method,
    };
  }
}

class ConfirmTwoFactorRequest {
  final String code;

  ConfirmTwoFactorRequest({required this.code});

  Map<String, dynamic> toJson() {
    return {
      'code': code,
    };
  }
}

class ApiResponse<T> {
  final bool success;
  final T data;
  final String? message;

  ApiResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: fromJsonT(json['data']),
      message: json['message'],
    );
  }
}