// Animated reveal for cards in HomePage
import 'package:flutter/material.dart';

class AnimatedCardReveal extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedCardReveal({
    required this.child,
    required this.index,
    super.key,
  });

  @override
  State<AnimatedCardReveal> createState() => _AnimatedCardRevealState();
}

class _AnimatedCardRevealState extends State<AnimatedCardReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    final Animation<Offset> slide = Tween<Offset>(
        begin: const Offset(0, 0.05), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: widget.child,
      ),
    );
  }
}
