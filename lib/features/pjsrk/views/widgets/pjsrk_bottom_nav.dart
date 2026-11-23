import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/widgets/sentra_bottom_nav.dart';

/// Bottom navigation bar modul PJSRK — memakai komponen tunggal `SentraBottomNav`
/// dengan aksen warna `ServicePalette.pjsrk`.
class PjsrkBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const PjsrkBottomNav({
    super.key,
    this.selectedIndex = 1,
    required this.onTabSelected,
  });

  static const List<SentraNavItem> _items = [
    SentraNavItem(
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
      label: 'Riwayat',
    ),
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
  ];

  @override
  Widget build(BuildContext context) {
    return SentraBottomNav(
      currentIndex: selectedIndex,
      onTap: onTabSelected,
      items: _items,
      activeColor: ServicePalette.pjsrk.primary,
      activeBgColor: ServicePalette.pjsrk.softTint,
    );
  }
}
