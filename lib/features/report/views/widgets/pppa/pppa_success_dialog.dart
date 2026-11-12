import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';

/// ============================================================================
/// WIDGET: PppaSuccessDialog
/// ============================================================================
/// Dialog konfirmasi sukses setelah laporan terkirim ke server Sentra:
/// - Animasi centang Lottie (done.json).
/// - Badge ID Laporan.
/// - Tombol salin ID laporan ke clipboard dan tutup dialog.
/// ============================================================================
class PppaSuccessDialog extends StatelessWidget {
  final String reportId;
  final VoidCallback onFinish;

  const PppaSuccessDialog({
    super.key,
    required this.reportId,
    required this.onFinish,
  });

  /// Static helper untuk memanggil dialog dengan mudah
  static Future<void> show(
    BuildContext context, {
    required String reportId,
    required VoidCallback onFinish,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PppaSuccessDialog(
        reportId: reportId,
        onFinish: onFinish,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animasi Centang Lottie
            SizedBox(
              width: 140,
              height: 140,
              child: Lottie.asset(
                'assets/animations/done.json',
                fit: BoxFit.contain,
                repeat: false,
              ),
            ),
            const SizedBox(height: 12),

            // Judul Dialog
            Text(
              "Laporan Terkirim",
              style: TextStyle(
                color: Colors.blueGrey[800],
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Mulish',
              ),
            ),
            const SizedBox(height: 8),

            // Badge ID Laporan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                "ID Laporan: $reportId",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Mulish',
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Deskripsi Keterangan
            Text(
              "Simpan ID laporan untuk melacak status setelah login.\nPetugas akan segera menghubungi Anda.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey[600],
                fontSize: 13,
                height: 1.45,
                fontFamily: 'Mulish',
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Salin ID & Selesai
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: reportId));
                  Navigator.pop(context); // Tutup dialog
                  onFinish(); // Callback selesai
                  CustomSnackbar.show('ID Laporan berhasil disalin', tinggi: 100);
                },
                icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                label: const Text(
                  "Salin ID & Selesai",
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Warna.backgroundIjo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

