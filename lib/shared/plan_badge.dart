// lib/shared/plan_badge.dart
import 'package:flutter/material.dart';

class PlanBadge extends StatelessWidget {
  final String plan;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final bool outlined;

  const PlanBadge({
    super.key,
    required this.plan,
    this.fontSize = 14,
    this.padding,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final planColors = _getPlanColors(plan);
    
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : planColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: outlined ? Border.all(color: planColors.textColor, width: 1.5) : null,
      ),
      child: Text(
        plan.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: outlined ? planColors.textColor : planColors.textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  PlanColors _getPlanColors(String plan) {
    switch (plan.toLowerCase()) {
      case 'free':
        return PlanColors(
          backgroundColor: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF15803D),
        );
      case 'core':
        return PlanColors(
          backgroundColor: const Color(0xFFF3E8FF),
          textColor: const Color(0xFF7C3AED),
        );
      case 'pro':
        return PlanColors(
          backgroundColor: const Color(0xFFE9D5FF),
          textColor: const Color(0xFF581C87),
        );
      case 'elite':
        return PlanColors(
          backgroundColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFB45309),
        );
      default:
        return PlanColors(
          backgroundColor: Colors.grey[200]!,
          textColor: Colors.grey[700]!,
        );
    }
  }
}

class PlanColors {
  final Color backgroundColor;
  final Color textColor;

  PlanColors({
    required this.backgroundColor,
    required this.textColor,
  });
}

// Alternative compact version for smaller spaces
class PlanBadgeCompact extends StatelessWidget {
  final String plan;

  const PlanBadgeCompact({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return PlanBadge(
      plan: plan,
      fontSize: 11,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

// Outlined version for cards
class PlanBadgeOutlined extends StatelessWidget {
  final String plan;
  final double fontSize;

  const PlanBadgeOutlined({
    super.key,
    required this.plan,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return PlanBadge(
      plan: plan,
      fontSize: fontSize,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      outlined: true,
    );
  }
}