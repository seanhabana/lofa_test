import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/auth_models.dart';

class AuthSessionState {
  final bool isLoggedIn;
  final String? token;
  final User? user;

  const AuthSessionState({
    required this.isLoggedIn,
    this.token,
    this.user,
  });

  AuthSessionState copyWith({
    bool? isLoggedIn,
    String? token,
    User? user,
  }) {
    return AuthSessionState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

class AuthSessionNotifier extends StateNotifier<AuthSessionState> {
  AuthSessionNotifier() : super(const AuthSessionState(isLoggedIn: false)) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token = prefs.getString('token');
    final userJson = prefs.getString('user');

    if (loggedIn && token != null) {
      User? user;
      if (userJson != null) {
        try {
          user = User.fromJson(json.decode(userJson));
        } catch (e) {
          // Handle parsing error
        }
      }
      
      state = AuthSessionState(
        isLoggedIn: true,
        token: token,
        user: user,
      );
    }
  }

  Future<void> login({
    required bool rememberMe,
    required String token,
    required User user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (rememberMe) {
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', token);
      await prefs.setString('user', json.encode(user.toJson()));
    }

    state = AuthSessionState(
      isLoggedIn: true,
      token: token,
      user: user,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    state = const AuthSessionState(isLoggedIn: false);
  }

  String? getToken() => state.token;
  
  User? getUser() => state.user;
}

final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, AuthSessionState>((ref) {
  return AuthSessionNotifier();
});