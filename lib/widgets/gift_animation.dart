import 'package:flutter/material.dart';
import 'dart:math' as math;

class GiftAnimation extends StatefulWidget {
  final String emoji;
  final Color color;
  final int quantity;
  final VoidCallback? onComplete;

  const GiftAnimation({
    super.key,
    required this.emoji,
    required this.color,
    this.quantity = 1,
    this.onComplete,
  });

  @override
  State<GiftAnimation> createState() => _GiftAnimationState();
}

class _GiftAnimationState extends State<GiftAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _floatController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late List<AnimationController> _particleControllers;
  late List<Animation<Offset>> _particleAnimations;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -2),
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeOut,
    ));

    // Create particle animations
    _particleControllers = List.generate(
      math.min(widget.quantity, 10),
      (index) => AnimationController(
        duration: Duration(milliseconds: 1500 + (index * 100)),
        vsync: this,
      ),
    );

    _particleAnimations = _particleControllers.map((controller) {
      final random = math.Random();
      return Tween<Offset>(
        begin: const Offset(0, 0),
        end: Offset(
          (random.nextDouble() - 0.5) * 4,
          -random.nextDouble() * 3 - 1,
        ),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    // Start main animation
    _controller.forward();
    _floatController.forward();

    // Start particle animations with delays
    for (int i = 0; i < _particleControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 50));
      if (mounted) {
        _particleControllers[i].forward();
      }
    }

    // Complete callback
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatController.dispose();
    for (final controller in _particleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _floatController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Main gift emoji
            SlideTransition(
              position: _slideAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ),
            ),

            // Particle effects
            ...List.generate(_particleAnimations.length, (index) {
              return AnimatedBuilder(
                animation: _particleControllers[index],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _particleAnimations[index].value.dx * 50,
                      _particleAnimations[index].value.dy * 50,
                    ),
                    child: Opacity(
                      opacity: 1.0 - _particleControllers[index].value,
                      child: Text(
                        widget.emoji,
                        style: TextStyle(
                          fontSize: 24 - (_particleControllers[index].value * 12),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Quantity indicator
            if (widget.quantity > 1)
              Positioned(
                top: 0,
                right: 0,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'x${widget.quantity}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
