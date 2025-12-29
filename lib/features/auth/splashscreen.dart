import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../shared/animatedlogo.dart';
import './onboarding.dart';
import '../dashboard/home_screen.dart';
import './loginpage.dart';
import '../../providers/auth_session_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authSessionProvider);

    ref.listen(authSessionProvider, (prev, next) {
      if (!next.isLoading) {
        debugPrint('🧭 Splash decision: loggedIn=${next.isLoggedIn}');

        if (next.isLoggedIn) {
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
    });

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
