import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<Offset> _part1Offset;
  late final Animation<Offset> _part2Offset;
  late final Animation<Offset> _part3Offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Top part: stacked above → slides left with ease in/out
    _part1Offset = Tween<Offset>(
      begin: const Offset(0, -42),
      end: const Offset(-45, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Slow start, fast middle, slow end
      ),
    );

    // Middle part: stays centered
    _part2Offset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Bottom part: stacked below → slides right with ease in/out
    _part3Offset = Tween<Offset>(
      begin: const Offset(0, 42),
      end: const Offset(45, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Slow start, fast middle, slow end
      ),
    );

    // Start animation after 1 second (matches fade in timing)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 180,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: _part1Offset.value,
                child: SvgPicture.asset(
                  'assets/logo/part1.svg',
                ),
              ),
              Transform.translate(
                offset: _part2Offset.value,
                child: SvgPicture.asset(
                  'assets/logo/part2.svg',
                ),
              ),
              Transform.translate(
                offset: _part3Offset.value,
                child: SvgPicture.asset(
                  'assets/logo/part3.svg',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}