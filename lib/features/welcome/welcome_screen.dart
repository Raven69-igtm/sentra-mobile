import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';
import 'package:sentra/core/widgets/sentra_button.dart';
import 'package:sentra/features/auth/views/login_screen.dart';
import 'package:sentra/features/report/views/pelaporan_cepat_menu_screen.dart';

class WelcomeWithSplashScreen extends StatefulWidget {
  const WelcomeWithSplashScreen({super.key});

  @override
  State<WelcomeWithSplashScreen> createState() =>
      _WelcomeWithSplashScreenState();
}

class _WelcomeWithSplashScreenState extends State<WelcomeWithSplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late final AnimationController _floatController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<Offset> _logoPositionAnimation;
  late final Animation<double> _fadeAnimationTitle;
  late final Animation<double> _fadeAnimationQuickReport;
  late final Animation<double> _fadeAnimationGetStarted;
  late final Animation<double> _floatAnimation;

  final AudioPlayer _player = AudioPlayer();
  bool _isMusicPlaying = false;
  bool _isAudioPrepared = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareAudio();

    // Mempertahankan koreografi rotasi + scale + slide + float logo asli.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3600),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.18, 0.5, curve: Curves.easeInOutCubic),
      ),
    );

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 139 / 240.86,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(139 / 240.86), weight: 45),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.68)),
    );

    _logoPositionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.05),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimationTitle = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.82, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimationQuickReport = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 0.93, curve: Curves.easeIn),
      ),
    );

    _fadeAnimationGetStarted = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.86, 1.0, curve: Curves.easeIn),
      ),
    );

    _floatAnimation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(const AssetImage('assets/logo/Image.png'), context);
      _controller.forward().then((_) {
        if (mounted) {
          _floatController.repeat(reverse: true);
        }
      });
    });
  }

  Future<void> _prepareAudio() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.6);
      await _player.setSource(AssetSource('audio/welcome.mp3'));
      _isAudioPrepared = true;
    } catch (e) {
      debugPrint('Gagal menyiapkan audio welcome: $e');
    }
  }

  Future<void> _toggleBackgroundMusic() async {
    HapticFeedback.lightImpact();
    if (_isMusicPlaying) {
      await _stopBackgroundMusic();
      return;
    }
    try {
      if (_isAudioPrepared) {
        await _player.resume();
      } else {
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.setVolume(0.6);
        await _player.play(AssetSource('audio/welcome.mp3'));
      }
      if (mounted) {
        setState(() => _isMusicPlaying = true);
      }
    } catch (e) {
      debugPrint('Gagal memutar audio welcome: $e');
    }
  }

  Future<void> _stopBackgroundMusic() async {
    try {
      if (_player.state == PlayerState.playing) {
        await _player.stop();
      }
    } catch (e) {
      debugPrint('Gagal menghentikan audio welcome: $e');
    }
    if (mounted && _isMusicPlaying) {
      setState(() => _isMusicPlaying = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopBackgroundMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _floatController.dispose();
    _player.dispose();
    super.dispose();
  }

  Route<void> _slideUpRoute(Widget page) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: SafeArea(
            child: Column(
              children: [
                // Tombol suara opsional di pojok kanan atas
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Semantics(
                        button: true,
                        label:
                            _isMusicPlaying
                                ? 'Matikan musik latar'
                                : 'Putar musik latar',
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: IconButton(
                            tooltip:
                                _isMusicPlaying
                                    ? 'Matikan musik'
                                    : 'Putar musik',
                            constraints: const BoxConstraints(
                              minWidth: AppSpacing.minTouchTarget,
                              minHeight: AppSpacing.minTouchTarget,
                            ),
                            onPressed: _toggleBackgroundMusic,
                            icon: Icon(
                              _isMusicPlaying
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Logo & judul dengan animasi rotasi + scale + slide asli
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SlideTransition(
                          position: _logoPositionAnimation,
                          child: ScaleTransition(
                            scale: _logoScaleAnimation,
                            child: RotationTransition(
                              turns: _rotationAnimation,
                              child: Image.asset(
                                'assets/logo/Image.png',
                                width: screenWidth * 0.56,
                                height: screenWidth * 0.38,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _fadeAnimationTitle,
                          child: Column(
                            children: [
                              Text(
                                'SENTRA',
                                textAlign: TextAlign.center,
                                style: AppTypography.display.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Dinas Sosial dan PPA Kabupaten Nganjuk',
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Dua tombol aksi utama dengan floating halus
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.authHorizontal,
                      AppSpacing.lg,
                      AppSpacing.authHorizontal,
                      AppSpacing.xxl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimationQuickReport,
                          child: AnimatedBuilder(
                            animation: _floatController,
                            builder:
                                (_, child) => Transform.translate(
                                  offset: Offset(0, _floatAnimation.value),
                                  child: child,
                                ),
                            child: SentraButton.onGradient(
                              label: 'Pelaporan Cepat',
                              icon: Icons.flash_on_rounded,
                              onPressed: () async {
                                await _stopBackgroundMusic();
                                if (!context.mounted) return;
                                await Navigator.of(context).push(
                                  _slideUpRoute(
                                    const PelaporanCepatMenuScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FadeTransition(
                          opacity: _fadeAnimationGetStarted,
                          child: AnimatedBuilder(
                            animation: _floatController,
                            builder:
                                (_, child) => Transform.translate(
                                  offset: Offset(0, _floatAnimation.value),
                                  child: child,
                                ),
                            child: SentraButton.onGradientOutlined(
                              label: 'Masuk atau Daftar',
                              onPressed: () async {
                                await _stopBackgroundMusic();
                                if (!context.mounted) return;
                                await Navigator.of(
                                  context,
                                ).push(_slideUpRoute(const LoginPage()));
                              },
                            ),
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
      ),
    );
  }
}
