import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionState {
  final bool isLoggedIn;

  const AuthSessionState({required this.isLoggedIn});
}

class AuthSessionNotifier extends StateNotifier<AuthSessionState> {
  AuthSessionNotifier() : super(const AuthSessionState(isLoggedIn: false)) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (loggedIn) {
      state = const AuthSessionState(isLoggedIn: true);
    }
  }

  Future<void> login({required bool rememberMe}) async {
    if (rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
    }

    state = const AuthSessionState(isLoggedIn: true);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    state = const AuthSessionState(isLoggedIn: false);
  }
}

final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, AuthSessionState>((ref) {
  return AuthSessionNotifier();
});
