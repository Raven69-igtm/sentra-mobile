import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/dashboard/views/widgets/layanan_card_background.dart';
import 'package:sentra/features/dashboard/views/pppa_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_screen.dart';
import 'package:sentra/features/notification/views/notification_screen.dart';

/// Model data untuk Menu Layanan
class LayananItem {
  final String id;
  final String title;
  final String description;
  final List<String> tags;

  /// Warna identitas layanan (dipakai sebagai aksen, bukan gradient penuh).
  final List<Color> gradientColors;
  final IconData icon;

  /// true untuk layanan yang belum tersedia (kartu PSK → Coming Soon).
  final bool comingSoon;

  /// Ilustrasi latar khas tiap kartu layanan.
  final LayananCardArt art;

  const LayananItem({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.gradientColors,
    required this.icon,
    required this.art,
    this.comingSoon = false,
  });
}

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data master layanan sesuai desain referensi (PJSRK, PSK, PPPA)
  final List<LayananItem> _allLayanan = const [
    LayananItem(
      id: 'pjsrk',
      title: 'PJSRK',
      description: 'Rehabilitasi sosial, bencana & permasalahan sosial',
      tags: ['Rehabilitasi Sosial', 'Bencana', 'Permasalahan Sosial'],
      gradientColors: [Color(0xFFE57E3B), Color(0xFFD46824)],
      icon: Icons.favorite_border_rounded,
      art: LayananCardArt.pjsrk,
    ),
    LayananItem(
      id: 'psk',
      title: 'PSK',
      description: 'Makam pahlawan & jadwal kegiatan mendatang',
      tags: ['Makam Pahlawan', 'Jadwal Kegiatan'],
      gradientColors: [Color(0xFF5B6BBF), Color(0xFF4856A6)],
      icon: Icons.outlined_flag_rounded,
      comingSoon: true,
      art: LayananCardArt.psk,
    ),
    LayananItem(
      id: 'pppa',
      title: 'PPPA',
      description:
          'Layanan Dinas Sosial Perlindungan Perempuan & Pemberdayaan Anak',
      tags: ['Pengaduan Kekerasan', 'Pemberdayaan Anak'],
      gradientColors: [Color(0xFF48B167), Color(0xFF389753)],
      icon: Icons.shield_outlined,
      art: LayananCardArt.pppa,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Menentukan sapaan otomatis berdasarkan waktu perangkat
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat siang,';
    if (hour >= 15 && hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  // ===========================================================================
  // NAVIGASI & AKSI INTERAKTIF
  // ===========================================================================

  /// Aksi ketika kartu layanan ditekan
  void _onLayananTap(BuildContext context, LayananItem item) {
    if (item.comingSoon) {
      _showComingSoonDialog(context);
      return;
    }
    switch (item.id) {
      case 'pjsrk':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PjsrkScreen()),
        );
        break;
      case 'pppa':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PppaScreen()),
        );
        break;
    }
  }

  /// Aksi ketika salah satu tag/fitur di dalam kartu ditekan
  void _onTagTap(BuildContext context, LayananItem item, String tag) {
    if (item.comingSoon) {
      _showComingSoonDialog(context);
      return;
    }
    if (item.id == 'pjsrk') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PjsrkScreen()),
      );
      return;
    }
    if (item.id == 'pppa') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PppaScreen()),
      );
    }
  }

  /// Dialog Coming Soon untuk kartu PSK — tanpa navigasi & tanpa request API.
  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(120),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B6BBF).withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_outlined,
                    color: Color(0xFF5B6BBF),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B6BBF).withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'COMING SOON',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color(0xFF5B6BBF),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Layanan Segera Hadir',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF252525),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Layanan PSK sedang dalam tahap pengembangan. '
                  'Kami sedang mempersiapkan layanan ini agar dapat '
                  'memberikan pengalaman terbaik untuk Anda.\n\n'
                  'Mohon tunggu informasi selanjutnya.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF8D9299),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Warna.backgroundIjo,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Mengerti',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil nama pengguna dari UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final String userName = userProvider.user?.nama ?? 'Pengguna';

    // Filter daftar layanan jika sedang melakukan pencarian
    final filteredLayanan =
        _allLayanan.where((item) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          final matchesTitle = item.title.toLowerCase().contains(q);
          final matchesDesc = item.description.toLowerCase().contains(q);
          final matchesTags = item.tags.any(
            (tag) => tag.toLowerCase().contains(q),
          );
          return matchesTitle || matchesDesc || matchesTags;
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // 1. TOP APP BAR / HEADER (HIJAU SESUAI DESAIN)
          _buildTopHeader(context),

          // 2. KONTEN BERANDA (SCROLLABLE)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                // Beri ruang untuk bottom navigation di bagian bawah
                bottom:
                    MediaQuery.of(context).padding.bottom +
                    kBottomNavigationBarHeight +
                    40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sapaan & Nama User
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          userName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF252525),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('👋', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Badge "Akun terverifikasi"
                  _buildVerifiedBadge(),

                  const SizedBox(height: 16),

                  // Search Bar Interaktif
                  _buildSearchBar(),

                  const SizedBox(height: 20),

                  // Section Header: Menu Layanan
                  const Text(
                    'Menu Layanan',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pilih layanan yang Anda butuhkan',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Daftar Kartu Layanan (PJSRK, PSK, PPPA)
                  if (filteredLayanan.isEmpty)
                    _buildEmptySearchResult()
                  else
                    ...filteredLayanan.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildServiceCard(context, item),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET COMPONENTS
  // ===========================================================================

  /// Header bagian atas: identitas SENTRA + tombol lonceng notifikasi.
  /// Hijau khas SENTRA dengan rounded bottom, aman terhadap status bar.
  Widget _buildTopHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 12, 16, 16),
      decoration: const BoxDecoration(
        color: Warna.backgroundIjo,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo / identitas layanan
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/logo/logo_sentra.png',
              width: 38,
              height: 38,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SENTRA',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                'Dinas Sosial & PPA',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Lonceng Notifikasi di kanan atas
          Material(
            color: Colors.white.withAlpha(51), // 20% opacity
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Badge Akun Terverifikasi
  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7EBD2), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF2E8540)),
          SizedBox(width: 4),
          Text(
            'Akun terverifikasi',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E8540),
            ),
          ),
        ],
      ),
    );
  }

  /// Search Bar interaktif dengan fitur real-time filtering dan clear button
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontFamily: 'Mulish',
          fontSize: 13,
          color: Colors.black87,
        ),
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari layanan, makam, jadwal kegiatan...',
          hintStyle: TextStyle(
            fontFamily: 'Mulish',
            fontSize: 13,
            color: Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey[500],
            size: 22,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.cancel_rounded,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  String? _imageAssetFor(LayananItem item) {
    switch (item.id) {
      case 'pjsrk':
        return 'assets/image/beranda/pjsrk.png';
      case 'psk':
        return 'assets/image/beranda/psk.png';
      case 'pppa':
        return 'assets/image/beranda/pppa.png';
      default:
        return null;
    }
  }

  /// Kartu Layanan (PJSRK, PSK, PPPA) — gradient warna khas tiap layanan
  /// dengan aksen dekoratif halus. Kartu PSK tetap penuh warna, ditandai
  /// badge COMING SOON sebagai indikator layanan belum tersedia.
  Widget _buildServiceCard(BuildContext context, LayananItem item) {
    final bool isComingSoon = item.comingSoon;
    final String? imageAsset = _imageAssetFor(item);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onLayananTap(context, item),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: item.gradientColors,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: item.gradientColors.last.withAlpha(90),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Aksen lingkaran dekoratif (ring halus + titik lembut)
              Positioned(
                right: -34,
                top: -34,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(26),
                      width: 14,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -52,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(14),
                  ),
                ),
              ),

              if (imageAsset != null)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.54,
                      heightFactor: 1,
                      child: Image.asset(
                        imageAsset,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        item.gradientColors.first.withAlpha(255),
                        item.gradientColors.first.withAlpha(125),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        item.gradientColors.last.withAlpha(0),
                        item.gradientColors.last.withAlpha(120),
                      ],
                      stops: const [0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // Konten Utama Kartu
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Atas: Ikon di kiri, badge/panah di kanan
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kotak Ikon putih transparan
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(56),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(item.icon, color: Colors.white, size: 22),
                        ),
                        const Spacer(),
                        if (isComingSoon)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(235),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'COMING SOON',
                              style: TextStyle(
                                fontFamily: 'Mulish',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: item.gradientColors.last,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(64),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Judul Layanan
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Deskripsi Layanan
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withAlpha(230),
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Baris Tag / Fitur Layanan
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          item.tags.map((tag) {
                            return _buildTagChip(context, item, tag);
                          }).toList(),
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

  /// Tag / Chip di dalam kartu. Tag layanan aktif bisa diklik; tag kartu
  /// Coming Soon (PSK) bersifat informasi saja.
  Widget _buildTagChip(BuildContext context, LayananItem item, String tag) {
    final Widget chipLabel = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(56),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontFamily: 'Mulish',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );

    if (item.comingSoon) return chipLabel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _onTagTap(context, item, tag),
        child: chipLabel,
      ),
    );
  }

  /// Tampilan ketika pencarian tidak menemukan hasil
  Widget _buildEmptySearchResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              'Layanan "$_searchQuery" tidak ditemukan',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba kata kunci lain seperti PJSRK, Bencana, atau Makam',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
