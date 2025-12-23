import 'package:flutter/material.dart';

Route slideUpRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(0, 1), // from bottom
        end: Offset.zero,
      ).chain(
        CurveTween(curve: Curves.easeInOut),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

// Slide right route (for next lesson) - True Carousel style
Route slideRightRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    opaque: false, // Allow previous page to be visible
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeInOut;

      // New page slides in from right
      final slideTween = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: child,
      );
    },
  );
}

// Slide left route (for previous lesson) - True Carousel style
Route slideLeftRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    opaque: false, // Allow previous page to be visible
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeInOut;

      // New page slides in from left
      final slideTween = Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: child,
      );
    },
  );
}

// Format currency
String formatCurrency(double amount) {
  return '₱${amount.toStringAsFixed(2)}';
}

// Format date
String formatDate(DateTime date) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

// Calculate progress percentage
int calculateProgressPercent(double progress) {
  return (progress * 100).toInt();
}

// Get greeting based on time of day
String getGreeting() {
  final hour = DateTime.now().hour;
  
  if (hour < 12) {
    return 'Good Morning';
  } else if (hour < 17) {
    return 'Good Afternoon';
  } else {
    return 'Good Evening';
  }
}