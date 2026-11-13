import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/features/report/views/pjsrk/models/pjsrk_type.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/lokasi_autocomplete_field.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/pjsrk_form_header.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/pjsrk_submit_button.dart';
import 'package:sentra/features/report/views/pjsrk/widgets/pjsrk_text_field.dart';

/// ============================================================================
/// HALAMAN: PjsrkFormScreen
/// ============================================================================
/// Formulir Laporan Cepat PJSRK yang dinamis menyesuaikan tipe layanan:
/// 1. Permasalahan Sosial
/// 2. Bencana Alam
/// 3. Rehabilitasi Sosial
///
/// Fitur Utama:
/// - Header judul & subtitle sesuai layanan + tombol close (X).
/// - Field Nama Lengkap & Nomor Telepon.
/// - Field Lokasi dengan fitur Autocomplete Dropdown (contoh ketik "N" muncul kota).
/// - Field Jenis Laporan & Deskripsi yang otomatis menyesuaikan jenis layanan.
/// - Tombol Submit hijau dengan validasi form.
/// ============================================================================
class PjsrkFormScreen extends StatefulWidget {
  /// Tipe layanan PJSRK (Permasalahan Sosial, Bencana Alam, atau Rehabilitasi Sosial)
  final PjsrkType type;

  const PjsrkFormScreen({
    super.key,
    required this.type,
  });

  @override
  State<PjsrkFormScreen> createState() => _PjsrkFormScreenState();
}

class _PjsrkFormScreenState extends State<PjsrkFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk masing-masing field
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

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

  /// Fungsi pengiriman formulir saat tombol Submit ditekan
  void _onSubmit() async {
    // 1. Validasi form
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

    // Simulasi pengiriman data
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Tampilkan dialog sukses
    _showSuccessDialog();
  }

  /// Menampilkan dialog bahwa laporan berhasil dikirim
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
                "Laporan cepat ${widget.type.subtitle} Anda telah berhasil diterima oleh tim Sentra.",
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
                    Navigator.pop(context); // Kembali ke menu utama
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
            // 1. Header Formulir (Judul + Subtitle + Tombol X)
            PjsrkFormHeader(
              subtitle: widget.type.subtitle,
              onClose: () => Navigator.pop(context),
            ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // 2. Konten Form Input
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

                      // Field 3: Lokasi (Autocomplete Dropdown saat user mengetik)
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

                      // Field 4: Jenis Layanan (Dinamis sesuai Permasalahan / Bencana / Rehabilitasi)
                      PjsrkTextField(
                        label: widget.type.jenisLabel,
                        hintText: widget.type.jenisHint,
                        controller: _jenisController,
                        icon: Icons.category_outlined,
                        iconColor: Colors.blue.shade600,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "${widget.type.jenisLabel} tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 5: Deskripsi Kasus (Dinamis & Multi-baris)
                      PjsrkTextField(
                        label: widget.type.deskripsiLabel,
                        hintText: widget.type.deskripsiHint,
                        controller: _deskripsiController,
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "${widget.type.deskripsiLabel} tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Tombol Submit Hijau
                      PjsrkSubmitButton(
                        isLoading: _isLoading,
                        onPressed: _onSubmit,
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

