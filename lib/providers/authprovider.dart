import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// Sign up
class SignUpFormState {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final String? errorMessage;

  SignUpFormState({
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.errorMessage,
  });

  SignUpFormState copyWith({
    String? fullName,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SignUpFormState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// State notifier class
class SignUpFormNotifier extends StateNotifier<SignUpFormState> {
  SignUpFormNotifier() : super(SignUpFormState());

  void updateFullName(String value) {
    state = state.copyWith(fullName: value, errorMessage: null);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, errorMessage: null);
  }

  Future<bool> signUp() async {
    // Validation
    if (state.fullName.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your full name');
      return false;
    }

    if (state.email.isEmpty || !state.email.contains('@')) {
      state = state.copyWith(errorMessage: 'Please enter a valid email');
      return false;
    }

    if (state.password.isEmpty || state.password.length < 6) {
      state = state.copyWith(errorMessage: 'Password must be at least 6 characters');
      return false;
    }

    if (state.password != state.confirmPassword) {
      state = state.copyWith(errorMessage: 'Passwords do not match');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await Future.delayed(const Duration(seconds: 2)); 
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sign up failed: ${e.toString()}',
      );
      return false;
    }
  }
}



// Provider for the sign-up form
final signUpFormProvider = StateNotifierProvider<SignUpFormNotifier, SignUpFormState>((ref) {
  return SignUpFormNotifier();
});

// Provider for password visibility
final obscurePasswordProvider = StateProvider<bool>((ref) => true);
final obscureConfirmPasswordProvider = StateProvider<bool>((ref) => true);

// Login

class LoginFormState {
  final String email;
  final String password;
  final bool rememberMe;
  final bool isLoading;
  final String? errorMessage;

  LoginFormState({
    this.email = '',
    this.password = '',
    this.rememberMe = false,
    this.isLoading = false,
    this.errorMessage,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Login Form Notifier
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(LoginFormState());

  void updateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  Future<bool> login() async {
    // Validation
    if (state.email.isEmpty || !state.email.contains('@')) {
      state = state.copyWith(errorMessage: 'Please enter a valid email');
      return false;
    }

    if (state.password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your password');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: Implement actual login logic here
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed: ${e.toString()}',
      );
      return false;
    }
  }
}

// Provider for the login form
final loginFormProvider = StateNotifierProvider<LoginFormNotifier, LoginFormState>((ref) {
  return LoginFormNotifier();
});

// Provider for login password visibility
final obscureLoginPasswordProvider = StateProvider<bool>((ref) => true);

class ForgotPasswordState {
  final String email;
  final List<String> codeDigits;
  final bool isCodeSent;
  final bool isResendEnabled;
  final int resendCountdown;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  ForgotPasswordState({
    this.email = '',
    this.codeDigits = const ['', '', '', '', '', ''],
    this.isCodeSent = false,
    this.isResendEnabled = true,
    this.resendCountdown = 0,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ForgotPasswordState copyWith({
    String? email,
    List<String>? codeDigits,
    bool? isCodeSent,
    bool? isResendEnabled,
    int? resendCountdown,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      codeDigits: codeDigits ?? this.codeDigits,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      isResendEnabled: isResendEnabled ?? this.isResendEnabled,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  String get fullCode => codeDigits.join();
}

// Forgot Password Notifier
class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordNotifier() : super(ForgotPasswordState());
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void updateEmail(String value) {
    state = state.copyWith(
      email: value,
      errorMessage: null,
      successMessage: null,
    );
  }

  void updateCodeDigit(int index, String value) {
    if (index < 0 || index >= 6) return;
    
    final newDigits = List<String>.from(state.codeDigits);
    newDigits[index] = value;
    state = state.copyWith(
      codeDigits: newDigits,
      errorMessage: null,
      successMessage: null,
    );
  }

  void clearCode() {
    state = state.copyWith(
      codeDigits: ['', '', '', '', '', ''],
      errorMessage: null,
      successMessage: null,
    );
  }

  Future<bool> sendCode() async {
    if (state.email.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email');
      return false;
    }

    if (!state.email.contains('@')) {
      state = state.copyWith(errorMessage: 'Please enter a valid email');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: Implement actual API call to send code
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      state = state.copyWith(
        isLoading: false,
        isCodeSent: true,
        successMessage: 'Verification code sent to your email',
      );
      
      _startCountdown();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send code: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> resendCode() async {
    if (!state.isResendEnabled) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: Implement actual API call to resend code
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Verification code resent',
      );
      
      clearCode();
      _startCountdown();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to resend code: ${e.toString()}',
      );
      return false;
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    
    state = state.copyWith(
      isResendEnabled: false,
      resendCountdown: 60,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdown > 0) {
        state = state.copyWith(resendCountdown: state.resendCountdown - 1);
      } else {
        state = state.copyWith(isResendEnabled: true);
        timer.cancel();
      }
    });
  }

  Future<bool> verifyCode() async {
    if (state.fullCode.length != 6) {
      state = state.copyWith(
        errorMessage: 'Please enter the complete 6-digit code',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: Implement actual API call to verify code
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Code verified successfully',
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid verification code',
      );
      return false;
    }
  }

  void reset() {
    _countdownTimer?.cancel();
    state = ForgotPasswordState();
  }
}

// Provider for forgot password
final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
  return ForgotPasswordNotifier();
});
