import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/pjsrk/repositories/pjsrk_quick_report_repository.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/lokasi_autocomplete_field.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/pjsrk_form_header.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/pjsrk_submit_button.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/pjsrk_text_field.dart';

/// ============================================================================
/// HALAMAN: FormRehabilitasiSosialScreen
/// ============================================================================
/// Formulir khusus untuk pelaporan cepat "Rehabilitasi Sosial":
///
/// Daftar Field Input (lengkap dengan ikon gaya PPPA):
/// 1. Nama Lengkap              -> Icons.person_outline_rounded (Hijau)
/// 2. Nomor Telepon             -> Icons.phone_outlined (Oranye)
/// 3. Lokasi                    -> Icons.location_on_outlined (Merah) + Autocomplete Dropdown
/// 4. Jenis Rehabilitasi Sosial -> Icons.accessibility_new_rounded (Teal)
/// 5. Deskripsi                 -> Icons.chat_bubble_outline_rounded (Ungu)
/// ============================================================================
class FormRehabilitasiSosialScreen extends StatefulWidget {
  const FormRehabilitasiSosialScreen({super.key});

  @override
  State<FormRehabilitasiSosialScreen> createState() =>
      _FormRehabilitasiSosialScreenState();
}

class _FormRehabilitasiSosialScreenState
    extends State<FormRehabilitasiSosialScreen> {
  // Global key untuk validasi form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk membaca dan mengontrol teks input
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  // Status loading saat tombol submit ditekan
  bool _isLoading = false;

  // Repository pengiriman laporan cepat ke backend SENTRA
  final PjsrkQuickReportRepository _repository = PjsrkQuickReportRepository();

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _lokasiController.dispose();
    _jenisController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }


  /// Menangani aksi saat tombol Submit ditekan
  Future<void> _handleSubmit() async {
    // 1. Validasi semua field apakah sudah terisi dengan benar
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi semua kolom formulir"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 2. Pastikan pengguna sudah login sebelum mengirim laporan
    final int? idAkun =
        Provider.of<UserProvider>(context, listen: false).idAkun;

    if (idAkun == null || idAkun <= 0) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan login terlebih dahulu untuk mengirim laporan"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 3. Kirim laporan rehabilitasi sosial ke server SENTRA
    try {
      final nomor = await _repository.kirim(
        idAkun: idAkun,
        layanan: PjsrkQuickReportRepository.layananRehabilitasi,
        nama: _namaController.text,
        telepon: _teleponController.text,
        lokasi: _lokasiController.text,
        jenis: _jenisController.text,
        deskripsi: _deskripsiController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // 4. Tampilkan dialog sukses beserta nomor laporan
      _showSuccessDialog(nomor);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      HapticFeedback.mediumImpact();
      final pesan = error is ApiException
          ? error.message
          : 'Laporan gagal dikirim. Silakan coba lagi.';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Dialog konfirmasi bahwa laporan rehabilitasi sosial berhasil terkirim
  void _showSuccessDialog(String nomor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F8F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D5B),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Laporan Terkirim!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Mulish',
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Laporan Rehabilitasi Sosial Anda telah diterima oleh petugas Sentra untuk segera ditindaklanjuti.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontFamily: 'Mulish',
                  height: 1.4,
                ),
              ),
              if (nomor.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Nomor Laporan",
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Mulish',
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nomor.trim(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Mulish',
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Tutup dialog
                    Navigator.pop(context); // Kembali ke halaman menu
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D5B),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Selesai",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Mulish',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // -----------------------------------------------------------------
            // 1. HEADER (Judul: "Form Laporan Cepat", Subtitle: "Rehabilitasi Sosial")
            // -----------------------------------------------------------------
            PjsrkFormHeader(
              subtitle: "Rehabilitasi Sosial",
              onClose: () => Navigator.pop(context),
            ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // -----------------------------------------------------------------
            // 2. KONTEN FORMULIR REHABILITASI SOSIAL (DILENGKAPI IKON-IKON)
            // -----------------------------------------------------------------
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field 1: Nama Lengkap
                      PjsrkTextField(
                        label: "Nama Lengkap",
                        hintText: "Masukkan nama lengkap",
                        controller: _namaController,
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFF2E7D5B),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Nama lengkap tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 2: Nomor Telepon
                      PjsrkTextField(
                        label: "Nomor Telepon",
                        hintText: "08xxxxxxxxxx",
                        controller: _teleponController,
                        icon: Icons.phone_outlined,
                        iconColor: const Color(0xFFE07A3B),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Nomor telepon tidak boleh kosong";
                          }
                          if (!value.startsWith('0')) {
                            return "Nomor telepon harus diawali 0";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 3: Lokasi (Dropdown rekomendasi kota otomatis saat mengetik)
                      LokasiAutocompleteField(
                        controller: _lokasiController,
                        label: "Lokasi",
                        hintText: "Jalan,Desa,Kecamatan",
                        icon: Icons.location_on_outlined,
                        iconColor: Colors.red.shade500,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Lokasi tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 4: Jenis Rehabilitasi Sosial
                      PjsrkTextField(
                        label: "Jenis Rehabilitasi Sosial",
                        hintText: "Masukkan Jenis Laporan",
                        controller: _jenisController,
                        icon: Icons.accessibility_new_rounded,
                        iconColor: const Color(0xFF0D9488),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Jenis Rehabilitasi Sosial tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 5: Deskripsi Rehabilitasi Sosial (Multi-baris)
                      PjsrkTextField(
                        label: "Deskripsi Rehabilitasi Sosial",
                        hintText:
                            "Ceritakan apa yang anda ketahui dan kondisi yang anda lihat",
                        controller: _deskripsiController,
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Deskripsi Rehabilitasi Sosial tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Tombol Submit Hijau
                      PjsrkSubmitButton(
                        isLoading: _isLoading,
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
