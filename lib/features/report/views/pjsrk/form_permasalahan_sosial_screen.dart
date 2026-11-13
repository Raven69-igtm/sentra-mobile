import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/lokasi_autocomplete_field.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/pjsrk_form_header.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/pjsrk_submit_button.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/pjsrk_text_field.dart';

/// ============================================================================
/// HALAMAN: FormPermasalahanSosialScreen
/// ============================================================================
/// Formulir khusus untuk pelaporan cepat "Permasalahan Sosial":
///
/// Daftar Field Input (lengkap dengan ikon gaya PPPA):
/// 1. Nama Lengkap       -> Icons.person_outline_rounded (Hijau)
/// 2. Nomor Telepon      -> Icons.phone_outlined (Oranye)
/// 3. Lokasi             -> Icons.location_on_outlined (Merah) + Autocomplete Dropdown
/// 4. Jenis Permasalahan -> Icons.groups_outlined (Biru)
/// 5. Deskripsi          -> Icons.chat_bubble_outline_rounded (Ungu)
/// ============================================================================
class FormPermasalahanSosialScreen extends StatefulWidget {
  const FormPermasalahanSosialScreen({super.key});

  @override
  State<FormPermasalahanSosialScreen> createState() =>
      _FormPermasalahanSosialScreenState();
}

class _FormPermasalahanSosialScreenState
    extends State<FormPermasalahanSosialScreen> {
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
  void _handleSubmit() async {
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

    setState(() {
      _isLoading = true;
    });

    // 2. Simulasi proses pengiriman data ke server
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // 3. Tampilkan dialog sukses
    _showSuccessDialog();
  }

  /// Dialog konfirmasi bahwa laporan berhasil terkirim
  void _showSuccessDialog() {
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
                "Laporan Permasalahan Sosial Anda telah diterima oleh petugas Sentra untuk segera ditindaklanjuti.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontFamily: 'Mulish',
                  height: 1.4,
                ),
              ),
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
            // 1. HEADER (Judul: "Form Laporan Cepat", Subtitle, & Tombol Tutup X)
            // -----------------------------------------------------------------
            PjsrkFormHeader(
              subtitle: "Permasalahan Sosial",
              onClose: () => Navigator.pop(context),
            ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // -----------------------------------------------------------------
            // 2. KONTEN FORMULIR PERMASALAHAN SOSIAL (DILENGKAPI IKON-IKON)
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

                      // Field 3: Lokasi (Dropdown rekomendasi saat mengetik huruf, misal 'N')
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

                      // Field 4: Jenis Permasalahan Sosial
                      PjsrkTextField(
                        label: "Jenis Permasalahan Sosial",
                        hintText: "Masukkan Jenis Permasalahan",
                        controller: _jenisController,
                        icon: Icons.groups_outlined,
                        iconColor: Colors.blue.shade600,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Jenis Permasalahan Sosial tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 5: Deskripsi Permasalahan Sosial (Multi-baris)
                      PjsrkTextField(
                        label: "Deskripsi Permasalahan Sosial",
                        hintText: "Ceritakan kondisi yang Anda lihat",
                        controller: _deskripsiController,
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Deskripsi Permasalahan Sosial tidak boleh kosong";
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
