import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/features/auth/views/profile_screen.dart';
import 'package:sentra/features/notification/views/notification_screen.dart';
import 'package:sentra/features/report/views/report_screen.dart';
import 'package:sentra/features/chat/views/room_chat_screen.dart';

/// Halaman Menu PPPA (Perlindungan Perempuan & Pemberdayaan Anak)
/// Struktur mengikuti design Overview dengan tracking laporan PPPA
class PppaScreen extends StatefulWidget {
  const PppaScreen({super.key});

  @override
  State<PppaScreen> createState() => _PppaScreenState();
}

class _PppaScreenState extends State<PppaScreen> {
  static const Color _primaryGreen = Color(0xFF2D9F6B);
  static const Color _lightGreen = Color(0xFFD4F4E4);
  static const Color _backgroundColor = Color(0xFFF5F5F5);

  int _selectedTab = 2; // Center tab (grid) adalah default (Overview)

  void _onTabSelected(int index) {
    if (index == _selectedTab) return;
    
    // Handle navigation
    if (index == 0) {
      // History - stay on current page
      setState(() => _selectedTab = index);
    } else if (index == 1) {
      // Laporan
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LaporanPage()),
      );
    } else if (index == 2) {
      // Overview (center) - current page
      setState(() => _selectedTab = index);
    } else if (index == 3) {
      // Notification
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationPage()),
      );
    } else if (index == 4) {
      // Profile
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: _PppaOverviewContent(
          primaryGreen: _primaryGreen,
          lightGreen: _lightGreen,
        ),
        bottomNavigationBar: _PppaBottomNav(
          selectedIndex: _selectedTab,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Overview Content PPPA - Mengikuti struktur design
// ─────────────────────────────────────────────────────────────
class _PppaOverviewContent extends StatefulWidget {
  final Color primaryGreen;
  final Color lightGreen;

  const _PppaOverviewContent({
    required this.primaryGreen,
    required this.lightGreen,
  });

  @override
  State<_PppaOverviewContent> createState() => _PppaOverviewContentState();
}

class _PppaOverviewContentState extends State<_PppaOverviewContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan icon
              _buildHeader(),
              
              const SizedBox(height: 16),
              
              // Date badge dan judul Overview
              _buildTitleSection(),
              
              const SizedBox(height: 8),
              
              // Subtitle
              const Text(
                'Tracking Laporan',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Card Tracking Laporan PPPA
              _buildTrackingCard(),
              
              const SizedBox(height: 20),
              
              // Section Informasi
              const Text(
                'Informasi',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Card Statistik Laporan PPPA
              _buildStatistikCard(),
              
              const SizedBox(height: 12),
              
              // Card Informasi
              _buildInformasiCard(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Icon PPPA
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.shield_outlined,
            color: widget.primaryGreen,
            size: 24,
          ),
        ),
        
        const Spacer(),
        
        // Button Room Chat
        GestureDetector(
          onTap: () {
            // Navigate ke Room Chat PPPA
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoomChat()),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.forum_outlined,
              color: widget.primaryGreen,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Row(
      children: [
        // Date badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny_outlined, size: 14, color: widget.primaryGreen),
              const SizedBox(width: 4),
              Text(
                _getCurrentDate(),
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Judul Overview
        const Expanded(
          child: Text(
            'Overview',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        
        // Button All data
        GestureDetector(
          onTap: () {
            // Filter all data
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menampilkan semua data'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_list, size: 14, color: Color(0xFF6366F1)),
                SizedBox(width: 4),
                Text(
                  'All data',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final days = ['SUN', 'MON', 'TUES', 'WED', 'THU', 'FRI', 'SAT'];
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${days[now.weekday % 7]} ${now.day} ${months[now.month - 1]}';
  }

  Widget _buildTrackingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.lightGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Teks
              const Expanded(
                child: Text(
                  'Masukan ID unik Laporan',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Icon send
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.primaryGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Search box
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 13,
                      color: Color(0xFF1F2937),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(6),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusIndicator('Dikirim', const Color(0xFF3B82F6), true),
              _buildStatusIndicator('Diterima', const Color(0xFFFBBF24), false),
              _buildStatusIndicator('Diproses', const Color(0xFFF97316), false),
              _buildStatusIndicator('Selesai', const Color(0xFF8B5CF6), false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, Color color, bool isFilled) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isFilled ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Mulish',
            fontSize: 10,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistikCard() {
    return GestureDetector(
      onTap: () {
        // Navigate ke halaman statistik detail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menampilkan statistik laporan kekerasan'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Text(
              'Statistik Laporan',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Kekerasan',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Nganjuk',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformasiCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Informasi',
          style: TextStyle(
            fontFamily: 'Mulish',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom Nav PPPA - 5 tabs dengan center button hijau
// ─────────────────────────────────────────────────────────────
class _PppaBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _PppaBottomNav({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const primaryGreen = Color(0xFF2D9F6B);
    const inactiveColor = Color(0xFF9CA3AF);

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
        top: 12,
        bottom: bottomPadding > 0 ? bottomPadding : 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavIcon(
            icon: Icons.history_rounded,
            isActive: selectedIndex == 0,
            onTap: () => onTabSelected(0),
            color: inactiveColor,
            activeColor: primaryGreen,
          ),
          _buildNavIcon(
            icon: Icons.description_outlined,
            isActive: selectedIndex == 1,
            onTap: () => onTabSelected(1),
            color: inactiveColor,
            activeColor: primaryGreen,
          ),
          _buildCenterButton(
            isActive: selectedIndex == 2,
            onTap: () => onTabSelected(2),
            color: primaryGreen,
          ),
          _buildNavIcon(
            icon: Icons.notifications_outlined,
            isActive: selectedIndex == 3,
            onTap: () => onTabSelected(3),
            color: inactiveColor,
            activeColor: primaryGreen,
          ),
          _buildNavIcon(
            icon: Icons.person_outline_rounded,
            isActive: selectedIndex == 4,
            onTap: () => onTabSelected(4),
            color: inactiveColor,
            activeColor: primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color color,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isActive ? activeColor : color,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildCenterButton({
    required bool isActive,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.apps_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
