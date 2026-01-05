import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/settings_account_model.dart';
import '../providers/auth_session_provider.dart';
import '../services/settings_account_service.dart'; // Adjust path to your auth session provider

// Service Provider
final accountSettingsServiceProvider = Provider<AccountSettingsService>((ref) {
  return AccountSettingsService();
});

// Account Settings State Provider
final accountSettingsProvider = StateNotifierProvider<AccountSettingsNotifier, AsyncValue<AccountSettings>>((ref) {
  final service = ref.watch(accountSettingsServiceProvider);
  final authSession = ref.watch(authSessionProvider);
  return AccountSettingsNotifier(service, authSession.token);
});

class AccountSettingsNotifier extends StateNotifier<AsyncValue<AccountSettings>> {
  final AccountSettingsService _service;
  final String? _token;

  AccountSettingsNotifier(this._service, this._token) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    if (_token == null) {
      state = AsyncValue.error('No authentication token found', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final settings = await _service.getAccountSettings(_token!);
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
  }) async {
    if (_token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final request = UpdateProfileRequest(name: name, phone: phone);
      final updatedSettings = await _service.updateProfile(request, _token!);
      state = AsyncValue.data(updatedSettings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    if (_token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      await _service.changePassword(request, _token!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestEmailChange(String newEmail) async {
    if (_token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final request = RequestEmailChangeRequest(newEmail: newEmail);
      await _service.requestEmailChange(request, _token!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyEmailChange(String token) async {
    if (_token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final request = VerifyEmailChangeRequest(token: token);
      await _service.verifyEmailChange(request, _token!);
      // Reload settings after email change
      await loadSettings();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> enableTwoFactor(String method) async {
    if (_token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final request = EnableTwoFactorRequest(method: method);
      await _service.enableTwoFactor(request, _token!);
      // Reload settings after enabling 2FA
      await loadSettings();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmTwoFactor(String code) async {
    if (_token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final request = ConfirmTwoFactorRequest(code: code);
      await _service.confirmTwoFactor(request, _token!);
      // Reload settings after confirming 2FA
      await loadSettings();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> disableTwoFactor() async {
    if (_token == null) {
      throw Exception('No authentication token found');
    }

    try {
      await _service.disableTwoFactor(_token!);
      // Reload settings after disabling 2FA
      await loadSettings();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deactivateAccount() async {
    if (_token == null) {
      throw Exception('No authentication token found');
    }

    try {
      await _service.deactivateAccount(_token!);
      // Reload settings after deactivation
      await loadSettings();
    } catch (e) {
      rethrow;
    }
  }
}