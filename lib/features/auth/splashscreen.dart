import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../components/animatedlogo.dart';
import './onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.allowFirstFrame();

  Future.delayed(const Duration(milliseconds: 3000), () {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingPage()),
    );
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: Stack(
        children: [
          // Center animated logo
          const Center(
            child: AnimatedLogo(),
          ),

          // Bottom loading indicator
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                SpinKitRing(
                  color: Color(0xFF581C87), // purplish
                  size: 36,
                  lineWidth: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
