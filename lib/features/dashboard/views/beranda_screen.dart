import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/auth/views/login_screen.dart';
import 'package:sentra/features/notification/views/notification_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_screen.dart';
import 'package:sentra/features/report/views/report_screen.dart';

/// Model data untuk Menu Layanan
class LayananItem {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final List<Color> gradientColors;
  final IconData icon;
  final IconData? decorativeIcon;

  const LayananItem({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.gradientColors,
    required this.icon,
    this.decorativeIcon,
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
    ),
    LayananItem(
      id: 'psk',
      title: 'PSK',
      description: 'Makam pahlawan & jadwal kegiatan mendatang',
      tags: ['Makam Pahlawan', 'Jadwal Kegiatan'],
      gradientColors: [Color(0xFF5B6BBF), Color(0xFF4856A6)],
      icon: Icons.outlined_flag_rounded,
      decorativeIcon: Icons.explore_outlined,
    ),
    LayananItem(
      id: 'pppa',
      title: 'PPPA',
      description:
          'Layanan Dinas Sosial Perlindungan Perempuan & Pemberdayaan Anak',
      tags: ['Pengaduan Kekerasan', 'Pemberdayaan Anak'],
      gradientColors: [Color(0xFF48B167), Color(0xFF389753)],
      icon: Icons.outlined_flag_rounded,
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
  // 🔗 NAVIGASI & AKSI INTERAKTIF (SAMBUNGKAN KE HALAMAN ANDA DI SINI)
  // ===========================================================================

  /// Aksi ketika kartu layanan ditekan
  void _onLayananTap(BuildContext context, LayananItem item) {
    switch (item.id) {
      case 'pjsrk':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PjsrkScreen()),
        );
        break;

      case 'psk':
        // =====================================================================
        // 👉 2. SAMBUNGKAN KE HALAMAN PSK:
        // Contoh:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanPSK()));
        // =====================================================================
        _showInteractiveBottomSheet(context, item, null);
        break;

      case 'pppa':
        // Formulir pengaduan Sentra existing (LaporanPage) — bukan placeholder.
        _bukaFormPengaduanPppa(context);
        break;

      default:
        _showInteractiveBottomSheet(context, item, null);
    }
  }

