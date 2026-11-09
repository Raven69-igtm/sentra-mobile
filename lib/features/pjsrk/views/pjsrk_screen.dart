import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/features/auth/views/profile_screen.dart';
import 'package:sentra/features/notification/views/notification_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_report_event_screen.dart';
import 'package:sentra/features/pjsrk/views/rehabilitasi_sosial_screen.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_bottom_nav.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_feature_card.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_info_card.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_report_card.dart';
import 'package:sentra/features/report/views/report_screen.dart';

/// Halaman Menu PJSRK (Pelayanan Jaminan Sosial dan Rehabilitasi Kesejahteraan)
/// Sesuai dengan desain referensi kedua (pixel-accurate & responsif)
class PjsrkScreen extends StatefulWidget {
  const PjsrkScreen({super.key});

  @override
  State<PjsrkScreen> createState() => _PjsrkScreenState();
}

class _PjsrkScreenState extends State<PjsrkScreen> {
  // Warna tema halaman PJSRK
  static const Color _primaryOrange = Color(0xFFD8782E);
  static const Color _backgroundColor = Color(0xFFF8F9FA);

  // Tab aktif: 0=Beranda, 1=Laporan, 2=Notifikasi, 3=Profil
  int _selectedTab = 0;

  void _onTabSelected(int index) {
    if (index == _selectedTab) return;
    setState(() => _selectedTab = index);
  }

  /// Menampilkan snackbar feedback sementara yang rapi dan konsisten
  void _showFeatureNotice(String featureName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Layanan $featureName sedang dalam pengembangan',
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Navigasi ke form Rehabilitasi Sosial
  void _onRehabilitasiSosialTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RehabilitasiSosialFormScreen(),
      ),
    );
  }

  /// Navigasi ke form Pengaduan Bencana
  void _onPengaduanBencanaTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PjsrkReportEventScreen(),
      ),
    );
  }

  /// Navigasi ke tab Laporan (index 1)
  void _onLihatLaporanTap() {
    _onTabSelected(1);
  }

  /// Handler pemilihan tab pada bottom navigation bar
  void _onBottomNavTapped(int index) {
    _onTabSelected(index);
    // tab 0 (Beranda) — scroll ke atas jika sudah di sana
    if (index == 0 && _selectedTab == 0) {
      Navigator.of(context).pop();
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
        body: _buildBody(),
        bottomNavigationBar: PjsrkBottomNav(
          selectedIndex: _selectedTab,
          onTabSelected: _onBottomNavTapped,
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedTab) {
      case 1:
        return const LaporanPage();
      case 2:
        return const NotificationPage();
      case 3:
        return const ProfileScreen();
      default:
        return _buildPjsrkHome();
    }
  }

  Widget _buildPjsrkHome() {
    return Column(
      children: [
            _buildHeader(context),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PjsrkInfoCard(
                          title: 'PJSRK',
                          description:
                              'Pilih jenis laporan yang ingin Anda sampaikan. Petugas akan menindaklanjuti dalam 2 hari kerja.',
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Fitur PJSRK',
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF252525),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Fitur 1: Rehabilitasi Sosial → buka form
                        PjsrkFeatureCard(
                          title: 'Rehabilitasi Sosial',
                          description:
                              'Form pengaduan tunawisma & anak terlantar',
                          icon: Icons.home_outlined,
                          iconColor: const Color(0xFFD8782E),
                          iconBgColor: const Color(0xFFFFF0E4),
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

                        // Fitur 3: masih notice
                        PjsrkFeatureCard(
                          title: 'Permasalahan Sosial',
                          description:
                              'Form pengaduan permasalahan sosial di lingkungan masyarakat',
                          icon: Icons.people_outline_rounded,
                          iconColor: const Color(0xFF379AE6),
                          iconBgColor: const Color(0xFFE7F2FF),
                          onTap: () =>
                              _showFeatureNotice('Permasalahan Sosial'),
                        ),
                        const SizedBox(height: 12),

                        PjsrkReportCard(
                          onTap: _onLihatLaporanTap,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
  }

  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: statusBarHeight + 8,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: _primaryOrange,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
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
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                'PJSRK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}