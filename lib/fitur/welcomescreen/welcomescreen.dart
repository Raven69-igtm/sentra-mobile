import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sentra/utils/color.dart';
import 'package:sentra/fitur/authentikasi/screen/views/loginscreen.dart';
import 'package:sentra/utils/customsnackbar.dart';
import 'package:sentra/utils/customroundedbutton.dart';
import 'package:sentra/quickacces.dart';
import 'package:flutter/services.dart';

class WelcomeWithSplashScreen extends StatefulWidget {
  @override
  _WelcomeWithSplashScreenState createState() =>
      _WelcomeWithSplashScreenState();
}

class _WelcomeWithSplashScreenState extends State<WelcomeWithSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _floatController; 
  late Animation<double> _popUpAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoPositionAnimation;
  late Animation<double> _fadeAnimationTitle;
  late Animation<double> _fadeAnimationSubtitle;
  late Animation<double> _fadeAnimationAuthor;
  late Animation<double> _fadeAnimationQuickReport;
  late Animation<double> _fadeAnimationGetStarted;
  late Animation<double> _floatAnimation; 

  final LaporanCepatService _service = LaporanCepatService();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController telpController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();
    
    //controller untuk animasi utama (logo, teks, fade-in tombol)
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    //controller untuk efek floating (berulang)
    _floatController = AnimationController(
      duration: const Duration(seconds: 2), //durasi satu siklus naik-turun
      vsync: this,
    );

    //pop-up animation (muncul)
    _popUpAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack),
      ),
    );

    //rotation animation (memutar)
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.4, curve: Curves.easeOutExpo),
      ),
    );

    //scale animation (menyesuaikan ukuran)
    _logoScaleAnimation = Tween<double>(begin: 1, end: 139 / 240.86).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
      ),
    );

    //position animation (menyesuaikan posisi)
    _logoPositionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.05),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
      ),
    );

    //fade-in animations untuk teks
    _fadeAnimationTitle = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.85, curve: Curves.easeInOut),
      ),
    );

    _fadeAnimationSubtitle = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 0.9, curve: Curves.easeInOut),
      ),
    );

    _fadeAnimationAuthor = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 0.95, curve: Curves.easeInOut),
      ),
    );

    //fade-in animations untuk tombol
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

    //floating animation (naik-turun)
    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutSine, //kurva lembut untuk efek mengambang
      ),
    );

    //mulai animasi utama setelah delay
    Future.delayed(const Duration(seconds: 1), () {
      _controller.forward().then((_) {
        //mulai animasi floating setelah animasi utama selesai
        _floatController.repeat(reverse: true);
      });
    });
  }
  void _playBackgroundMusic() async {
    await _player.play(AssetSource('audio/welcome.mp3'), volume: 0.6);
    _player.setReleaseMode(ReleaseMode.loop); 
  }
  @override
  void dispose() {
    _controller.dispose();
    _floatController.dispose();
    nikController.dispose();
    namaController.dispose();
    telpController.dispose();
    alamatController.dispose();
    deskripsiController.dispose();
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
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: _logoPositionAnimation.value * screenHeight,
                        child: Transform.scale(
                          scale:
                              _logoScaleAnimation.value * _popUpAnimation.value,
                          alignment: Alignment.center,
                          child: RotationTransition(
                            turns: _rotationAnimation,
                            child: RotatedBox(
                              quarterTurns: 2,
                              child: Image.asset(
                                'assets/logo/Image.png',
                                width: screenWidth * 0.6,
                                height: screenWidth * 0.4,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: screenWidth * 0.9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _fadeAnimationTitle,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimationTitle.value,
                              child: child,
                            );
                          },
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
                        AnimatedBuilder(
                          animation: _fadeAnimationSubtitle,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimationSubtitle.value,
                              child: child,
                            );
                          },
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
                        AnimatedBuilder(
                          animation: _fadeAnimationAuthor,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimationAuthor.value,
                              child: child,
                            );
                          },
                          child: Text(
                            "By. DPPPA Nganjuk",
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
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _controller,
                        _floatController,
                      ]),
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimationQuickReport.value,
                          child: Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: child,
                          ),
                        );
                      },
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
                    SizedBox(height: screenWidth * 0.02),
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _controller,
                        _floatController,
                      ]),
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimationGetStarted.value,
                          child: Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: child,
                          ),
                        );
                      },
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
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
      builder: (dialogContext) {
        String? reportId;
        bool isSubmitted = false;
        bool isLoading = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            double maxWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;
            double paddingHorizontal = screenWidth > 600 ? 24 : 16;

            return AlertDialog(
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: paddingHorizontal,
                vertical: 24,
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  minWidth: screenWidth * 0.8,
                  maxHeight: screenHeight * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: Warna.backgroundIjo),
                        )
                      else if (isSubmitted)
                        _buildSuccessContent(
                          reportId: reportId,
                          onSave: () async {
                            await Clipboard.setData(
                              ClipboardData(text: reportId!),
                            );
                            nikController.clear();
                            namaController.clear();
                            telpController.clear();
                            alamatController.clear();
                            deskripsiController.clear();
                            Navigator.pop(dialogContext);
                            CustomSnackbar.show('ID Laporan berhasil disalin',tinggi: 100);
                          },
                        )
                      else
                        _buildFormContent(
                          onSubmit: () async {
                            if (!_isFormValid()) {
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
                              print(result);
                              setState(() {
                                isLoading = false;
                                isSubmitted = result['success'] ?? false;
                                reportId = result['data'];
                              });

                              if (result['success'] == true) {
                                CustomSnackbar.show(
                                  'Laporan berhasil dikirim.',tinggi: 100
                                );
                              } else {
                                CustomSnackbar.show('Laporan gagal dikirim',
                                  tinggi: 100,warna: Colors.red
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
        Icon(
          Icons.check_circle_outline,
          size: screenWidth * 0.15,
          color: Colors.green[600],
        ),
        SizedBox(height: screenWidth * 0.03),
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
      ],
    );
  }

  Widget _buildFormContent({
    required VoidCallback onSubmit,
    required VoidCallback onClose,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = screenWidth > 600 ? 1.0 : 0.9;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Form Laporan Cepat",
              style: TextStyle(
                fontSize: 20 * textScaleFactor,
                color: Colors.blueGrey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: screenWidth * 0.06,
                color: Colors.blueGrey[600],
              ),
              onPressed: onClose,
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.04),
        buildTextField("NIK", nikController, fieldType: 'nik'),
        SizedBox(height: screenWidth * 0.03),
        buildTextField("Nama Lengkap", namaController, fieldType: 'nama'),
        SizedBox(height: screenWidth * 0.03),
        buildTextField("Nomor Telepon", telpController, fieldType: 'notelp'),
        SizedBox(height: screenWidth * 0.03),
        buildTextField(
          "Alamat",
          alamatController,
          fieldType: 'alamat',
          maxLines: 2,
        ),
        SizedBox(height: screenWidth * 0.03),
        buildTextField(
          "Deskripsi Kasus",
          deskripsiController,
          fieldType: 'deskripsi',
          maxLines: 4,
        ),
        SizedBox(height: screenWidth * 0.04),
        CustomRoundedButton(
          text: "Kirim Laporan",
          backgroundColor: Warna.backgroundIjo,
          textColor: Colors.white,
          onPressed: onSubmit,
        ),
      ],
    );
  }

  Widget buildTextField(
  String label,
  TextEditingController controller, {
  int maxLines = 1,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  String? hintText,
  int? maxLength,
  bool obscureText = false,
  String? Function(String?)? validator,
  String? fieldType,
}) {
  if (fieldType != null) {
    switch (fieldType.toLowerCase()) {
      case 'nik':
        keyboardType ??= TextInputType.number;
        inputFormatters ??= [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(16),
        ];
        maxLength ??= 16;
        hintText ??= 'Masukkan 16 digit NIK';
        validator ??= (value) {
          if (value == null || value.isEmpty) return 'NIK tidak boleh kosong';
          if (value.length != 16) return 'NIK harus 16 digit';
          if (value.startsWith('0')) return 'NIK tidak boleh dimulai dengan 0';
          return null;
        };
        break;
      case 'nama':
        keyboardType ??= TextInputType.name;
        inputFormatters ??= [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
        ];
        maxLength ??= 50;
        hintText ??= 'Masukkan nama lengkap';
        validator ??= (value) {
          if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
          if (value.length < 3) return 'Nama terlalu pendek';
          return null;
        };
        break;
      case 'notelp':
        keyboardType ??= TextInputType.phone;
        inputFormatters ??= [
          FilteringTextInputFormatter.digitsOnly,
        ];
        maxLength ??= 15;
        hintText ??= 'Contoh: 081234567890';
        validator ??= (value) {
          if (value == null || value.isEmpty) return 'Nomor telepon tidak boleh kosong';
          if (value.length < 8) return 'Nomor telepon terlalu pendek';
          return null;
        };
        break;
      case 'alamat':
        keyboardType ??= TextInputType.streetAddress;
        maxLines = maxLines.clamp(1, 3);
        maxLength ??= 100;
        hintText ??= 'Masukkan alamat lengkap';
        validator ??= (value) {
          if (value == null || value.isEmpty) return 'Alamat tidak boleh kosong';
          if (value.length < 10) return 'Alamat terlalu pendek';
          return null;
        };
        break;
      case 'deskripsi':
        keyboardType ??= TextInputType.multiline;
        maxLines = maxLines.clamp(1, 4);
        maxLength ??= 200;
        hintText ??= 'Deskripsi kasus (maksimal 200 karakter)';
        break;
    }
  }

  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    maxLength: maxLength,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    obscureText: obscureText,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: const TextStyle(color: Colors.blueGrey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      counterText: '',
    ),
    style: const TextStyle(color: Colors.blueGrey),
  );
}


}
