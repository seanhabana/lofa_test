import 'package:flutter/material.dart';

class AuthTopBar extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final double height;
  final Widget? logo;

  const AuthTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.height = 280,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF581C87),
        ),
        child: Stack(
          children: [
            _buildPatterns(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo ??
              Image.asset(
                'assets/logo/logo_white_cropped.png',
                height: 90,
              ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            subtitle!,
          ],
        ],
      ),
    );
  }

  Widget _buildPatterns() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: -50,
          child: Transform.rotate(
            angle: 0.3,
            child: Column(
              children: const [
                _PatternLine(width: 200, color: 0xFF813E98),
                SizedBox(height: 30),
                _PatternLine(width: 250, color: 0xFF9D65AA),
                SizedBox(height: 30),
                _PatternLine(width: 180, color: 0xFFCBA4CC),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: -30,
          child: Transform.rotate(
            angle: -0.3,
            child: Column(
              children: const [
                _PatternLine(width: 150, color: 0xFF9D65AA),
                SizedBox(height: 25),
                _PatternLine(width: 200, color: 0xFF813E98),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
class _PatternLine extends StatelessWidget {
  final double width;
  final int color;

  const _PatternLine({
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: Color(color).withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}


class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start point (controls overall depth)
    path.lineTo(0, size.height - 45);

    // First wave
    final firstControlPoint =
        Offset(size.width / 4, size.height + 10);
    final firstEndPoint =
        Offset(size.width / 2, size.height - 30);

    // Second wave
    final secondControlPoint =
        Offset(size.width * 3 / 4, size.height - 70);
    final secondEndPoint =
        Offset(size.width, size.height - 30);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
