import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/widgets/sentra_bottom_nav.dart';

/// Bottom navigation bar halaman Laporan Saya — memakai `SentraBottomNav`.
class LaporanSayaBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const LaporanSayaBottomNav({
    super.key,
    this.selectedIndex = 1,
    required this.onTabSelected,
  });

  static const List<SentraNavItem> _items = [
    SentraNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Beranda',
    ),
    SentraNavItem(
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
      label: 'Laporan',
    ),
    SentraNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SentraBottomNav(
      currentIndex: selectedIndex,
      onTap: onTabSelected,
      items: _items,
      activeColor: AppColors.primary,
      activeBgColor: AppColors.primarySoft,
    );
  }
}
