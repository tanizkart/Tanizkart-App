import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../main_navigation_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();

    // Auto navigate after 2.2 seconds
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, animation, secondaryAnimation) => const MainNavigationShell(),
            transitionsBuilder: (_, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
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
    return Scaffold(
      backgroundColor: TanizColors.midnightNavy,
      body: Stack(
        children: [
          // Background subtle ambient radial glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TanizColors.primaryBlue.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TanizColors.goldenAmber.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central Hero Brand Animation
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value * _pulseAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glowing halo container with logo
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: TanizColors.primaryBlue.withValues(alpha: 0.4),
                                blurRadius: 36,
                                spreadRadius: 4,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: TanizColors.goldenAmber.withValues(alpha: 0.2),
                                blurRadius: 24,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            height: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'TANIZ',
                                  style: TanizTypography.headlineMedium.copyWith(
                                    color: TanizColors.primaryBlue,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  'KART',
                                  style: TanizTypography.headlineMedium.copyWith(
                                    color: TanizColors.goldenAmber,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Save money • Save time',
                          style: TanizTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: TanizColors.rapidGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Superfast Delivery in Ongole',
                                style: TanizTypography.labelSmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Loading Spinner
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    TanizColors.goldenAmber,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
