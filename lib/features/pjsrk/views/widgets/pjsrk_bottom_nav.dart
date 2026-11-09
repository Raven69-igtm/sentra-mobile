import 'package:flutter/material.dart';

/// Bottom Navigation Bar khusus untuk halaman PJSRK
/// Tab: Beranda, Laporan, Notifikasi, Profil
class PjsrkBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const PjsrkBottomNav({
    super.key,
    this.selectedIndex = 0,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const activeColor = Color(0xFFD8782E); // Orange untuk PJSRK
    const inactiveColor = Color(0xFF8D9299);

    final tabs = [
      (Icons.home_outlined, Icons.home_rounded, 'Beranda'),
      (Icons.description_outlined, Icons.description_rounded, 'Laporan'),
      (Icons.notifications_none_rounded, Icons.notifications_rounded, 'Notifikasi'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: bottomPadding > 0 ? bottomPadding : 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final isActive = selectedIndex == i;
          final tab = tabs[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? tab.$2 : tab.$1,
                      color: isActive ? activeColor : inactiveColor,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab.$3,
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 11,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? activeColor : inactiveColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
