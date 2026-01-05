// Models for Forgot Password Flow
class ForgotPasswordState {
  final String email;
  final List<String> codeDigits;
  final String? errorMessage;
  final String? successMessage;
  final bool isLoading;
  final bool isCodeSent;
  final bool isCodeVerified;
  final String? resetToken;
  final int resendCountdown;
  final bool isResendEnabled;
  final ForgotPasswordStep currentStep;

  ForgotPasswordState({
    this.email = '',
    this.codeDigits = const ['', '', '', '', '', ''],
    this.errorMessage,
    this.successMessage,
    this.isLoading = false,
    this.isCodeSent = false,
    this.isCodeVerified = false,
    this.resetToken,
    this.resendCountdown = 60,
    this.isResendEnabled = false,
    this.currentStep = ForgotPasswordStep.enterEmail,
  });

  String get fullCode => codeDigits.join();

  ForgotPasswordState copyWith({
    String? email,
    List<String>? codeDigits,
    String? errorMessage,
    String? successMessage,
    bool? isLoading,
    bool? isCodeSent,
    bool? isCodeVerified,
    String? resetToken,
    int? resendCountdown,
    bool? isResendEnabled,
    ForgotPasswordStep? currentStep,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearResetToken = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      codeDigits: codeDigits ?? this.codeDigits,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isLoading: isLoading ?? this.isLoading,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      isCodeVerified: isCodeVerified ?? this.isCodeVerified,
      resetToken: clearResetToken ? null : (resetToken ?? this.resetToken),
      resendCountdown: resendCountdown ?? this.resendCountdown,
      isResendEnabled: isResendEnabled ?? this.isResendEnabled,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

enum ForgotPasswordStep {
  enterEmail,
  verifyCode,
  resetPassword,
}

// API Response Models
class SendPinResponse {
  final bool success;
  final String message;

  SendPinResponse({required this.success, required this.message});

  factory SendPinResponse.fromJson(Map<String, dynamic> json) {
    return SendPinResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Code sent successfully',
    );
  }
}

class VerifyPinResponse {
  final bool success;
  final String message;
  final String? resetToken;

  VerifyPinResponse({
    required this.success,
    required this.message,
    this.resetToken,
  });

  factory VerifyPinResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPinResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Code verified successfully',
      resetToken: json['reset_token'] ?? json['resetToken'],
    );
  }
}

class ResetPasswordResponse {
  final bool success;
  final String message;

  ResetPasswordResponse({required this.success, required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Password reset successfully',
    );
  }
}