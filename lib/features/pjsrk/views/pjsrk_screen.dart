import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'package:sentra/features/pjsrk/views/permasalahan_sosial_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_report_event_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_riwayat.dart';
import 'package:sentra/features/pjsrk/views/rehabilitasi_sosial_screen.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_bottom_nav.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_colors.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_feature_card.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_info_card.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_tracking_card.dart';

/// Halaman Menu PJSRK (Pelayanan Jaminan Sosial dan Rehabilitasi Kesejahteraan)
/// dengan komposisi visual yang konsisten dengan halaman PPA.
class PjsrkScreen extends StatefulWidget {
  const PjsrkScreen({super.key});

  @override
  State<PjsrkScreen> createState() => _PjsrkScreenState();
}

class _PjsrkScreenState extends State<PjsrkScreen> {
  static const Color _primaryOrange = PjsrkColors.primary;
  static const Color _backgroundColor = Color(0xFFF5F7F9);

  void _handleBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  /// Navigasi ke form Rehabilitasi Sosial
  void _onRehabilitasiSosialTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RehabilitasiSosialFormScreen()),
    );
  }

  /// Navigasi ke form Pengaduan Bencana
  void _onPengaduanBencanaTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PjsrkReportEventScreen()),
    );
  }

  /// Membuka laporan saya dari menu Riwayat dan Laporan di navigasi bawah.
  void _onLihatLaporanTap() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.idAkun;

    if (userId != null && userId > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LaporanSayaScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Silakan login terlebih dahulu untuk melihat riwayat laporan',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: PjsrkColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      );
    }
  }

  /// Handler pemilihan tab pada bottom navigation bar
  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        _onLihatLaporanTap();
        break;
      case 1:
        Navigator.of(context).maybePop();
        break;
      case 2:
        _onLihatLaporanTap();
        break;
    }
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
        backgroundColor: _backgroundColor,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      const PjsrkInfoCard(),
                      const SizedBox(height: 20),
                      const _PjsrkSectionHeader(
                        icon: Icons.grid_view_rounded,
                        title: 'Fitur PJSRK',
                        subtitle:
                            'Pilih layanan yang sesuai dengan kebutuhan Anda.',
                      ),
                      const SizedBox(height: 12),

                      // Fitur 1: Rehabilitasi Sosial → buka form
                      PjsrkFeatureCard(
                        title: 'Rehabilitasi Sosial',
                        description:
                            'Form pengaduan tunawisma & anak terlantar',
                        icon: Icons.home_outlined,
                        iconColor: PjsrkColors.primary,
                        iconBgColor: PjsrkColors.primaryLight,
                        onTap: _onRehabilitasiSosialTap,
                      ),
                      const SizedBox(height: 12),

                      // Fitur 2: Pengaduan Bencana → buka form
                      PjsrkFeatureCard(
                        title: 'Pengaduan Bencana',
                        description:
                            'Form pengaduan bencana lengkap dengan lokasi & keterangan kejadian',
                        icon: Icons.warning_amber_rounded,
                        iconColor: const Color(0xFFE54D5E),
                        iconBgColor: const Color(0xFFFCE8EB),
                        onTap: _onPengaduanBencanaTap,
                      ),
                      const SizedBox(height: 12),

                      // Fitur 3: Permasalahan Sosial → buka form
                      PjsrkFeatureCard(
                        title: 'Permasalahan Sosial',
                        description:
                            'Form pengaduan permasalahan sosial di lingkungan masyarakat',
                        icon: Icons.people_outline_rounded,
                        iconColor: const Color(0xFF379AE6),
                        iconBgColor: const Color(0xFFE7F2FF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PermasalahanSosialScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const PjsrkTrackingCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: PjsrkBottomNav(
          selectedIndex: 1,
          onTabSelected: _onBottomNavTapped,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE58A3E), _primaryOrange, PjsrkColors.primaryDark],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: _primaryOrange.withAlpha(60),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(right: -30, top: -44, child: _headerCircle(132, 0x20)),
          Positioned(left: -26, bottom: -52, child: _headerCircle(120, 0x16)),
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + 8,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: Colors.white.withAlpha(56),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          mouseCursor: SystemMouseCursors.click,
                          onTap: _handleBack,
                          child: const Tooltip(
                            message: 'Kembali',
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 52),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'PJSRK',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pelayanan Jaminan Sosial & Rehabilitasi',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xE6FFFFFF),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(width: 40, height: 40),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCircle(double size, int alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(alpha),
      ),
    );
  }
}

class _PjsrkSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PjsrkSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: PjsrkColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: PjsrkColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
