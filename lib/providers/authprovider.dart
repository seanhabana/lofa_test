import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../repositories/auth_repository.dart';
import '../models/auth_models.dart';

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

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

class SignUpFormNotifier extends StateNotifier<SignUpFormState> {
  final AuthRepository _authRepository;

  SignUpFormNotifier(this._authRepository) : super(SignUpFormState());

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

  Future<RegisterResponse?> signUp() async {
    if (state.fullName.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your full name');
      return null;
    }

    if (state.email.isEmpty || !state.email.contains('@')) {
      state = state.copyWith(errorMessage: 'Please enter a valid email');
      return null;
    }

    if (state.password.isEmpty || state.password.length < 6) {
      state = state.copyWith(errorMessage: 'Password must be at least 6 characters');
      return null;
    }

    if (state.password != state.confirmPassword) {
      state = state.copyWith(errorMessage: 'Passwords do not match');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authRepository.register(
        name: state.fullName,
        email: state.email,
        password: state.password,
        passwordConfirmation: state.confirmPassword,
      );
      
      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }
}

final signUpFormProvider = StateNotifierProvider<SignUpFormNotifier, SignUpFormState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SignUpFormNotifier(authRepository);
});

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

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final AuthRepository _authRepository;

  LoginFormNotifier(this._authRepository) : super(LoginFormState());

  void updateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  Future<LoginResponse?> login() async {
    if (state.email.isEmpty || !state.email.contains('@')) {
      state = state.copyWith(errorMessage: 'Please enter a valid email');
      return null;
    }

    if (state.password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your password');
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authRepository.login(
        email: state.email,
        password: state.password,
      );
      
      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }
}

final loginFormProvider = StateNotifierProvider<LoginFormNotifier, LoginFormState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginFormNotifier(authRepository);
});

final obscureLoginPasswordProvider = StateProvider<bool>((ref) => true);

// Forgot Password (keep existing code but update repository calls)
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

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final AuthRepository _authRepository;
  Timer? _countdownTimer;

  ForgotPasswordNotifier(this._authRepository) : super(ForgotPasswordState());

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
      await _authRepository.sendPasswordResetCode(email: state.email);
      
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
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> resendCode() async {
    if (!state.isResendEnabled) return false;
    return await sendCode();
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
      await _authRepository.verifyPasswordResetCode(
        email: state.email,
        code: state.fullCode,
      );
      
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Code verified successfully',
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() {
    _countdownTimer?.cancel();
    state = ForgotPasswordState();
  }
}

final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ForgotPasswordNotifier(authRepository);
});