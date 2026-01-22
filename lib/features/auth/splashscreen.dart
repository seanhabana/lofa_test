import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../shared/animatedlogo.dart';
import './onboarding.dart';
import '../dashboard/home_screen.dart';
import './loginpage.dart';
import '../../providers/auth_session_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _startLogoAnimationAndNavigate();
  }

  void _startLogoAnimationAndNavigate() async {
    // Wait for the logo animation to complete (2.5 seconds total)
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted || _hasNavigated) return;

    // Wait until session is loaded
    while (ref.read(authSessionProvider).isLoading && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    if (_hasNavigated || !mounted) return;

    final auth = ref.read(authSessionProvider);
    _hasNavigated = true;

    debugPrint('🧭 Navigating after logo: loggedIn=${auth.isLoggedIn}');

    if (auth.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: Stack(
        children: [
          Center(child: AnimatedLogo()),
          const Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: SpinKitRing(
              color: Color(0xFF813E98),
              size: 36,
              lineWidth: 5,
            ),
          ),
        ],
      ),
    );
  }
}
