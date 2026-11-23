import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';
import 'package:sentra/core/widgets/sentra_card.dart';

/// Kartu fitur layanan PJSRK berbasis `SentraCard` (putih, border 1px #E5E9EF,
/// radius 16, tanpa bayangan).
class PjsrkFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const PjsrkFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SentraCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      semanticLabel: '$title: $description',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.subtitle),
                const SizedBox(height: AppSpacing.xs),
                Text(description, style: AppTypography.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
            size: 22,
          ),
        ],
      ),
    );
  }
}
