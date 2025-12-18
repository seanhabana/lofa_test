import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        backgroundColor: Color(0xFFF7F7FB),
        body: Center(child: LogoDemo()),
      ),
    );
  }
}

/// Demo screen with button
class LogoDemo extends StatelessWidget {
  const LogoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        AnimatedLogo(),
        SizedBox(height: 24),
        AnimationToggleButton(),
      ],
    );
  }
}

/// Button controller (kept simple)
class AnimationToggleButton extends StatefulWidget {
  const AnimationToggleButton({super.key});

  @override
  State<AnimationToggleButton> createState() => _AnimationToggleButtonState();
}

class _AnimationToggleButtonState extends State<AnimationToggleButton> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _expanded = !_expanded;
        AnimatedLogoController.toggle(_expanded);
      },
      child: Text(_expanded ? 'Collapse' : 'Expand'),
    );
  }
}

/// Controller (simple global control for demo)
class AnimatedLogoController {
  static void Function(bool expanded)? _toggle;

  static void _bind(void Function(bool expanded) fn) {
    _toggle = fn;
  }

  static void toggle(bool expanded) {
    _toggle?.call(expanded);
  }
}

/// Reusable animated logo widget
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
      duration: const Duration(milliseconds: 700),
    );
    _part1Offset =
        Tween<Offset>(
          begin: const Offset(0, -42),
          end: const Offset(-45, 0), // left + up
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );

    _part2Offset =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, 0), // center stays
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );

    _part3Offset =
        Tween<Offset>(
          begin: const Offset(0, 42),
          end: const Offset(45, 0), // right + down
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );

    // bind controller
    AnimatedLogoController._bind(_handleToggle);
  }

  void _handleToggle(bool expanded) {
    if (expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
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
              // TOP
              Transform.translate(
                offset: _part1Offset.value,
                child: SvgPicture.asset('assets/logo/part1.svg'),
              ),

              // MIDDLE
              Transform.translate(
                offset: _part2Offset.value,
                child: SvgPicture.asset('assets/logo/part2.svg'),
              ),

              // BOTTOM
              Transform.translate(
                offset: _part3Offset.value,
                child: SvgPicture.asset('assets/logo/part3.svg'),
              ),
            ],
          );
        },
      ),
    );
  }
}
