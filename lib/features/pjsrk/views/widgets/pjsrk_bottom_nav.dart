import 'package:flutter/material.dart';

import 'pjsrk_colors.dart';

/// Bottom navigation bar khusus halaman PJSRK.
///
/// Struktur mengikuti navigasi PPA (Riwayat • Beranda • Laporan) dengan
/// aksen oranye sebagai identitas PJSRK.
class PjsrkBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const PjsrkBottomNav({
    super.key,
    this.selectedIndex = 1,
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
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Row(
            children: [
              Expanded(
                child: _PjsrkNavItem(
                  icon: Icons.history_rounded,
                  label: 'Riwayat',
                  isActive: selectedIndex == 0,
                  onTap: () => onTabSelected(0),
                ),
              ),
              Expanded(
                child: _PjsrkNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Beranda',
                  isActive: selectedIndex == 1,
                  onTap: () => onTabSelected(1),
                  isCenter: true,
                ),
              ),
              Expanded(
                child: _PjsrkNavItem(
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description_rounded,
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

class _PjsrkNavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isCenter;

  const _PjsrkNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color activeColor = PjsrkColors.primary;
    const Color inactiveColor = Color(0xFF9CA3AF);
    final IconData resolvedIcon = isActive ? (activeIcon ?? icon) : icon;

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
                    child: Icon(resolvedIcon, color: Colors.white, size: 24),
                  )
                  : SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      resolvedIcon,
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
