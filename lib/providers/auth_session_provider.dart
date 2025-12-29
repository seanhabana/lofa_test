import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/auth_models.dart';

class AuthSessionState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? token;
  final User? user;

  const AuthSessionState({
    required this.isLoggedIn,
    required this.isLoading,
    this.token,
    this.user,
  });

  AuthSessionState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? token,
    User? user,
  }) {
    return AuthSessionState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}


class AuthSessionNotifier extends StateNotifier<AuthSessionState> {
  AuthSessionNotifier()
      : super(const AuthSessionState(
          isLoggedIn: false,
          isLoading: true,
        )) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    debugPrint('🔄 Loading auth session...');

    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token = prefs.getString('token');
    final userJson = prefs.getString('user');

    debugPrint('📦 Stored values:');
    debugPrint('isLoggedIn: $loggedIn');
    debugPrint('token: $token');
    debugPrint('userJson: $userJson');

    if (loggedIn && token != null) {
      User? user;
      if (userJson != null) {
        try {
          user = User.fromJson(json.decode(userJson));
        } catch (e) {
          debugPrint('❌ User parse error: $e');
        }
      }

      state = AuthSessionState(
        isLoggedIn: true,
        isLoading: false,
        token: token,
        user: user,
      );

      debugPrint('✅ Session restored');
    } else {
      state = const AuthSessionState(
        isLoggedIn: false,
        isLoading: false,
      );

      debugPrint('❌ No saved session');
    }
  }

  Future<void> login({
    required bool rememberMe,
    required String token,
    required User user,
  }) async {
    debugPrint('🔐 Login called (rememberMe=$rememberMe)');

    final prefs = await SharedPreferences.getInstance();

    if (rememberMe) {
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', token);
      await prefs.setString('user', json.encode(user.toJson()));

      debugPrint('💾 Session saved');
    }

    state = AuthSessionState(
      isLoggedIn: true,
      isLoading: false,
      token: token,
      user: user,
    );
  }

  Future<void> logout() async {
    debugPrint('🚪 Logout');

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    state = const AuthSessionState(
      isLoggedIn: false,
      isLoading: false,
    );
  }
}


final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, AuthSessionState>((ref) {
  return AuthSessionNotifier();
});