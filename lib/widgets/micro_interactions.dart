import 'package:flutter/material.dart';

class MicroInteractions {
  // Animated button with scale effect
  static Widget animatedButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 150),
    double scale = 0.95,
  }) {
    return AnimatedButton(
      onPressed: onPressed,
      duration: duration,
      scale: scale,
      child: child,
    );
  }

  // Animated icon button
  static Widget animatedIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    double size = 24.0,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return AnimatedIconButton(
      icon: icon,
      onPressed: onPressed,
      color: color,
      size: size,
      duration: duration,
    );
  }

  // Ripple effect container
  static Widget rippleContainer({
    required Widget child,
    required VoidCallback onTap,
    Color? rippleColor,
    BorderRadius? borderRadius,
  }) {
    return RippleContainer(
      onTap: onTap,
      rippleColor: rippleColor,
      borderRadius: borderRadius,
      child: child,
    );
  }

  // Animated counter badge
  static Widget animatedCounter({
    required int count,
    Color? backgroundColor,
    Color? textColor,
    double size = 20.0,
  }) {
    return AnimatedCounter(
      count: count,
      backgroundColor: backgroundColor,
      textColor: textColor,
      size: size,
    );
  }

  // Pulse animation for notifications
  static Widget pulseAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    return PulseAnimation(
      duration: duration,
      child: child,
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;
  final double scale;

  const AnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.duration = const Duration(milliseconds: 150),
    this.scale = 0.95,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final Duration duration;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24.0,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) => _controller.reverse());
        widget.onPressed();
      },
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Icon(
              widget.icon,
              color: widget.color ?? Theme.of(context).colorScheme.primary,
              size: widget.size,
            ),
          );
        },
      ),
    );
  }
}

class RippleContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? rippleColor;
  final BorderRadius? borderRadius;

  const RippleContainer({
    super.key,
    required this.child,
    required this.onTap,
    this.rippleColor,
    this.borderRadius,
  });

  @override
  State<RippleContainer> createState() => _RippleContainerState();
}

class _RippleContainerState extends State<RippleContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reset());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          widget.child,
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: (widget.rippleColor ?? Colors.white.withOpacity(0.3))
                        .withOpacity(_opacityAnimation.value),
                    borderRadius: widget.borderRadius,
                  ),
                  transform: Matrix4.identity()
                    ..scale(_scaleAnimation.value),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnimatedCounter extends StatefulWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;

  const AnimatedCounter({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size = 20.0,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.count.toString(),
                style: TextStyle(
                  color: widget.textColor ?? Colors.white,
                  fontSize: widget.size * 0.6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
