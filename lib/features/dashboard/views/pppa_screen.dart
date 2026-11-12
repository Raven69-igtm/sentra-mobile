import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/constants/app_constants.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/chat/views/chat_screen.dart';
import 'package:sentra/features/chat/views/room_chat_screen.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'package:sentra/features/dashboard/views/widgets/ppa_service_card.dart';
import 'package:sentra/features/dashboard/views/widgets/tracking_report_widget.dart';
import 'package:sentra/features/dashboard/models/info_model.dart';
import 'package:sentra/features/dashboard/services/info_service.dart';
import 'package:sentra/features/report/views/history_screen.dart';
import 'package:sentra/features/report/views/report_screen.dart';
import 'package:sentra/features/report/views/widgets/graph_widget.dart';

/// Halaman PPA (Pemberdayaan Perempuan dan Perlindungan Anak).
///
/// Konten layanan mengacu pada halaman website SENTRA:
/// - /layanan/perempuan  (Layanan Pemberdayaan Perempuan)
/// - /layanan/anak       (Layanan Perlindungan Anak)
/// Alur pelaporan, pelacakan, riwayat, dan konsultasi merupakan fitur
/// aplikasi SENTRA yang sudah ada dan dipertahankan.
class PppaScreen extends StatefulWidget {
  const PppaScreen({super.key});

  @override
  State<PppaScreen> createState() => _PppaScreenState();
}

class _PppaScreenState extends State<PppaScreen> {
  static const int _berandaTab = 1;

  final InformasiService _informasiService = InformasiService();
  bool _isLoadingInformasi = true;
  String _informasiError = '';
  List<Informasi> _informasiList = [];

  @override
  void initState() {
    super.initState();
    _loadInformasi();
  }

  Future<void> _loadInformasi() async {
    setState(() {
      _isLoadingInformasi = true;
      _informasiError = '';
    });
    try {
      final items = await _informasiService.fetchInformasi();
      if (!mounted) return;
      setState(() {
        _informasiList = items;
        _isLoadingInformasi = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _informasiError = e.toString();
        _isLoadingInformasi = false;
      });
    }
  }

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

