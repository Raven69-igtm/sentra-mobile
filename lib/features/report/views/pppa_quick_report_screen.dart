import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/core/utils/address_field.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';
import 'package:sentra/features/report/services/quick_report_service.dart';
import 'package:sentra/features/report/views/widgets/pppa/pppa_success_dialog.dart';
import 'package:sentra/features/report/views/widgets/pppa/pppa_text_field.dart';

/// ============================================================================
/// HALAMAN: PppaQuickReportScreen
/// ============================================================================
/// Formulir Laporan Cepat PPPA (Perempuan & Anak) Sentra.
///
/// Komponen Form:
/// 1. NIK (16 digit angka wajib)
/// 2. Nama Lengkap (Huruf sesuai KTP)
/// 3. Nomor Telepon (Dimulai dari angka 0, 10-13 digit)
/// 4. Alamat Lengkap (AddressAutocompleteCompact)
/// 5. Deskripsi Kasus (Kronologi singkat, minimal 20 karakter)
/// 6. Tombol Kirim & Animasi Getar Validasi Form (Shake Animation)
/// ============================================================================
class PppaQuickReportScreen extends StatefulWidget {
  const PppaQuickReportScreen({super.key});

  @override
  State<PppaQuickReportScreen> createState() => _PppaQuickReportScreenState();
}

class _PppaQuickReportScreenState extends State<PppaQuickReportScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final LaporanCepatService _service = LaporanCepatService();

  // Controller untuk masing-masing field form
  final TextEditingController nikController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController telpController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  late List<TextEditingController> _controllers;

  // Controller animasi getar saat ada inputan yang tidak valid
  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controllers = [
      nikController,
      namaController,
      telpController,
      alamatController,
      deskripsiController,
    ];

    // Otomatis huruf kapital di awal setiap kata/input
    for (var controller in _controllers) {
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

    // Inisialisasi animasi shake form
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController!, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _shakeController?.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Menjalankan animasi getar dan menampilkan snackbar peringatan
  void _shakeForm() {
    _shakeController?.reset();
    _shakeController?.forward();
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
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
                      color: Colors.white,
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
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  /// Memeriksa apakah semua field tidak kosong
  bool _isFormValid() {
    return nikController.text.isNotEmpty &&
        namaController.text.isNotEmpty &&
        telpController.text.isNotEmpty &&
        alamatController.text.isNotEmpty &&
        deskripsiController.text.isNotEmpty;
  }

  /// Menghapus seluruh isi form
  void _clearAllFields() {
    nikController.clear();
    namaController.clear();
    telpController.clear();
    alamatController.clear();
    deskripsiController.clear();
  }

  /// Mengirim laporan cepat ke API Sentra
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate() || !_isFormValid()) {
      _shakeForm();
      setState(() {
        _errorMessage = 'Lengkapi semua kolom formulir';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
        _isLoading = false;
      });

      if (result['success'] == true) {
        CustomSnackbar.show('Laporan berhasil dikirim.', tinggi: 100);

        if (mounted) {
          PppaSuccessDialog.show(
            context,
            reportId: result['data']?.toString() ?? '-',
            onFinish: () {
              _clearAllFields();
              Navigator.pop(context); // Kembali ke halaman menu sebelumnya
            },
          );
        }
      } else {
        CustomSnackbar.show(
          'Laporan gagal dikirim',
          tinggi: 100,
          warna: Colors.red,
        );
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal mengirim laporan';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: Stack(
        children: [
          // Background Header Gradien Hijau
          Container(
            height: 230,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF266E4E), Color(0xFF1E563D)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // -------------------------------------------------------------
                // 1. TOP APP BAR DENGAN TOMBOL KEMBALI & IDENTITAS
                // -------------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Laporan Cepat PPPA",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Mulish',
                              ),
                            ),
                            Text(
                              "Perempuan & Anak",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                            SizedBox(width: 5),
                            Text(
                              "Sentra",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Pesan Error Jika Pengiriman Gagal
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Mulish',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // -------------------------------------------------------------
                // 2. KONTEN LEMBAR FORMULIR
                // -------------------------------------------------------------
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _shakeAnimation ?? const AlwaysStoppedAnimation(0),
                      builder: (context, child) {
                        final shakeOffset = _shakeAnimation != null
                            ? sin(_shakeAnimation!.value * pi * 3) * 8
                            : 0.0;
                        return Transform.translate(
                          offset: Offset(shakeOffset, 0),
                          child: child,
                        );
                      },
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Indikator Tahap Informasi
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Warna.backgroundIjo.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.description_outlined,
                                      size: 16,
                                      color: Warna.backgroundIjo,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Informasi Laporan & Pelapor",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade700,
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
                                  gradient: const LinearGradient(
                                    colors: [
                                      Warna.backgroundIjo,
                                      Color(0xFF266E4E),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Form 1: NIK
                              PppaTextField(
                                label: "NIK",
                                controller: nikController,
                                icon: Icons.credit_card_outlined,
                                iconColor: Colors.blue.shade600,
                                fieldType: 'angka',
                                maxLength: 16,
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
                              const SizedBox(height: 16),

                              // Form 2: Nama Lengkap
                              PppaTextField(
                                label: "Nama Lengkap",
                                controller: namaController,
                                icon: Icons.person_outline_rounded,
                                iconColor: Warna.backgroundIjo,
                                fieldType: 'huruf',
                                maxLength: 50,
                                hintText: "Masukkan nama lengkap sesuai KTP",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Form 3: Nomor Telepon
                              PppaTextField(
                                label: "Nomor Telepon",
                                controller: telpController,
                                icon: Icons.phone_outlined,
                                iconColor: const Color(0xFFE07A3B),
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
                              const SizedBox(height: 16),

                              // Form 4: Alamat Lengkap Autocomplete
                              AddressAutocompleteCompact(
                                label: "Alamat Lengkap",
                                maxLength: 200,
                                controller: alamatController,
                                iconColor: Colors.red.shade500,
                                hintText: 'Jalan, RT/RW, Desa/Kelurahan, Kecamatan',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Alamat tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Form 5: Deskripsi Kasus
                              PppaTextField(
                                label: "Deskripsi Kasus",
                                controller: deskripsiController,
                                icon: Icons.chat_bubble_outline_rounded,
                                iconColor: const Color(0xFF6B46C1),
                                maxLines: 4,
                                maxLength: 200,
                                hintText:
                                    'Jelaskan kronologi kejadian secara singkat...',
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
                              const SizedBox(height: 24),

                              // Tombol Kirim Form
                              Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2E7D5B),
                                      Color(0xFF1E563D),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2E7D5B).withOpacity(0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitReport,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.send_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Kirim Laporan Sekarang",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                fontFamily: 'Mulish',
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Keterangan Jaminan Privasi
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F8F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFD4EBDD),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD4EBDD),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.security_rounded,
                                        color: Color(0xFF2E7D5B),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Kerahasiaan Terjamin",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1E563D),
                                              fontFamily: 'Mulish',
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            "Identitas dan laporan Anda dilindungi oleh DPPPA sesuai ketentuan perundang-undangan.",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF4A755E),
                                              fontFamily: 'Mulish',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
