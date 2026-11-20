import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentra/features/dashboard/views/widgets/stepper_tracking_widget.dart';
import 'package:sentra/features/report/controllers/report_controller.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';

/// Widget Lacak Status Laporan khusus halaman beranda PJSRK (tema oranye).
/// Fungsionalitas identik dengan [TrackingLaporan] di halaman PPA/Dashboard,
/// tetapi warna disesuaikan dengan identitas visual PJSRK (oranye).
class PjsrkTrackingWidget extends StatefulWidget {
  const PjsrkTrackingWidget({super.key});

  @override
  State<PjsrkTrackingWidget> createState() => _PjsrkTrackingWidgetState();
}

class _PjsrkTrackingWidgetState extends State<PjsrkTrackingWidget> {
  static const Color _primaryOrange = Color(0xFFD8782E);
  static const Color _lightOrange = Color(0xFFFBEADB);

  final LaporanController _laporanController = Get.put(LaporanController());
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Controller GetX dipakai bersama halaman lain; kosongkan status lama
    // agar stepper selalu mulai dari keadaan "belum ada laporan yang dilacak".
    _laporanController.trackingStatus.value = '';
    _codeController.clear();
  }

  Future<void> _cariLaporan() async {
    final String kode = _codeController.text.trim();
    if (kode.isEmpty) {
      CustomSnackbar.show(
        'Masukkan ID laporan terlebih dahulu',
        warna: _primaryOrange,
      );
      return;
    }

    setState(() => _isSearching = true);
    _focusNode.unfocus();

    try {
      await _laporanController.trackingReport(kode);

      if (_laporanController.trackingStatus.value == 'dirujuk') {
        if (mounted) _showDirujukDialog();
      } else if (_laporanController.errorMessage.value.isNotEmpty) {
        CustomSnackbar.show(
          _laporanController.errorMessage.value,
          warna: Colors.red,
          tinggi: 100,
          icon: Icons.error_outline_rounded,
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _clearSearch() {
    _codeController.clear();
    if (_laporanController.trackingStatus.value.isNotEmpty) {
      _laporanController.trackingStatus.value = '';
    }
    setState(() {});
  }

  void _showDirujukDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (_, value, __) => Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _lightOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.forward_to_inbox_rounded,
                            color: _primaryOrange,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Laporan Berhasil Dirujuk',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Laporan Anda telah berhasil diteruskan ke instansi terkait untuk ditindaklanjuti.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                color: Colors.grey.shade200,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Mengerti',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double screenH = MediaQuery.of(context).size.height;
    final double hPad = screenW * 0.04;
    final double vPad = screenH * 0.02;
    final double barH = screenH * 0.055;
    final double iconSz = screenW * 0.06;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF4EC), Color(0xFFFFE5CC)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // === Baris atas: Judul + Badge ===
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Row(
                        children: [
                          Icon(
                            Icons.track_changes_rounded,
                            size: iconSz,
                            color: _primaryOrange,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Lacak Status Laporan',
                              style: TextStyle(
                                fontFamily: 'Mulish',
                                color: Colors.black87,
                                fontWeight: FontWeight.w800,
                                fontSize: (screenW * 0.05).clamp(14.0, 18.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'Masukkan ID unik laporan untuk melihat perkembangannya',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                          fontSize: (screenW * 0.035).clamp(12.0, 14.0),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenH * 0.015),
                      // Search bar
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.white,
                              elevation: 0,
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                height: barH,
                                child: TextField(
                                  focusNode: _focusNode,
                                  controller: _codeController,
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (_) => _cariLaporan(),
                                  onChanged: (_) => setState(() {}),
                                  cursorColor: Colors.black87,
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize:
                                        (screenW * 0.04).clamp(14.0, 16.0),
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.confirmation_number_outlined,
                                      color: Colors.grey.shade600,
                                    ),
                                    hintText: 'Masukkan ID Laporan',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Mulish',
                                      color: Colors.grey.shade500,
                                      fontSize:
                                          (screenW * 0.038).clamp(12.0, 14.0),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: screenH * 0.012,
                                      horizontal: screenW * 0.02,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: _primaryOrange,
                                        width: 2,
                                      ),
                                    ),
                                    suffixIcon:
                                        _codeController.text.isNotEmpty
                                            ? IconButton(
                                                tooltip: 'Bersihkan',
                                                onPressed: _clearSearch,
                                                icon: Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.grey.shade600,
                                                ),
                                              )
                                            : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Tombol cari
                          SizedBox(
                            height: barH,
                            width: barH,
                            child: ElevatedButton(
                              onPressed: _isSearching ? null : _cariLaporan,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: _primaryOrange,
                                disabledBackgroundColor:
                                    _primaryOrange.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: _isSearching
                                  ? SizedBox(
                                      width: iconSz * 0.7,
                                      height: iconSz * 0.7,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Icon(
                                      Icons.search_rounded,
                                      color: Colors.white,
                                      size: iconSz * 0.9,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge ikon
                SizedBox(width: screenW * 0.04),
                ClipPath(
                  clipper: _BadgeClipper(),
                  child: Container(
                    width: 60,
                    height: 72,
                    color: _primaryOrange,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenH * 0.02),

            // === Perkembangan Laporan ===
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(screenW * 0.03),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.timeline_rounded,
                        color: _primaryOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Perkembangan Laporan',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w700,
                          fontSize: (screenW * 0.042).clamp(14.0, 16.0),
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenH * 0.015),
                  Obx(() {
                    // Status kosong = belum ada laporan yang dilacak,
                    // stepper menampilkan keadaan netral (tanpa langkah aktif).
                    return MiniStepperTracking(
                      status: _laporanController.trackingStatus.value,
                    );
                  }),
                  SizedBox(height: screenH * 0.012),
                  Text(
                    'Status akan diperbarui secara otomatis ketika laporan Anda diproses.',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      color: Colors.black54,
                      fontSize: (screenW * 0.032).clamp(10.0, 12.0),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom clipper untuk badge segitiga di pojok kanan atas.
class _BadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.75);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

