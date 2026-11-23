import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';

class SplashScreen extends StatefulWidget {
  /// Saat false, splash hanya menampilkan animasi dan tidak berpindah
  /// halaman sendiri (dipakai saat memulihkan sesi).
  final bool autoNavigate;

  const SplashScreen({super.key, this.autoNavigate = true});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _popUpAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _popUpAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.5, curve: Curves.easeOutExpo),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInCubic),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !widget.autoNavigate) return;
      _controller.forward().whenComplete(() {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      });
    });

    if (!widget.autoNavigate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: 1,
                    alignment: Alignment.center,
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: Transform.scale(
                        scale: _popUpAnimation.value,
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: RotatedBox(
                quarterTurns: 2,
                child: Image.asset(
                  'assets/logo/Image.png',
                  width: 240.86,
                  height: 167.7,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
