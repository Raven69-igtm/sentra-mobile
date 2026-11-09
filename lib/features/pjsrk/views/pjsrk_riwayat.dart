import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/auth/views/profile_screen.dart';
import 'package:sentra/features/notification/views/notification_screen.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_bottom_nav.dart';
import 'package:sentra/features/report/controllers/report_controller.dart';
import 'package:sentra/features/report/models/report_model.dart';
import 'package:sentra/features/report/services/search_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_detail_laporan.dart';

/// Halaman "Laporan Saya" khusus PJSRK
/// UI mengikuti desain Figma (header oranye, filter chip, kartu laporan, FAB Lapor)
class LaporanSayaScreen extends StatefulWidget {
  const LaporanSayaScreen({super.key});

  @override
  State<LaporanSayaScreen> createState() => _LaporanSayaScreenState();
}

class _LaporanSayaScreenState extends State<LaporanSayaScreen> {
  static const Color _primaryOrange = Color(0xFFD6762E);
  static const Color _bgGrey = Color(0xFFFAFAFA);
  static const Color _textDark = Color(0xFF2A2A2A);
  static const Color _textGrey = Color(0xFF7A7F85);
  static const Color _borderGrey = Color(0xFFE8EBEE);

  final LaporanController _laporanController = Get.put(LaporanController());
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();

  String _selectedFilter = 'semua';
  bool _isSearching = false;
  Timer? _debounce;
  String _errorMessage = '';

