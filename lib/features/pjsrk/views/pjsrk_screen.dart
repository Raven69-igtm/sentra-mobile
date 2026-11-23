import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';
import 'package:sentra/core/widgets/sentra_curved_header.dart';
import 'package:sentra/core/widgets/sentra_snackbar.dart';
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
  static const Color _backgroundColor = Colors.white;

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
      SentraSnackbar.show(
        'Silakan masuk terlebih dahulu untuk melihat riwayat laporan.',
        context: context,
        type: SentraSnackbarType.warning,
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

    return SentraCurvedHeader(
      gradient: AppColors.pjsrkHeaderGradient,
      backgroundAsset: 'assets/image/beranda/pjsrk.png',
      curveHeight: 28,
      padding: EdgeInsets.only(
        top: statusBarHeight + AppSpacing.sm,
        bottom: 40,
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'Kembali',
                child: IconButton(
                  tooltip: 'Kembali',
                  constraints: const BoxConstraints(
                    minWidth: AppSpacing.minTouchTarget,
                    minHeight: AppSpacing.minTouchTarget,
                  ),
                  onPressed: _handleBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PJSRK',
                      style: AppTypography.title.copyWith(color: Colors.white),
                    ),
                    Text(
                      'Pelayanan Jaminan Sosial & Rehabilitasi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            color: ServicePalette.pjsrk.softTint,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: ServicePalette.pjsrk.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.subtitle),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}
