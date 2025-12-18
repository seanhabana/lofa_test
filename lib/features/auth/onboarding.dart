import 'package:flutter/material.dart';
import './loginpage.dart'; // Make sure to import your LoginPage

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      title: 'Learn Anytime',
      description: 'Access expert-led courses and video lessons from anywhere in the world',
      imagePath: 'assets/onboarding/onboarding_1.png',
    ),
    OnboardingContent(
      title: 'Track Progress',
      description: 'Monitor your learning journey and complete courses at your own pace',
      imagePath: 'assets/onboarding/onboarding_2.png',
    ),
    OnboardingContent(
      title: 'Get Certified',
      description: 'Earn professional certificates upon completing your courses',
      imagePath: 'assets/onboarding/onboarding_3.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _currentPage < _pages.length - 1) {
        _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Bottom section: dots, button
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF581C87),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingContent content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Image container
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7FB),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                // Background blob
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBA4CC).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Image
                Center(
                  child: Image.asset(
                    content.imagePath,
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        _getIconForPage(_currentPage),
                        size: 140,
                        color: const Color(0xFF9D65AA).withOpacity(0.4),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          // Title
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1a1a1a),
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive 
            ? const Color(0xFF9D65AA) 
            : const Color(0xFFCBA4CC).withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  IconData _getIconForPage(int page) {
    switch (page) {
      case 0:
        return Icons.play_circle_outline;
      case 1:
        return Icons.trending_up;
      case 2:
        return Icons.workspace_premium_outlined;
      default:
        return Icons.school_outlined;
    }
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final String imagePath;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}