  void _openReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LaporanPage()),
    );
  }

  void _openHistory() {
    final userId = Provider.of<UserProvider>(context, listen: false).idAkun;
    if (userId == null || userId <= 0) {
      _showNotice(
        'Silakan login terlebih dahulu untuk melihat riwayat laporan',
        icon: Icons.lock_outline_rounded,
        color: Warna.oren,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryPage()),
    );
  }

  void _openChatRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoomChat()),
    );
  }

  void _openConsultation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => const ChatKonsultasiScreen(
              receiverId: AppConstants.ADMIN_ID,
              receiverName: AppConstants.ADMIN_NAME,
            ),
      ),
    );
  }

  void _onTabSelected(int index) {
    if (index == 0) {
      _openHistory();
    } else if (index == 2) {
      _openReport();
    }
  }

  void _showNotice(
    String message, {
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
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
        backgroundColor: const Color(0xFFF5F7F9),
        body: Column(
          children: [
            _PpaHeader(onBack: _handleBack, onChat: _openChatRoom),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      const _PpaHero(),
                      const SizedBox(height: 16),
                      _PpaQuickActions(
                        onReport: _openReport,
                        onHistory: _openHistory,
                        onConsultation: _openConsultation,
                      ),
                      const SizedBox(height: 20),
                      const TrackingLaporan(),
                      const SizedBox(height: 24),
                      const PpaSectionHeader(
                        icon: Icons.insights_rounded,
                        title: 'Statistik Laporan',
                        subtitle:
                            'Rekap laporan kekerasan di Kabupaten Nganjuk '
                            'berdasarkan kategori.',
                      ),
                      const SizedBox(height: 12),
                      const LineChartScreen(),
                      const SizedBox(height: 24),
                      const PpaSectionHeader(
                        icon: Icons.campaign_outlined,
                        title: 'Informasi Terkini',
                        subtitle:
                            'Informasi terbaru dari Dinas Sosial '
                            'Pemberdayaan Perempuan dan Perlindungan Anak.',
                      ),
                      const SizedBox(height: 12),
                      _buildInformasiSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _PpaBottomNav(
          selectedIndex: _berandaTab,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }

  Widget _buildInformasiSection() {
    if (_isLoadingInformasi) {
      return const _PpaInfoPlaceholder(
        icon: Icons.hourglass_empty_rounded,
        title: 'Memuat informasi...',
        message: 'Mohon tunggu sebentar.',
      );
    }

    if (_informasiError.isNotEmpty) {
      return Column(
        children: [
          _PpaInfoPlaceholder(
            icon: Icons.cloud_off_rounded,
            title: 'Informasi gagal dimuat',
            message: _informasiError,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadInformasi,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Coba Lagi',
              style: TextStyle(fontFamily: 'Mulish'),
            ),
          ),
        ],
      );
    }

    if (_informasiList.isEmpty) {
      return const _PpaInfoPlaceholder(
        icon: Icons.campaign_outlined,
        title: 'Belum ada informasi',
        message: 'Informasi terbaru dari Dinas Sosial P3A akan tampil di sini.',
      );
    }

    return Column(
      children: [
        for (var i = 0; i < _informasiList.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _PpaInfoCard(
            informasi: _informasiList[i],
            onTap: () => _openInformasiDetail(_informasiList[i]),
          ),
        ],
      ],
    );
  }

  void _openInformasiDetail(Informasi informasi) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if ((informasi.gambar ?? '').isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        informasi.gambar!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    informasi.judul,
                    style: const TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    informasi.deskripsi,
                    style: const TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PpaInfoCard extends StatelessWidget {
  final Informasi informasi;
  final VoidCallback onTap;

  const _PpaInfoCard({required this.informasi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String? gambar = informasi.gambar;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDF0F3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (gambar != null && gambar.isNotEmpty)
                Image.network(
                  gambar,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 140,
                        color: const Color(0xFFE8F7ED),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Warna.backgroundIjoDark,
                          size: 32,
                        ),
                      ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      informasi.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      informasi.deskripsi,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Baca selengkapnya',
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Warna.backgroundIjoDark,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Warna.backgroundIjoDark,
                        ),
                      ],
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

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────
class _PpaHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onChat;

  const _PpaHeader({required this.onBack, required this.onChat});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: statusBarHeight + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(color: Warna.backgroundIjo),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _HeaderIconButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Kembali',
                  onTap: onBack,
                ),
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PPA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Pemberdayaan Perempuan & Perlindungan Anak',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xE6FFFFFF),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _HeaderIconButton(
                  icon: Icons.forum_outlined,
                  tooltip: 'Pesan',
                  onTap: onChat,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(56),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Hero / pengantar PPA
// ─────────────────────────────────────────────────────────────
class _PpaHero extends StatelessWidget {
  const _PpaHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Warna.backgroundIjo, Warna.backgroundIjoDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Warna.backgroundIjo.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -36,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(13),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(46),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'DINAS SOSIAL P3A KABUPATEN NGANJUK',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pemberdayaan Perempuan dan Perlindungan Anak',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kami berkomitmen untuk mendukung perempuan agar lebih '
                  'mandiri dan sejahtera, serta melindungi hak dan '
                  'kesejahteraan anak-anak di Kabupaten Nganjuk.',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xE6FFFFFF),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroPill(
                      icon: Icons.female_rounded,
                      label: 'Pemberdayaan Perempuan',
                    ),
                    _HeroPill(
                      icon: Icons.child_care_rounded,
                      label: 'Perlindungan Anak',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(64)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Aksi cepat
// ─────────────────────────────────────────────────────────────
class _PpaQuickActions extends StatelessWidget {
  final VoidCallback onReport;
  final VoidCallback onHistory;
  final VoidCallback onConsultation;

  const _PpaQuickActions({
    required this.onReport,
    required this.onHistory,
    required this.onConsultation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF0F3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.note_add_outlined,
                label: 'Buat Laporan',
                color: Warna.backgroundIjo,
                onTap: onReport,
              ),
            ),
            const _QuickActionDivider(),
            Expanded(
              child: _QuickAction(
                icon: Icons.history_rounded,
                label: 'Riwayat',
                color: Warna.backgroundBiru,
                onTap: onHistory,
              ),
            ),
            const _QuickActionDivider(),
            Expanded(
              child: _QuickAction(
                icon: Icons.support_agent_rounded,
                label: 'Konsultasi',
                color: Warna.oren,
                onTap: onConsultation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionDivider extends StatelessWidget {
  const _QuickActionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFFEDF0F3),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Placeholder informasi
// ─────────────────────────────────────────────────────────────
class _PpaInfoPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _PpaInfoPlaceholder({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF0F3)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F7ED),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Warna.backgroundIjoDark, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 12,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom navigation: Riwayat • PPA • Laporan
// ─────────────────────────────────────────────────────────────
class _PpaBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _PpaBottomNav({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: bottomPadding > 0 ? bottomPadding : 8,
        left: 16,
        right: 16,
      ),
      // heightFactor 1.0 keeps the nav sized to its content; a plain Center
      // would expand to the full Scaffold height and collapse the body.
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Row(
            children: [
              Expanded(
                child: _PpaNavItem(
                  icon: Icons.history_rounded,
                  label: 'Riwayat',
                  isActive: selectedIndex == 0,
                  onTap: () => onTabSelected(0),
                ),
              ),
              Expanded(
                child: _PpaNavItem(
                  icon: Icons.eco_rounded,
                  label: 'PPA',
                  isActive: selectedIndex == 1,
                  onTap: () => onTabSelected(1),
                  isCenter: true,
                ),
              ),
              Expanded(
                child: _PpaNavItem(
                  icon: Icons.description_outlined,
                  label: 'Laporan',
                  isActive: selectedIndex == 2,
                  onTap: () => onTabSelected(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PpaNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isCenter;

  const _PpaNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Warna.backgroundIjo;
    const Color inactiveColor = Color(0xFF9CA3AF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isCenter
                  ? Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withAlpha(70),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  )
                  : SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      icon,
                      color: isActive ? activeColor : inactiveColor,
                      size: 24,
                    ),
                  ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
