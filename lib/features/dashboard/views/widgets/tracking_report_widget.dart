import 'package:sentra/features/report/controllers/report_controller.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/features/dashboard/views/widgets/stepper_tracking_widget.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:sentra/features/report/views/widgets/badge_widget.dart';
import 'package:get/get.dart';

class TrackingLaporan extends StatefulWidget {
  const TrackingLaporan({super.key});

  @override
  _TrackingLaporanState createState() => _TrackingLaporanState();
}

class _TrackingLaporanState extends State<TrackingLaporan> {
  final LaporanController laporanController = Get.put(LaporanController());
  final TextEditingController trackingCodeController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;

  Future<void> cariLaporan() async {
    final String kode = trackingCodeController.text.trim();
    if (kode.isEmpty) {
      CustomSnackbar.show(
        "Masukkan ID laporan terlebih dahulu",
        warna: Colors.orange,
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _searchFocusNode.unfocus();

    try {
      await laporanController.trackingReport(kode);

      if (laporanController.trackingStatus.value.isNotEmpty) {
        if (laporanController.trackingStatus.value == "dirujuk") {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
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
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with animated icon
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                          child: Column(
                            children: [
                              // Animated container for icon
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Warna.backgroundBiru.withOpacity(
                                          0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.forward_to_inbox_rounded,
                                        color: Warna.backgroundBiru,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              // Title with fade-in animation
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: const Text(
                                        "Laporan Berhasil Dirujuk",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Mulish',
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A1A),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              // Subtitle with fade-in animation
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: Text(
                                        "Laporan Anda telah berhasil diteruskan ke instansi terkait untuk ditindaklanjuti.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Mulish',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Divider line
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.grey.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Action button with animation
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Warna.backgroundIjoDark,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                      ).copyWith(
                                        overlayColor:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((Set<WidgetState> states) {
                                              if (states.contains(
                                                WidgetState.pressed,
                                              )) {
                                                return Colors.white.withOpacity(
                                                  0.1,
                                                );
                                              }
                                              return null;
                                            }),
                                      ),
                                      child: const Text(
                                        'Mengerti',
                                        style: TextStyle(
                                          fontFamily: 'Mulish',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }
      } else if (laporanController.errorMessage.value.isNotEmpty) {
        CustomSnackbar.show("ID Laporan Tidak Ditemukan", warna: Colors.red);
        if (Get.overlayContext != null) {
          Get.snackbar('Error', laporanController.errorMessage.value);
        }
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    trackingCodeController.clear();
    // Reset tampilan stepper ke default jika diperlukan
    if (laporanController.trackingStatus.value.isNotEmpty) {
      laporanController.trackingStatus.value = '';
    }
    setState(() {});
  }

  @override
  void dispose() {
    trackingCodeController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    final double horizontalPadding = screenWidth * 0.04;
    final double verticalPadding = screenHeight * 0.02;
    final double searchBarHeight = screenHeight * 0.055;
    final double iconSize = screenWidth * 0.06;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxFontSize =
            screenWidth < 360 ? 16.0 : 18.0; // Batasi ukuran font
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.green.shade50, Colors.green.shade100],
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
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Optimalkan ruang
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.track_changes_rounded,
                                size: iconSize,
                                color: Warna.backgroundIjoDark,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                // Gunakan Flexible untuk mencegah overflow
                                child: Text(
                                  "Lacak Status Laporan",
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w800,
                                    fontSize: (screenWidth * 0.05).clamp(
                                      14.0,
                                      maxFontSize,
                                    ), // Batasi ukuran font
                                    overflow:
                                        TextOverflow
                                            .ellipsis, // Potong teks jika terlalu panjang
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Masukkan ID unik laporan untuk melihat perkembangannya",
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                              fontSize: (screenWidth * 0.035).clamp(
                                12.0,
                                14.0,
                              ), // Optimasi ukuran subtitle
                            ),
                            maxLines: 2, // Batasi jumlah baris
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.white,
                                  elevation: 0,
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(
                                    height: searchBarHeight,
                                    child: TextField(
                                      focusNode: _searchFocusNode,
                                      controller: trackingCodeController,
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: (_) => cariLaporan(),
                                      onChanged: (_) => setState(() {}),
                                      cursorColor: Colors.black87,
                                      style: TextStyle(
                                        fontFamily: 'Mulish',
                                        fontSize: (screenWidth * 0.04).clamp(
                                          14.0,
                                          16.0,
                                        ),
                                      ),
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.confirmation_number_outlined,
                                          color: Colors.grey.shade600,
                                        ),
                                        hintText: "Masukkan ID Laporan",
                                        hintStyle: TextStyle(
                                          fontFamily: 'Mulish',
                                          color: Colors.grey.shade500,
                                          fontSize: (screenWidth * 0.038).clamp(
                                            12.0,
                                            14.0,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.012,
                                          horizontal: screenWidth * 0.02,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: Warna.backgroundIjo,
                                            width: 2,
                                          ),
                                        ),
                                        suffixIcon:
                                            trackingCodeController
                                                    .text
                                                    .isNotEmpty
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
                              SizedBox(
                                height: searchBarHeight,
                                width: searchBarHeight,
                                child: ElevatedButton(
                                  onPressed: _isSearching ? null : cariLaporan,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: Warna.backgroundIjo,
                                    disabledBackgroundColor: Warna.backgroundIjo
                                        .withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child:
                                      _isSearching
                                          ? SizedBox(
                                            width: iconSize * 0.7,
                                            height: iconSize * 0.7,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                          )
                                          : Icon(
                                            Icons.search_rounded,
                                            color: Colors.white,
                                            size: iconSize * 0.9,
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Obx(() {
                      final String currentStatus =
                          laporanController.trackingStatus.value.isEmpty
                              ? 'dikirim'
                              : laporanController.trackingStatus.value;
                      return TrackingBadge(status: currentStatus);
                    }),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(screenWidth * 0.03),
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
                          Icon(
                            Icons.timeline_rounded,
                            color: Warna.backgroundIjoDark,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Perkembangan Laporan',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.w700,
                              fontSize: (screenWidth * 0.042).clamp(14.0, 16.0),
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Obx(() {
                        final String currentStatus =
                            laporanController.trackingStatus.value.isEmpty
                                ? 'dikirim'
                                : laporanController.trackingStatus.value;
                        return MiniStepperTracking(status: currentStatus);
                      }),
                      SizedBox(height: screenHeight * 0.012),
                      Text(
                        'Status akan diperbarui secara otomatis ketika laporan Anda diproses.',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          color: Colors.black54,
                          fontSize: (screenWidth * 0.032).clamp(10.0, 12.0),
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
      },
    );
  }
}

Widget _buildStatusIndicator(String label, Color color, bool isActive) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final double size = constraints.maxWidth * 0.2;
      return Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: size,
                backgroundColor: color,
                child:
                    isActive
                        ? CircleAvatar(
                          radius: size * 0.6,
                          backgroundColor: Colors.green[50],
                        )
                        : null,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: constraints.maxWidth * 0.15,
            ),
          ),
        ],
      );
    },
  );
}

class CustomBadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
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
