import 'dart:convert';
import 'api_service.dart';
import '../models/settings_account_model.dart';

class AccountSettingsService {
  // Get account settings
  Future<AccountSettings> getAccountSettings(String token) async {
    try {
      print('🔍 Fetching account settings from /account/settings');
      final response = await ApiService.get('/account/settings', token: token);

      print('📡 Account settings response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiResponse = ApiResponse<AccountSettings>.fromJson(
          data,
          (data) => AccountSettings.fromJson(data as Map<String, dynamic>),
        );
        
        if (apiResponse.success) {
          print('✅ Account settings loaded successfully');
          return apiResponse.data;
        } else {
          throw Exception(apiResponse.message ?? 'Failed to load account settings');
        }
      } else {
        print('⚠️ Failed to load account settings: ${response.statusCode}');
        throw Exception('Failed to load account settings: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching account settings: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error fetching account settings: $e');
    }
  }

  // Update profile (name, phone)
  Future<AccountSettings> updateProfile(UpdateProfileRequest request, String token) async {
    try {
      print('🔄 Updating profile...');
      final response = await ApiService.put(
        '/account/profile',
        body: request.toJson(),
        token: token,
      );

      print('📡 Update profile response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiResponse = ApiResponse<AccountSettings>.fromJson(
          data,
          (data) => AccountSettings.fromJson(data as Map<String, dynamic>),
        );
        
        if (apiResponse.success) {
          print('✅ Profile updated successfully');
          return apiResponse.data;
        } else {
          throw Exception(apiResponse.message ?? 'Failed to update profile');
        }
      } else {
        final errorData = json.decode(response.body);
        print('⚠️ Failed to update profile: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Failed to update profile: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error updating profile: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error updating profile: $e');
    }
  }

  // Change password
  Future<void> changePassword(ChangePasswordRequest request, String token) async {
    try {
      print('🔒 Changing password...');
      final response = await ApiService.post(
        '/account/password/change',
        body: request.toJson(),
        token: token,
      );

      print('📡 Change password response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiResponse = ApiResponse<dynamic>.fromJson(
          data,
          (data) => data,
        );
        
        if (apiResponse.success) {
          print('✅ Password changed successfully');
        } else {
          throw Exception(apiResponse.message ?? 'Failed to change password');
        }
      } else {
        final errorData = json.decode(response.body);
        print('⚠️ Failed to change password: ${errorData['message']}');
        throw Exception(errorData['message'] ?? 'Failed to change password');
      }
    } catch (e, stackTrace) {
      print('❌ Error changing password: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Request email change
  Future<void> requestEmailChange(RequestEmailChangeRequest request, String token) async {
    try {
      print('📧 Requesting email change...');
      final response = await ApiService.post(
        '/account/email/request-change',
        body: request.toJson(),
        token: token,
      );

      print('📡 Request email change response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiResponse = ApiResponse<dynamic>.fromJson(
          data,
          (data) => data,
        );
        
        if (apiResponse.success) {
          print('✅ Email change requested successfully');
        } else {
          throw Exception(apiResponse.message ?? 'Failed to request email change');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to request email change');
      }
    } catch (e, stackTrace) {
      print('❌ Error requesting email change: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Verify email change
  Future<void> verifyEmailChange(VerifyEmailChangeRequest request, String token) async {
    try {
      print('✉️ Verifying email change...');
      final response = await ApiService.post(
        '/account/email/verify-change',
        body: request.toJson(),
        token: token,
      );

      print('📡 Verify email change response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiResponse = ApiResponse<dynamic>.fromJson(
          data,
          (data) => data,
        );
        
        if (apiResponse.success) {
          print('✅ Email change verified successfully');
        } else {
          throw Exception(apiResponse.message ?? 'Failed to verify email change');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to verify email change');
      }
    } catch (e, stackTrace) {
      print('❌ Error verifying email change: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Enable two-factor authentication
  Future<void> enableTwoFactor(EnableTwoFactorRequest request, String token) async {
    try {
      print('🔐 Enabling two-factor authentication...');
      final response = await ApiService.post(
        '/account/two-factor/enable',
        body: request.toJson(),
        token: token,
      );

      print('📡 Enable 2FA response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiResponse = ApiResponse<dynamic>.fromJson(
          data,
          (data) => data,
        );
        
        if (apiResponse.success) {
          print('✅ Two-factor authentication enabled');
        } else {
          throw Exception(apiResponse.message ?? 'Failed to enable two-factor');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to enable two-factor');
      }
    } catch (e, stackTrace) {
      print('❌ Error enabling two-factor: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Confirm two-factor authentication
  Future<void> confirmTwoFactor(ConfirmTwoFactorRequest request, String token) async {
    try {
      print('✅ Confirming two-factor authentication...');
      final response = await ApiService.post(
        '/account/two-factor/confirm',
        body: request.toJson(),
        token: token,
      );

      print('📡 Confirm 2FA response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiResponse = ApiResponse<dynamic>.fromJson(
          data,
          (data) => data,
        );
        
        if (apiResponse.success) {
          print('✅ Two-factor authentication confirmed');
        } else {
          throw Exception(apiResponse.message ?? 'Failed to confirm two-factor');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to confirm two-factor');
      }
    } catch (e, stackTrace) {
      print('❌ Error confirming two-factor: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Disable two-factor authentication
  Future<void> disableTwoFactor(String token) async {
    try {
      print('🔓 Disabling two-factor authentication...');
      final response = await ApiService.post(
        '/account/two-factor/disable',
        body: {},
        token: token,
      );

      print('📡 Disable 2FA response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiResponse = ApiResponse<dynamic>.fromJson(
          data,
          (data) => data,
        );
        
        if (apiResponse.success) {
          print('✅ Two-factor authentication disabled');
        } else {
          throw Exception(apiResponse.message ?? 'Failed to disable two-factor');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to disable two-factor');
      }
    } catch (e, stackTrace) {
      print('❌ Error disabling two-factor: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Deactivate account
  Future<void> deactivateAccount(String token) async {
    try {
      print('⚠️ Deactivating account...');
      final response = await ApiService.post(
        '/account/deactivate',
        body: {},
        token: token,
      );

      print('📡 Deactivate account response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiResponse = ApiResponse<dynamic>.fromJson(
          data,
          (data) => data,
        );
        
        if (apiResponse.success) {
          print('✅ Account deactivated successfully');
        } else {
          throw Exception(apiResponse.message ?? 'Failed to deactivate account');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to deactivate account');
      }
    } catch (e, stackTrace) {
      print('❌ Error deactivating account: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}