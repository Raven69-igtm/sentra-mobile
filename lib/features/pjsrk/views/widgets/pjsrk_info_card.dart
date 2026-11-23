import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';

/// Banner hero utama halaman PJSRK sesuai `design_system.md`:
/// warna solid `ServicePalette.pjsrk.primary` (#A84F0F, putih 5,54:1),
/// radius 24, tanpa bayangan, chip berlatar putih solid dengan teks oranye tua.
class PjsrkInfoCard extends StatelessWidget {
  final String title;
  final String description;

  const PjsrkInfoCard({
    super.key,
    this.title = 'PJSRK',
    this.description =
        'Pilih jenis laporan sosial atau bencana yang ingin Anda sampaikan kepada Dinas Sosial Kabupaten Nganjuk.',
  });

  @override
  Widget build(BuildContext context) {
    final pjsrkColor = ServicePalette.pjsrk.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: pjsrkColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.title.copyWith(color: Colors.white),
                    ),
                    Text(
                      'Pelayanan Jaminan Sosial & Rehabilitasi',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: AppTypography.body.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _HeroTag(
                icon: Icons.home_outlined,
                label: 'Rehabilitasi',
                color: pjsrkColor,
              ),
              _HeroTag(
                icon: Icons.warning_amber_rounded,
                label: 'Bencana',
                color: pjsrkColor,
              ),
              _HeroTag(
                icon: Icons.groups_2_outlined,
                label: 'Sosial',
                color: pjsrkColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeroTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.label.copyWith(
              letterSpacing: 0.1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
