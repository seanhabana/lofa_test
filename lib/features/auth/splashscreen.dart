import 'package:flutter/material.dart';
import '../components/animatedlogo.dart';
import './onboarding.dart'; // whatever your next screen is
import './loginpage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate AFTER animation finishes
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F7FB),
      body: Center(
        child: AnimatedLogo(),
      ),
    );
  }
}
