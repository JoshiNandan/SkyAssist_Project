// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import 'booking_lookup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Kick off the entrance animation
    _controller.forward();

    // Navigate after 2.8 s total
    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BookingLookupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF), // darker teal — richer than AppColors.primary
              Color(0xFFFFFFFF), // AppColors.primary
              Color(0xFFA8A8A8), // lighter teal highlight
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Main centred branding ────────────────────────────────────
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Icon container ─────────────────────────────
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black12.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.flight_takeoff_rounded,
                            color: Colors.lightGreenAccent,
                            size: 48,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── App name ───────────────────────────────────
                        Text(
                          AppStrings.appTitle,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.black45,
                            letterSpacing: 1.2,
                            height: 1.0,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── Tagline ────────────────────────────────────
                        Text(
                          'Self-Service Flight Recovery',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black45.withValues(alpha: 0.80),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom status strip ──────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Preparing your journey…',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black12.withValues(alpha: 0.65),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: _AnimatedProgressBar(
                          duration: const Duration(milliseconds: 2400),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Thin animated progress bar — grows left-to-right over [duration]
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedProgressBar extends StatefulWidget {
  final Duration duration;
  const _AnimatedProgressBar({required this.duration});

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    // Small initial delay so it starts after the fade-in settles
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (_, constraints) {
            final trackW = constraints.maxWidth;
            return Stack(
              children: [
                // Track
                Container(
                  height: 3,
                  width: trackW,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Fill
                Container(
                  height: 3,
                  width: trackW * _progress.value,
                  decoration: BoxDecoration(
                    color: Colors.black12.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
