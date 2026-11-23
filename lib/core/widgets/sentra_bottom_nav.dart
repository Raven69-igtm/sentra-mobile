import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';
import 'package:sentra/core/widgets/sentra_gradient_icon.dart';

/// Item untuk `SentraBottomNav`.
class SentraNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const SentraNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// Navbar bawah SENTRA dengan gaya Floating Bottom Navbar (default 2 item:
/// Beranda & Profil) atau docked untuk sub-modul.
/// Saat [useBrandGradient] true, ikon aktif, label aktif, dan efek hover/pill
/// memakai gradient brand SENTRA (#52AE77 -> #5270AD).
class SentraBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<SentraNavItem> items;
  final Color activeColor;
  final Color activeBgColor;
  final bool floating;
  final bool useBrandGradient;

  static const List<SentraNavItem> defaultItems = [
    SentraNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Beranda',
    ),
    SentraNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  const SentraBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = defaultItems,
    this.activeColor = AppColors.primary,
    this.activeBgColor = AppColors.primarySoft,
    this.floating = true,
    this.useBrandGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isActive = index == currentIndex;
        return Expanded(
          child: _NavButton(
            item: item,
            isActive: isActive,
            activeColor: activeColor,
            activeBgColor: activeBgColor,
            useBrandGradient: useBrandGradient,
            onTap: () {
              if (!isActive) {
                HapticFeedback.lightImpact();
              }
              onTap(index);
            },
          ),
        );
      }),
    );

    if (!floating) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(height: AppSpacing.bottomNavHeight, child: row),
        ),
      );
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomMargin = bottomInset > 0 ? bottomInset + 4.0 : 10.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomMargin),
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: items.length <= 2 ? 300 : 480,
          ),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A0F172A),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              clipBehavior: Clip.antiAlias,
              child: row,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final SentraNavItem item;
  final bool isActive;
  final Color activeColor;
  final Color activeBgColor;
  final bool useBrandGradient;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.activeColor,
    required this.activeBgColor,
    required this.useBrandGradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool useGrad = useBrandGradient;
    final IconData iconData =
        isActive ? (item.activeIcon ?? item.icon) : item.icon;

    final Widget iconWidget =
        useGrad && isActive
            ? SentraGradientIcon(iconData, size: 24)
            : Icon(
              iconData,
              size: 24,
              color: isActive ? activeColor : AppColors.textSecondary,
            );

    final TextStyle labelStyle = AppTypography.label.copyWith(
      letterSpacing: 0.1,
      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
      color: isActive ? activeColor : AppColors.textSecondary,
    );

    final Widget labelWidget =
        useGrad && isActive
            ? SentraGradientText(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            )
            : Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            );

    return Semantics(
      button: true,
      selected: isActive,
      label: '${item.label}${isActive ? ', aktif' : ''}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppSpacing.minTouchTarget,
            minHeight: AppSpacing.minTouchTarget,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(height: 4),
              labelWidget,
            ],
          ),
        ),
      ),
    );
  }
}
