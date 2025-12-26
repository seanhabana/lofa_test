import 'dart:convert';
import '../services/api_service.dart';
import '../models/auth_models.dart';

class AuthRepository {
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Some APIs wrap the created resource under `data` or `user` keys.
        if (decoded is Map<String, dynamic>) {
          return RegisterResponse.fromJson(decoded);
        } else {
          // Fallback: convert to map
          return RegisterResponse.fromJson(Map<String, dynamic>.from({
            'message': decoded.toString(),
          }));
        }
      } else {
        // Try to extract useful error message(s)
        if (decoded is Map<String, dynamic>) {
          String message = '';
          if (decoded.containsKey('message') && decoded['message'] != null) {
            message = decoded['message'].toString();
          } else if (decoded.containsKey('errors') && decoded['errors'] is Map) {
            // Flatten the first error messages
            final errors = decoded['errors'] as Map<String, dynamic>;
            final firstMessages = <String>[];
            for (final v in errors.values) {
              if (v is List && v.isNotEmpty) firstMessages.add(v.first.toString());
              else if (v != null) firstMessages.add(v.toString());
            }
            message = firstMessages.join(', ');
          } else {
            message = decoded.toString();
          }

          throw Exception(message.isNotEmpty ? message : 'Registration failed');
        } else {
          throw Exception('Registration failed');
        }
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> sendPasswordResetCode({required String email}) async {
    try {
      final response = await ApiService.post(
        '/auth/forgot-password',
        body: {'email': email},
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to send reset code');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/verify-reset-code',
        body: {
          'email': email,
          'code': code,
        },
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Invalid verification code');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}