import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/forgot_password_service.dart';
import '../models/forgot_password_models.dart';
// State Provider
final forgotPasswordProvider =
    StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
  return ForgotPasswordNotifier();
});

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  Timer? _resendTimer;

  ForgotPasswordNotifier() : super(ForgotPasswordState());

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, clearError: true);
  }

  void updateCodeDigit(int index, String value) {
    final newDigits = List<String>.from(state.codeDigits);
    newDigits[index] = value;
    state = state.copyWith(codeDigits: newDigits, clearError: true);
  }

  Future<void> sendCode() async {
    if (state.email.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email');
      return;
    }

    if (!_isValidEmail(state.email)) {
      state = state.copyWith(errorMessage: 'Please enter a valid email');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await ForgotPasswordService.sendPin(state.email);
      
      state = state.copyWith(
        isLoading: false,
        isCodeSent: true,
        currentStep: ForgotPasswordStep.verifyCode,
        successMessage: response.message,
        clearError: true,
      );

      _startResendTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearSuccess: true,
      );
    }
  }

  Future<void> resendCode() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await ForgotPasswordService.sendPin(state.email);
      
      state = state.copyWith(
        isLoading: false,
        successMessage: response.message,
        codeDigits: ['', '', '', '', '', ''],
        clearError: true,
      );

      _startResendTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearSuccess: true,
      );
    }
  }

  Future<bool> verifyCode() async {
    final code = state.fullCode;

    if (code.length != 6) {
      state = state.copyWith(errorMessage: 'Please enter complete 6-digit code');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await ForgotPasswordService.verifyPin(state.email, code);
      
      state = state.copyWith(
        isLoading: false,
        isCodeVerified: true,
        resetToken: response.resetToken,
        currentStep: ForgotPasswordStep.resetPassword,
        successMessage: response.message,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearSuccess: true,
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    if (password.isEmpty || passwordConfirmation.isEmpty) {
      state = state.copyWith(errorMessage: 'Please fill in all fields');
      return false;
    }

    if (password != passwordConfirmation) {
      state = state.copyWith(errorMessage: 'Passwords do not match');
      return false;
    }

    if (password.length < 8) {
      state = state.copyWith(
        errorMessage: 'Password must be at least 8 characters',
      );
      return false;
    }

    if (state.resetToken == null) {
      state = state.copyWith(
        errorMessage: 'Invalid reset token. Please verify code again.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await ForgotPasswordService.resetPassword(
        email: state.email,
        resetToken: state.resetToken!,
        pin: state.fullCode,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      
      state = state.copyWith(
        isLoading: false,
        successMessage: response.message,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearSuccess: true,
      );
      return false;
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    state = state.copyWith(resendCountdown: 60, isResendEnabled: false);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdown > 0) {
        state = state.copyWith(resendCountdown: state.resendCountdown - 1);
      } else {
        state = state.copyWith(isResendEnabled: true);
        timer.cancel();
      }
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void reset() {
    _resendTimer?.cancel();
    state = ForgotPasswordState();
  }

  void goToStep(ForgotPasswordStep step) {
    state = state.copyWith(currentStep: step, clearError: true);
  }
}