  /// Aksi ketika salah satu tag/fitur di dalam kartu ditekan
  void _onTagTap(BuildContext context, LayananItem item, String tag) {
    // =========================================================================
    // 👉 SAMBUNGKAN LANGSUNG KE SUB-FITUR SESUAI TAG:
    // Contoh:
    // if (tag == 'Pengaduan Kekerasan') {
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => FormPengaduanScreen()));
    // } else if (tag == 'Makam Pahlawan') {
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => MakamPahlawanScreen()));
    // }
    // =========================================================================
    if (item.id == 'pjsrk') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PjsrkScreen()),
      );
      return;
    }

    if (item.id == 'pppa') {
      if (tag == 'Pengaduan Kekerasan') {
        // Tag utama PPPA membuka formulir pengaduan Sentra yang sama
        // dengan navigasi kartu PPPA.
        _bukaFormPengaduanPppa(context);
      } else {
        // Tag lain (mis. "Pemberdayaan Anak") tetap memakai placeholder
        // existing sampai flow resminya tersedia.
        _showInteractiveBottomSheet(context, item, tag);
      }
      return;
    }

    _showInteractiveBottomSheet(context, item, tag);
  }

  /// Membuka formulir pengaduan Sentra (`LaporanPage`) untuk layanan PPPA.
  /// Pengguna wajib login terlebih dahulu karena backend mewajibkan
  /// `id_akun` (required|exists) pada POST /api/post-report.
  void _bukaFormPengaduanPppa(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.idAkun == null) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: const Color(0xFF389753)),
                const SizedBox(width: 10),
                const Text(
                  "Perlu Login",
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Untuk mengirim pengaduan, Anda perlu masuk menggunakan akun terlebih dahulu.",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 14,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  "Nanti",
                  style: TextStyle(
                    fontFamily: "Mulish",
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.login, size: 18),
                label: const Text(
                  "Login",
                  style: TextStyle(fontFamily: "Mulish"),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF389753),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LaporanPage(openedFromPpa: true)),
    );
  }

  /// Menampilkan bottom sheet interaktif sebagai placeholder interaktif
  void _showInteractiveBottomSheet(
    BuildContext context,
    LayananItem item,
    String? specificTag,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: item.gradientColors),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (specificTag != null)
                          Text(
                            'Fitur: $specificTag',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: item.gradientColors.first,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item.description,
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Fitur / Layanan yang tersedia:',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    item.tags.map((tag) {
                      final isSelected = tag == specificTag;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? item.gradientColors.first
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected
                                    ? item.gradientColors.first
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.gradientColors.first,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    // 👉 Panggil navigasi halaman tujuan di sini
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Membuka layanan ${item.title}${specificTag != null ? " ($specificTag)" : ""}...',
                        ),
                        backgroundColor: item.gradientColors.first,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'Buka Halaman Layanan',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil nama pengguna dari UserProvider atau gunakan fallback 'Rafi'
    final userProvider = Provider.of<UserProvider>(context);
    final String userName = userProvider.user?.nama ?? 'Rafi';

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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ===================================================================
          // 1. TOP APP BAR / HEADER (HIJAU SESUAI DESAIN)
          // ===================================================================
          _buildTopHeader(context),

          // ===================================================================
          // 2. KONTEN BERANDA (SCROLLABLE)
          // ===================================================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                // Beri ruang untuk CurvedNavigationBar di bagian bawah
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
                      Text(
                        userName,
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
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
                        padding: const EdgeInsets.only(bottom: 16),
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

  /// Header bagian atas dengan warna hijau khas dan lonceng notifikasi
  Widget _buildTopHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: statusBarHeight + 10,
        bottom: 14,
        left: 20,
        right: 18,
      ),
      decoration: const BoxDecoration(
        color: Warna.backgroundIjo,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Spacer penyeimbang di kiri agar teks judul berada tepat di tengah
          const SizedBox(width: 40),

          // Judul Header
          const Expanded(
            child: Text(
              'Dinas Sosial dan PPA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),

          // Lonceng Notifikasi di kanan atas
          Material(
            color: Colors.white.withAlpha(51), // 20% opacity
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // 👉 Arahkan ke Halaman Notifikasi
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NotificationPage()),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7EBD2), width: 1),
      ),
      child: const Text(
        'Akun terverifikasi',
        style: TextStyle(
          fontFamily: 'Mulish',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E8540),
        ),
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

  /// Kartu Layanan Besar (PJSRK, PSK, PPPA)
  Widget _buildServiceCard(BuildContext context, LayananItem item) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
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
                color: item.gradientColors.first.withAlpha(76),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Lingkaran dekoratif kanan bawah (efek kurva figma)
              Positioned(
                right: -30,
                bottom: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(20),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -60,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(13),
                  ),
                ),
              ),

              // Ikon aksen tengah (misal lambang target/kompas pada kartu PSK)
              if (item.decorativeIcon != null)
                Positioned(
                  right: 120,
                  top: 40,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(46),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item.decorativeIcon,
                      color: Colors.white.withAlpha(230),
                      size: 20,
                    ),
                  ),
                ),

              // Konten Utama Kartu
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Atas: Ikon di kiri, tombol panah di kanan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kotak Ikon
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(56),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.icon,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),

                        // Tombol Panah Bulat
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(64),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 22,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Deskripsi Layanan
                    Text(
                      item.description,
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withAlpha(230),
                        height: 1.3,
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

  /// Tag / Chip di dalam kartu (Interaktif & bisa diklik per tag)
  Widget _buildTagChip(BuildContext context, LayananItem item, String tag) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _onTagTap(context, item, tag),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(64),
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
        ),
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