  static const Map<String, String> _filterMap = {
    'semua': 'all',
    'diproses': 'diproses',
    'selesai': 'selesai',
    'ditolak': 'ditolak',
  };

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).idAkun;
    if (userId != null && userId > 0) {
      _laporanController.getUserReports(userId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onFilterSelected(String filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
      _errorMessage = '';
    });

    final userId = Provider.of<UserProvider>(context, listen: false).idAkun;
    if (userId == null || userId <= 0) return;

    if (filter == 'semua') {
      _laporanController.getUserReports(userId);
    } else {
      final category = _filterMap[filter] ?? filter;
      _laporanController.getUserReportsByCategory(userId, category);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      final userId = Provider.of<UserProvider>(context, listen: false).idAkun;
      if (userId == null || userId <= 0) return;

      if (query.trim().isEmpty) {
        setState(() => _isSearching = false);
        if (_selectedFilter == 'semua') {
          await _laporanController.getUserReports(userId);
        } else {
          await _laporanController.getUserReportsByCategory(
            userId,
            _filterMap[_selectedFilter] ?? _selectedFilter,
          );
        }
        return;
      }

      setState(() {
        _isSearching = true;
        _errorMessage = '';
      });

      try {
        final results =
            await _searchService.fetchSearchResults(query, userId);
        if (results != null && results.isNotEmpty) {
          _laporanController.laporanList.value = results
              .map((e) => LaporanModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _laporanController.laporanList.clear();
        }
      } catch (e) {
        setState(() => _errorMessage = 'Gagal mencari laporan');
      } finally {
        setState(() => _isSearching = false);
      }
    });
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pop();
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NotificationPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _primaryOrange,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bgGrey,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // ===== App Bar (oranye) =====
              _buildHeader(),

              // ===== Body =====
              Expanded(
                child: Obx(() {
                  final isLoading =
                      _laporanController.isLoading.value || _isSearching;

                  final List<LaporanModel> list = _selectedFilter == 'semua'
                      ? _laporanController.laporanList
                      : _laporanController.laporanByCategoryList;

                  return Stack(
                    children: [
                      Column(
                        children: [
                          // Search + Filter
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                            child: Column(
                              children: [
                                _buildSearchField(),
                                const SizedBox(height: 12),
                                _buildFilterChips(),
                              ],
                            ),
                          ),

                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 4,
                              ),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontFamily: 'Mulish',
                                  fontSize: 13,
                                ),
                              ),
                            ),

                          // List Laporan
                          Expanded(
                            child: isLoading
                                ? _buildShimmer()
                                : list.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(
                                          18,
                                          0,
                                          18,
                                          100,
                                        ),
                                        itemCount: list.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          return _buildReportCard(list[index]);
                                        },
                                      ),
                          ),
                        ],
                      ),

                      // FAB "Lapor"
                      Positioned(
                        right: 18,
                        bottom: 24,
                        child: _buildLaporButton(),
                      ),
                    ],
                  );
                }),
              ),

              // ===== Bottom Navigation =====
              PjsrkBottomNav(
                selectedIndex: 1,
                onTabSelected: _onBottomNavTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: _primaryOrange,
      child: Column(
        children: [
          SizedBox(height: topPadding),
          SizedBox(
            height: 56,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Laporan Saya',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Mulish',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------
  Widget _buildSearchField() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGrey),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: _textGrey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 13,
                color: _textDark,
                fontWeight: FontWeight.w400,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari no. tiket / judul',
                hintStyle: TextStyle(
                  color: _textGrey,
                  fontSize: 13,
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTER CHIPS
  // ---------------------------------------------------------------------------
  Widget _buildFilterChips() {
    final filters = [
      {'key': 'semua', 'label': 'Semua'},
      {'key': 'diproses', 'label': 'Diproses'},
      {'key': 'selesai', 'label': 'Selesai'},
      {'key': 'ditolak', 'label': 'Ditolak'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((item) {
          final isSelected = _selectedFilter == item['key'];
          return Padding(
            padding: EdgeInsets.only(
              right: item == filters.last ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => _onFilterSelected(item['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryOrange : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _primaryOrange : _borderGrey,
                  ),
                ),
                child: Text(
                  item['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _textGrey,
                    fontSize: 12,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REPORT CARD
  // ---------------------------------------------------------------------------
  Widget _buildReportCard(LaporanModel laporan) {
    final statusInfo = _resolveStatus(laporan.status);
    final dateStr =
        DateFormat('d MMM yyyy', 'id_ID').format(laporan.createdAt);
    final ticketId = laporan.id.toString().startsWith('SP-')
        ? laporan.id.toString()
        : 'SP-${laporan.id}';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailLaporanScreen(laporan: laporan),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F141E28),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusInfo.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusInfo.icon,
                  size: 20,
                  color: statusInfo.fgColor,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      laporan.deskripsi.isNotEmpty
                          ? laporan.deskripsi
                          : laporan.kategori,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 13,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$ticketId · $dateStr',
                      style: const TextStyle(
                        color: _textGrey,
                        fontSize: 11,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo.bgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusInfo.label,
                        style: TextStyle(
                          color: statusInfo.fgColor,
                          fontSize: 10,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF9AA0A6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATUS RESOLVER
  // ---------------------------------------------------------------------------
  _StatusVisual _resolveStatus(String raw) {
    final s = raw.toLowerCase().trim();

    if (s.contains('menunggu') ||
        s.contains('verifikasi') ||
        s == 'dikirim') {
      return const _StatusVisual(
        label: 'Menunggu verifikasi',
        bgColor: Color(0xFFFDF1D8),
        fgColor: Color(0xFFB27A0B),
        icon: Icons.warning_amber_rounded,
      );
    }
    if (s.contains('tindak') ||
        s.contains('proses') ||
        s == 'diproses' ||
        s == 'diterima') {
      return const _StatusVisual(
        label: 'Sedang ditindaklanjuti',
        bgColor: Color(0xFFE5F0FC),
        fgColor: Color(0xFF1F6FBF),
        icon: Icons.person_outline_rounded,
      );
    }
    if (s.contains('selesai') || s == 'selesai') {
      return const _StatusVisual(
        label: 'Selesai',
        bgColor: Color(0xFFE6F4EC),
        fgColor: Color(0xFF3F8F63),
        icon: Icons.check_circle_outline_rounded,
      );
    }
    if (s.contains('tolak') || s.contains('ditolak')) {
      return const _StatusVisual(
        label: 'Ditolak – di luar kewenangan',
        bgColor: Color(0xFFFDE8EA),
        fgColor: Color(0xFFC7283A),
        icon: Icons.warning_amber_rounded,
      );
    }

    return _StatusVisual(
      label: raw.isNotEmpty ? raw : 'Tidak diketahui',
      bgColor: const Color(0xFFF0F0F0),
      fgColor: const Color(0xFF7A7F85),
      icon: Icons.info_outline_rounded,
    );
  }

  // ---------------------------------------------------------------------------
  // FAB LAPOR
  // ---------------------------------------------------------------------------
  Widget _buildLaporButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Fitur Lapor sedang dikembangkan',
                style: TextStyle(fontFamily: 'Mulish'),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF2C3E50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment(-0.8, -0.6),
              end: Alignment(0.8, 1.2),
              colors: [
                Color(0xFFE48F4B),
                Color(0xFFC86921),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD6762E).withOpacity(0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Lapor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY & SHIMMER
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 56, color: Colors.grey[350]),
          const SizedBox(height: 12),
          const Text(
            'Belum ada laporan',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Laporan yang Anda buat akan muncul di sini',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
      itemCount: 5,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

class _StatusVisual {
  final String label;
  final Color bgColor;
  final Color fgColor;
  final IconData icon;

  const _StatusVisual({
    required this.label,
    required this.bgColor,
    required this.fgColor,
    required this.icon,
  });
}