import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'colors.dart';

/// TanizKart Strict Motion System
/// Only two curves across the entire app:
/// 1. Entrance: Curves.easeOutCubic (250-350ms)
/// 2. State Change: Curves.easeInOut (200ms)
class TanizMotion {
  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Duration entranceDuration = Duration(milliseconds: 300);

  static const Curve stateCurve = Curves.easeInOut;
  static const Duration stateDuration = Duration(milliseconds: 200);
}

/// Reusable tappable component providing AnimatedScale to 0.96 + HapticFeedback.lightImpact()
class TanizTappable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double scaleTo;

  const TanizTappable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.scaleTo = 0.96,
  });

  @override
  State<TanizTappable> createState() => _TanizTappableState();
}

class _TanizTappableState extends State<TanizTappable> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleTo : 1.0,
        curve: TanizMotion.stateCurve,
        duration: TanizMotion.stateDuration,
        child: widget.borderRadius != null
            ? ClipRRect(
                borderRadius: widget.borderRadius!,
                child: widget.child,
              )
            : widget.child,
      ),
    );
  }
}

/// Shimmer skeleton loader for image placeholders and loading states (shimmer package)
class TanizShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const TanizShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      period: const Duration(milliseconds: 1400),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Cart badge with elastic pop animation on quantity change, instead of flat rebuild
class ElasticPopBadge extends StatefulWidget {
  final int count;
  final Color backgroundColor;
  final TextStyle? textStyle;

  const ElasticPopBadge({
    super.key,
    required this.count,
    this.backgroundColor = TanizColors.accentGold,
    this.textStyle,
  });

  @override
  State<ElasticPopBadge> createState() => _ElasticPopBadgeState();
}

class _ElasticPopBadgeState extends State<ElasticPopBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.count;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.90), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant ElasticPopBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != _lastCount) {
      _lastCount = widget.count;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) return const SizedBox.shrink();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(999), // 999px pill per design system
          boxShadow: [
            BoxShadow(
              color: widget.backgroundColor.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '${widget.count}',
          style: widget.textStyle ??
              const TextStyle(
                color: TanizColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
        ),
      ),
    );
  }
}
