import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _bounceController;
  late final AnimationController _scaleController;

  late final Animation<Offset> _part1SlideIn;
  late final Animation<Offset> _part2SlideIn;
  late final Animation<Offset> _part3SlideIn;

  late final Animation<double> _part1Bounce;
  late final Animation<double> _part2Bounce;
  late final Animation<double> _part3Bounce;

  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initial slide-in animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Subtle bounce animation
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Scale pulse animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Parts slide in from their horizontal positions (already in place but offset)
    _part1SlideIn = Tween<Offset>(
      begin: const Offset(-60, 0), // Start further left
      end: const Offset(-45, 0),   // End at final position
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    _part2SlideIn = Tween<Offset>(
      begin: const Offset(0, -20), // Start slightly above
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    _part3SlideIn = Tween<Offset>(
      begin: const Offset(60, 0), // Start further right
      end: const Offset(45, 0),   // End at final position
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Subtle vertical bounce for each part (staggered)
    _part1Bounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -8)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -8, end: 2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 2, end: 0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_bounceController);

    _part2Bounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -10)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10, end: 2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 2, end: 0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_bounceController);

    _part3Bounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -8)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -8, end: 2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 2, end: 0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_bounceController);

    // Scale pulse at the end
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations in sequence
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _slideController.forward().then((_) {
          if (mounted) {
            _bounceController.forward().then((_) {
              if (mounted) {
                _scaleController.forward().then((_) {
                  if (mounted) {
                    _scaleController.reverse();
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 120,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _slideController,
          _bounceController,
          _scaleController,
        ]),
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Part 1 (Left)
                Transform.translate(
                  offset: Offset(
                    _part1SlideIn.value.dx,
                    _part1SlideIn.value.dy + _part1Bounce.value,
                  ),
                  child: Opacity(
                    opacity: _slideController.value,
                    child: SvgPicture.asset(
                      'assets/logo/part1.svg',
                    ),
                  ),
                ),
                // Part 2 (Center)
                Transform.translate(
                  offset: Offset(
                    _part2SlideIn.value.dx,
                    _part2SlideIn.value.dy + _part2Bounce.value,
                  ),
                  child: Opacity(
                    opacity: _slideController.value,
                    child: SvgPicture.asset(
                      'assets/logo/part2.svg',
                    ),
                  ),
                ),
                // Part 3 (Right)
                Transform.translate(
                  offset: Offset(
                    _part3SlideIn.value.dx,
                    _part3SlideIn.value.dy + _part3Bounce.value,
                  ),
                  child: Opacity(
                    opacity: _slideController.value,
                    child: SvgPicture.asset(
                      'assets/logo/part3.svg',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}