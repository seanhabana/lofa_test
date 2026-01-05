import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/forgot_password_models.dart';
class ForgotPasswordService {
  // Send PIN to email
  static Future<SendPinResponse> sendPin(String email) async {
    try {
      print('🔍 Sending PIN to: $email');
      
      final response = await ApiService.post(
        '/password/send-pin',
        body: {'email': email},
      );

      print('📡 Send PIN response status: ${response.statusCode}');
      print('📡 Send PIN response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ PIN sent successfully');
        return SendPinResponse.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to send code');
      }
    } catch (e) {
      print('❌ Error sending PIN: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Verify PIN
  static Future<VerifyPinResponse> verifyPin(String email, String pin) async {
    try {
      print('🔍 Verifying PIN for: $email');
      print('🔍 PIN: $pin');
      
      final response = await ApiService.post(
        '/password/verify-pin',
        body: {
          'email': email,
          'pin': pin,
        },
      );

      print('📡 Verify PIN response status: ${response.statusCode}');
      print('📡 Verify PIN response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('📦 Parsed data: $data');
        
        final result = VerifyPinResponse.fromJson(data);
        // Force reset token to a fixed value as requested
        const forcedToken = 'abc123...';
        print('🔑 Original reset token: ${result.resetToken} -> forcing to: $forcedToken');

        return VerifyPinResponse(
          success: result.success,
          message: result.message,
          resetToken: forcedToken,
        );
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Invalid verification code');
      }
    } catch (e) {
      print('❌ Error verifying PIN: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Reset password
  static Future<ResetPasswordResponse> resetPassword({
    required String email,
    required String resetToken,
    required String pin,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      print('🔍 Resetting password for: $email');
      
      final response = await ApiService.post(
        '/password/reset',
        body: {
          'email': email,
          // Always use the fixed reset token
          'reset_token': 'abc123...',
          'pin': pin,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      print('📡 Reset password response status: ${response.statusCode}');
      print('📡 Reset password response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Password reset successfully');
        return ResetPasswordResponse.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      print('❌ Error resetting password: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}