import 'package:flutter/material.dart';
import 'dart:math' as math;

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  final double animationSpeed;
  final bool showBorder;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.colors = const [
      Color(0xFF40ffaa),
      Color(0xFF4079ff),
      Color(0xFF40ffaa),
      Color(0xFF4079ff),
      Color(0xFF40ffaa),
    ],
    this.animationSpeed = 8,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: showBorder ? Border.all(color: Colors.white, width: 1) : null,
      ),
      padding: const EdgeInsets.all(2),
      child: AnimatedGradientText(
        text: text,
        style: style,
        colors: colors,
        animationSpeed: animationSpeed,
      ),
    );
  }
}

class AnimatedGradientText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  final double animationSpeed;

  const AnimatedGradientText({
    super.key,
    required this.text,
    this.style,
    required this.colors,
    required this.animationSpeed,
  });

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: widget.animationSpeed.toInt()),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              transform: _GradientRotation(_animation.value * 2 * math.pi),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: (widget.style ?? const TextStyle()).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}

class _GradientRotation extends GradientTransform {
  const _GradientRotation(this.radians);

  final double radians;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double sin = math.sin(radians);
    final double cos = math.cos(radians);

    return Matrix4.identity()
      ..translate(bounds.width / 2, bounds.height / 2)
      ..rotateZ(radians)
      ..translate(-bounds.width / 2, -bounds.height / 2);
  }
}
