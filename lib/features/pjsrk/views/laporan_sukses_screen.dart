import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_screen.dart';
import 'package:sentra/features/report/views/history_screen.dart';

/// Halaman Konfirmasi Sukses Pengiriman Laporan (PJSRK / Sentra)
/// Dibuat sesuai referensi desain Figma "9 Sukses" (pixel-accurate & responsif)
class LaporanSuksesScreen extends StatelessWidget {
  /// Data laporan yang baru saja disubmit
  final Map<String, dynamic>? reportData;

  /// Nomor tiket khusus (opsional, jika kosong akan digenerate otomatis)
  final String? nomorTiket;

  /// Waktu laporan (opsional, jika kosong akan menggunakan waktu saat ini)
  final DateTime? tanggalWaktu;

  /// Callback kustom saat tombol "Lacak Laporan" ditekan
  final VoidCallback? onLacakLaporan;

  /// Callback kustom saat tombol "Kembali ke Beranda" ditekan
  final VoidCallback? onKembaliKeBeranda;

  const LaporanSuksesScreen({
    super.key,
    this.reportData,
    this.nomorTiket,
    this.tanggalWaktu,
    this.onLacakLaporan,
    this.onKembaliKeBeranda,
  });

  // Palet Warna Sesuai Desain Referensi Sentra
  static const Color _primaryOrange = Color(0xFFD8782E);
  static const Color _primaryGreen = Color(0xFF429468);
  static const Color _lightGreenBadge = Color(0xFFE2F2E9);
  static const Color _dashedGreenBorder = Color(0xFF6EBE92);
  static const Color _darkGreenText = Color(0xFF287D56);
  static const Color _neutralDark = Color(0xFF252525);
  static const Color _neutralGrey = Color(0xFF8D9299);

  /// Format nomor tiket otomatis (format contoh: SP-2610-0142)
  String get _formattedTicketNumber {
    if (nomorTiket != null && nomorTiket!.isNotEmpty) {
      return nomorTiket!;
    }
    if (reportData != null && reportData!['nomor_tiket'] != null) {
      return reportData!['nomor_tiket'].toString();
    }
    final now = tanggalWaktu ?? DateTime.now();
    final year = (now.year % 100).toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final randomSuffix = ((now.millisecondsSinceEpoch ~/ 1000) % 9000 + 1000).toString();
    return 'SP-$year$month-$randomSuffix';
  }

  /// Format tanggal & waktu ala Indonesia (contoh: 19 Okt 2026 · 12:41 WIB)
  String get _formattedDateTime {
    final now = tanggalWaktu ?? DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = now.day.toString().padLeft(2, '0');
    final month = months[now.month - 1];
    final year = now.year.toString();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$day $month $year · $hour:$minute WIB';
  }

  /// Salin nomor tiket ke clipboard
  void _copyTicketNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _formattedTicketNumber));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Nomor tiket $_formattedTicketNumber berhasil disalin!',
                style: const TextStyle(fontFamily: 'Mulish', fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handler tombol Lacak Laporan
  void _handleLacakLaporan(BuildContext context) {
    if (onLacakLaporan != null) {
      onLacakLaporan!();
      return;
    }

    // Default: Buka halaman riwayat laporan (HistoryPage)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryPage()),
    );
  }

  /// Handler tombol Kembali ke Beranda (Masuk ke Menu Layanan PJSRK sesuai gambar yang dikirim)
  void _handleKembaliKeBeranda(BuildContext context) {
    if (onKembaliKeBeranda != null) {
      onKembaliKeBeranda!();
      return;
    }

    // Masuk kembali ke menu layanan PJSRK sesuai tampilan referensi gambar yang dikirim
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PjsrkScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // =================================================================
            // 1. APPBAR / HEADER ORANGE HANGAT
            // =================================================================
            _buildHeader(context),

            // =================================================================
            // 2. KONTEN SUKSES UTAMA
            // =================================================================
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),

                        // Icon Checklist Bulat Hijau Besar
                        _buildCheckmarkBadge(),
                        const SizedBox(height: 24),

                        // Judul: Laporan berhasil dikirim
                        const Text(
                          'Laporan berhasil dikirim',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: _neutralDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle: Terima kasih sudah peduli...
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Terima kasih sudah peduli. Petugas akan memverifikasi laporan Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                              color: _neutralGrey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Card Nomor Tiket dengan Dashed Border Hijau
                        _buildTicketCard(context),
                        const SizedBox(height: 36),

                        // =====================================================
                        // 3. TOMBOL AKSI (Lacak Laporan & Kembali ke Beranda)
                        // =====================================================
                        _buildActionButtons(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header Oranye Hangat bertuliskan "Laporan Terkirim"
  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: statusBarHeight + 10,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: _primaryOrange,
      ),
      child: const Center(
        child: Text(
          'Laporan Terkirim',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Mulish',
            fontSize: 18.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  /// Badge Checklist Hijau Bulat Besar
  Widget _buildCheckmarkBadge() {
    return Container(
      width: 104,
      height: 104,
      decoration: const BoxDecoration(
        color: _lightGreenBadge,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.check_rounded,
        size: 58,
        color: _primaryGreen,
      ),
    );
  }

  /// Card Nomor Tiket dengan Garis Putus-putus Hijau
  Widget _buildTicketCard(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: _dashedGreenBorder,
        strokeWidth: 1.3,
        gap: 4.0,
        radius: 16.0,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _copyTicketNumber(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label "Nomor Tiket"
                const Text(
                  'Nomor Tiket',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _neutralGrey,
                  ),
                ),
                const SizedBox(height: 6),

                // Nomor Tiket (Contoh: SP-2610-0142)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formattedTicketNumber,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _darkGreenText,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: _darkGreenText.withOpacity(0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Tanggal dan Jam (Contoh: 19 Okt 2026 · 12:41 WIB)
                Text(
                  _formattedDateTime,
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: _neutralGrey.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Baris Tombol Aksi Bawah
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Tombol 1: Lacak Laporan (Hijau Solid)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: () => _handleLacakLaporan(context),
            child: const Text(
              'Lacak Laporan',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tombol 2: Kembali ke Beranda (Outline Hijau)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryGreen,
              side: const BorderSide(color: _primaryGreen, width: 1.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: Colors.white,
            ),
            onPressed: () => _handleKembaliKeBeranda(context),
            child: const Text(
              'Kembali ke Beranda',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom Painter untuk border putus-putus pada card tiket
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final ui.Path path = ui.Path()..addRRect(rrect);
    final ui.PathMetrics metrics = path.computeMetrics();

    for (final ui.PathMetric metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = (metric.length - distance).clamp(0.0, 5.0);
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += length + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.radius != radius;
  }
}

