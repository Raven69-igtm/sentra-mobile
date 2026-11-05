import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sentra/core/utils/address_field.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/features/auth/views/login_screen.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';
import 'package:sentra/core/utils/custom_button.dart';
import 'package:sentra/features/report/services/quick_report_service.dart';
import 'package:flutter/services.dart';

class WelcomeWithSplashScreen extends StatefulWidget {
  const WelcomeWithSplashScreen({super.key});

  @override
  _WelcomeWithSplashScreenState createState() =>
      _WelcomeWithSplashScreenState();
}

class _WelcomeWithSplashScreenState extends State<WelcomeWithSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _floatController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoPositionAnimation;
  late Animation<double> _fadeAnimationTitle;
  late Animation<double> _fadeAnimationSubtitle;
  late Animation<double> _fadeAnimationAuthor;
  late Animation<double> _fadeAnimationQuickReport;
  late Animation<double> _fadeAnimationGetStarted;
  late Animation<double> _floatAnimation;
  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;

  final LaporanCepatService _service = LaporanCepatService();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController telpController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  late List<TextEditingController> controllers;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    controllers = [
      nikController,
      namaController,
      telpController,
      alamatController,
      deskripsiController,
    ];
    for (var controller in controllers) {
      controller.addListener(() {
        if (controller.text.isNotEmpty) {
          final newText =
              controller.text[0].toUpperCase() + controller.text.substring(1);
          if (controller.text != newText) {
            controller.value = controller.value.copyWith(
              text: newText,
              selection: TextSelection.collapsed(offset: newText.length),
            );
          }
        }
      });
    }

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController!, curve: Curves.elasticOut),
    );

    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeInOutCubic),
      ),
    );

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 139 / 240.86,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(139 / 240.86), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7)),
    );

    _logoPositionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.05),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Fade-in teks
    _fadeAnimationTitle = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _fadeAnimationSubtitle = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    _fadeAnimationAuthor = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    // Fade-in tombol
    _fadeAnimationQuickReport = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 0.95, curve: Curves.easeIn),
      ),
    );
    _fadeAnimationGetStarted = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.9, 1.0, curve: Curves.easeIn),
      ),
    );

    // Floating lebih halus
    _floatAnimation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(const AssetImage('assets/logo/Image.png'), context);
      _controller.forward().then((_) {
        _floatController.repeat(reverse: true);
      });
      _playBackgroundMusic();
    });
  }

  void _playBackgroundMusic() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.6);
    await _player.play(AssetSource('audio/welcome.mp3'));
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatController.dispose();
    _shakeController?.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Warna.backgroundIjo, Warna.backgroundBiru],
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
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
                          width: screenWidth * 0.6,
                          height: screenWidth * 0.4,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimationTitle,
                          child: Text(
                            "SENTRA",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        FadeTransition(
                          opacity: _fadeAnimationSubtitle,
                          child: Text(
                            "(Sistem Entitas Pelaporan dan Tanggap Respons Aksi)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.030,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        FadeTransition(
                          opacity: _fadeAnimationAuthor,
                          child: Text(
                            "By. P3A Nganjuk",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontFamily: "Mulish",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimationQuickReport,
                      child: AnimatedBuilder(
                        animation: _floatController,
                        builder:
                            (context, child) => Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: child,
                            ),
                        child: CustomRoundedButton(
                          text: "Buat Laporan",
                          icon: Icons.flash_on,
                          backgroundColor: const Color(0xFFFDF6E3),
                          textColor: const Color(0xFF8B6220),
                          onPressed: () {
                            showQuickReportDialog();
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    FadeTransition(
                      opacity: _fadeAnimationGetStarted,
                      child: AnimatedBuilder(
                        animation: _floatController,
                        builder:
                            (context, child) => Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: child,
                            ),
                        child: CustomRoundedButton(
                          text: "Get Started",
                          backgroundColor: const Color.fromARGB(
                            255,
                            227,
                            253,
                            227,
                          ),
                          textColor: Warna.backgroundIjo,
                          onPressed: () async {
                            await _player.stop();
                            Navigator.of(
                              context,
                            ).push(_slideUpRoute(const LoginPage()));
                          }
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
    );
  }

  void showQuickReportDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (dialogContext) {
        String? reportId;
        bool isSubmitted = false;
        bool isLoading = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth > 600 ? 500 : double.infinity,
                  maxHeight: screenHeight * 0.85,
                  minHeight: 200,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading)
                        _buildLoadingContent()
                      else if (isSubmitted)
                        _buildSuccessContent(
                          reportId: reportId,
                          onSave: () async {
                            await Clipboard.setData(
                              ClipboardData(text: reportId!),
                            );
                            _clearAllFields();
                            Navigator.pop(dialogContext);
                            CustomSnackbar.show(
                              'ID Laporan berhasil disalin',
                              tinggi: 100,
                            );
                          },
                        )
                      else
                        _buildFixedFormContent(
                          onSubmit: () async {
                            if (!_isFormValid()) {
                              _shakeForm();
                              setState(() {
                                errorMessage = 'Lengkapi semua kolom formulir';
                              });
                              return;
                            }

                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });

                            try {
                              final result = await _service.kirimLaporanCepat(
                                idAkun: 3,
                                nik: nikController.text,
                                nama: namaController.text,
                                noTelp: telpController.text,
                                alamat: alamatController.text,
                                deskripsi: deskripsiController.text,
                              );

                              setState(() {
                                isLoading = false;
                                isSubmitted = result['success'] ?? false;
                                reportId = result['data'];
                              });

                              if (result['success'] == true) {
                                CustomSnackbar.show(
                                  'Laporan berhasil dikirim.',
                                  tinggi: 100,
                                );
                              } else {
                                CustomSnackbar.show(
                                  'Laporan gagal dikirim',
                                  tinggi: 100,
                                  warna: Colors.red,
                                );
                                setState(() {
                                  errorMessage =
                                      result['message'] ??
                                      'Gagal mengirim laporan';
                                });
                              }
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Terjadi kesalahan: $e';
                              });
                            }
                          },
                          onClose: () => Navigator.pop(dialogContext),
                          errorMessage: errorMessage,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

Route _slideUpRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(
        milliseconds: 600,
      ), // Durasi lebih panjang untuk kehalusan
      reverseTransitionDuration: const Duration(
        milliseconds: 400,
      ), // Reverse sedikit lebih cepat
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutSine,
          reverseCurve: Curves.easeInOutSine,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Mulai dari bawah
            end: Offset.zero, // Berakhir di posisi normal
          ).animate(curved),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.2, // Mulai dengan sedikit opasitas
              end: 1.0, // Penuh pada akhir
            ).animate(curved),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24), 
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildLoadingContent() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Warna.backgroundIjo, Warna.backgroundBiru],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Mengirim Laporan...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              fontFamily: 'Mulish',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Mohon tunggu sebentar",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontFamily: 'Mulish',
            ),
          ),
        ],
      ),
    );
  }

  bool _isFormValid() {
    return nikController.text.isNotEmpty &&
        namaController.text.isNotEmpty &&
        telpController.text.isNotEmpty &&
        alamatController.text.isNotEmpty &&
        deskripsiController.text.isNotEmpty;
  }

  Widget _buildSuccessContent({
    required String? reportId,
    required VoidCallback onSave,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = screenWidth > 600 ? 1.0 : 0.9;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: screenWidth * 0.5,
          height: screenWidth * 0.5,
          child: Lottie.asset(
            'assets/animations/done.json',
            fit: BoxFit.contain,
            repeat: false,
          ),
        ),
        SizedBox(height: screenWidth * 0.01),
        Text(
          "Laporan Terkirim",
          style: TextStyle(
            color: Colors.blueGrey[800],
            fontSize: 22 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          "ID Laporan: $reportId",
          style: TextStyle(
            color: Colors.green[700],
            fontSize: 16 * textScaleFactor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          "Simpan ID laporan untuk melacak status setelah login.\nPetugas akan segera menghubungi Anda.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blueGrey[600],
            fontSize: 14 * textScaleFactor,
            height: 1.5,
          ),
        ),
        SizedBox(height: screenWidth * 0.04),
        CustomRoundedButton(
          text: "Simpan & Tutup",
          backgroundColor: Warna.backgroundIjo,
          textColor: Colors.white,
          onPressed: onSave,
        ),
        SizedBox(height: screenWidth * 0.04),
      ],
    );
  }

  final _formKey = GlobalKey<FormState>();
  Widget _buildFixedFormContent({
    required VoidCallback onSubmit,
    required VoidCallback onClose,
    String? errorMessage,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = screenWidth > 600 ? 1.0 : 0.9;

    return AnimatedBuilder(
      animation: _shakeAnimation ?? const AlwaysStoppedAnimation(0),
      builder: (context, child) {
        final shakeOffset = sin(_shakeAnimation!.value * pi * 3) * 8;

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Container(
            height: screenHeight * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Warna.backgroundIjo, Warna.backgroundBiru],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.flash_on_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Laporan Cepat",
                                    style: TextStyle(
                                      fontSize: 20 * textScaleFactor,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Mulish',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Sampaikan laporan Anda dengan cepat dan aman",
                                    style: TextStyle(
                                      fontSize: 12 * textScaleFactor,
                                      color: Colors.white.withOpacity(0.9),
                                      fontFamily: 'Mulish',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                onPressed: onClose,
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12 * textScaleFactor,
                                      fontFamily: 'Mulish',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Compact Progress indicator
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timeline,
                                      size: 16,
                                      color: Warna.backgroundIjo,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Langkah 1 dari 1 - Informasi Dasar",
                                      style: TextStyle(
                                        fontSize: 12 * textScaleFactor,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                        fontFamily: 'Mulish',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: LinearGradient(
                                      colors: [
                                        Warna.backgroundIjo,
                                        Warna.backgroundBiru,
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Fields
                          _buildCompactTextField(
                            label: "NIK",
                            controller: nikController,
                            icon: Icons.credit_card_outlined,
                            iconColor: Colors.blue,
                            fieldType: 'angka',
                            maxLength: 16,
                            keyboardType: TextInputType.number,
                            hintText: "Masukkan 16 digit NIK Anda",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'NIK tidak boleh kosong';
                              }
                              if (value.length != 16) {
                                return 'NIK harus 16 digit';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          _buildCompactTextField(
                            label: "Nama Lengkap",
                            controller: namaController,
                            icon: Icons.person_outline,
                            iconColor: Colors.green,
                            fieldType: 'huruf',
                            maxLength: 50,
                            keyboardType: TextInputType.name,
                            hintText: "Masukkan nama lengkap sesuai KTP",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          _buildCompactTextField(
                            label: "Nomor Telepon",
                            controller: telpController,
                            icon: Icons.phone_outlined,
                            iconColor: Colors.orange,
                            fieldType: 'angka',
                            maxLength: 13,
                            keyboardType: TextInputType.phone,
                            hintText: "08xxxxxxxxxx",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nomor telepon tidak boleh kosong';
                              }
                              if (!value.startsWith('0')) {
                                return 'Nomor telepon harus diawali 0';
                              }
                              if (value.length < 10 || value.length > 13) {
                                return 'Nomor telepon tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          AddressAutocompleteCompact(
                            label: "Alamat Lengkap",
                            maxLength: 200,
                            controller: alamatController,
                            iconColor: Colors.red,
                            hintText: 'Jalan, RT/RW, Desa/Kelurahan, Kecamatan',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          _buildCompactTextField(
                            label: "Deskripsi Kasus",
                            controller: deskripsiController,
                            icon: Icons.description_outlined,
                            iconColor: Colors.purple,
                            fieldType: 'huruf',
                            maxLines: 3,
                            maxLength: 200,
                            hintText:
                                'Jelaskan kronologi kasus secara singkat...',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Deskripsi tidak boleh kosong';
                              }
                              if (value.length < 20) {
                                return 'Deskripsi minimal 20 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Submit Button
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Warna.backgroundIjo,
                                  Warna.backgroundBiru,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Warna.backgroundIjo.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  onSubmit();
                                } else {
                                  _shakeForm();
                                }
                              },
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                "Kirim Laporan Sekarang",
                                style: TextStyle(
                                  fontSize: 14 * textScaleFactor,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Mulish',
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Privacy
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade50,
                                  Colors.green.shade50,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.blue.shade100,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.security,
                                    color: Colors.blue.shade600,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Privasi Terjamin",
                                        style: TextStyle(
                                          fontSize: 11 * textScaleFactor,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                          fontFamily: 'Mulish',
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        "Data Anda akan dijaga kerahasiaan sesuai kebijakan privasi.",
                                        style: TextStyle(
                                          fontSize: 10 * textScaleFactor,
                                          color: Colors.blue.shade600,
                                          fontFamily: 'Mulish',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
    int? maxLength,
    bool obscureText = false,
    String? Function(String?)? validator,
    String? fieldType,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = screenWidth > 600 ? 1.0 : 0.9;

    if (fieldType != null) {
      switch (fieldType.toLowerCase()) {
        case 'angka':
          keyboardType = TextInputType.number;
          inputFormatters = [
            FilteringTextInputFormatter.digitsOnly,
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ];
          break;
        case 'huruf':
          inputFormatters = [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ];
          break;
        case 'tanpa filter':
          inputFormatters = [
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ];
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withOpacity(0.15),
                      iconColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: iconColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13 * textScaleFactor,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  fontFamily: 'Mulish',
                ),
              ),
              if (validator != null)
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Text(
                    "*",
                    style: TextStyle(
                      color: Colors.red.shade500,
                      fontSize: 14 * textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            obscureText: obscureText,
            style: TextStyle(
              fontSize: 14 * textScaleFactor,
              fontFamily: 'Mulish',
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13 * textScaleFactor,
                fontFamily: 'Mulish',
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 14 : 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: iconColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2),
              ),
              errorStyle: TextStyle(
                color: Colors.red.shade600,
                fontSize: 11 * textScaleFactor,
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w500,
              ),
              counterStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10 * textScaleFactor,
                fontFamily: 'Mulish',
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  void _clearAllFields() {
    nikController.clear();
    namaController.clear();
    telpController.clear();
    alamatController.clear();
    deskripsiController.clear();
  }

  void _shakeForm() {
    _shakeController?.reset();
    _shakeController?.forward();
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Oops! Ada yang terlewat',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Mohon lengkapi semua field yang wajib diisi',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }
}
