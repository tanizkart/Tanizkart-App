import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Isolated Countdown Badge for Lightning Deals
/// Updates strictly internally to prevent whole-screen rebuilds and achieve 60 FPS scrolling.
class LightningCountdownBadge extends StatefulWidget {
  final int initialSeconds;

  const LightningCountdownBadge({
    super.key,
    this.initialSeconds = 14 * 60 + 28,
  });

  @override
  State<LightningCountdownBadge> createState() => _LightningCountdownBadgeState();
}

class _LightningCountdownBadgeState extends State<LightningCountdownBadge> {
  Timer? _timer;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remaining > 0) {
            _remaining--;
          } else {
            _remaining = 15 * 60;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer() {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: TanizColors.metallicGold,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: TanizColors.metallicGold.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        _formatTimer(),
        style: TanizTypography.caption.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: 11,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }
}
