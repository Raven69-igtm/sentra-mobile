import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';

class SentraStatusStyle {
  final String label;
  final Color foreground;
  final Color background;
  final IconData icon;

  const SentraStatusStyle({
    required this.label,
    required this.foreground,
    required this.background,
    required this.icon,
  });

  /// Memetakan string status dari API/notifikasi ke gaya semantik standar.
  static SentraStatusStyle resolve(String rawStatus) {
    final normalized = rawStatus.trim().toLowerCase();
    if (normalized.contains('selesai') || normalized.contains('done')) {
      return const SentraStatusStyle(
        label: 'Selesai',
        foreground: AppColors.statusSelesaiFg,
        background: AppColors.statusSelesaiBg,
        icon: Icons.check_circle_rounded,
      );
    }
    if (normalized.contains('proses') || normalized.contains('tindak')) {
      return const SentraStatusStyle(
        label: 'Diproses',
        foreground: AppColors.statusDiprosesFg,
        background: AppColors.statusDiprosesBg,
        icon: Icons.autorenew_rounded,
      );
    }
    if (normalized.contains('terima') || normalized.contains('verif')) {
      return const SentraStatusStyle(
        label: 'Diterima',
        foreground: AppColors.statusDiterimaFg,
        background: AppColors.statusDiterimaBg,
        icon: Icons.inbox_rounded,
      );
    }
    if (normalized.contains('rujuk')) {
      return const SentraStatusStyle(
        label: 'Dirujuk',
        foreground: AppColors.info,
        background: Color(0xFFE0F2FE),
        icon: Icons.forward_to_inbox_rounded,
      );
    }
    if (normalized.contains('tolak') || normalized.contains('batal')) {
      return const SentraStatusStyle(
        label: 'Ditolak',
        foreground: AppColors.statusDitolakFg,
        background: AppColors.statusDitolakBg,
        icon: Icons.cancel_outlined,
      );
    }
    if (normalized.contains('kirim') ||
        normalized.contains('baru') ||
        normalized.contains('menunggu') ||
        normalized.contains('pending')) {
      return const SentraStatusStyle(
        label: 'Terkirim',
        foreground: AppColors.statusTerkirimFg,
        background: AppColors.statusTerkirimBg,
        icon: Icons.send_rounded,
      );
    }
    return SentraStatusStyle(
      label: rawStatus.trim().isEmpty ? 'Menunggu' : rawStatus.trim(),
      foreground: AppColors.textSecondary,
      background: AppColors.surfaceVariant,
      icon: Icons.info_outline_rounded,
    );
  }
}

/// Pill badge status laporan dengan ikon dan teks (minimal 11 sp).
class SentraStatusBadge extends StatelessWidget {
  final String status;

  const SentraStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = SentraStatusStyle.resolve(status);
    return Semantics(
      label: 'Status laporan: ${style.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, size: 14, color: style.foreground),
            const SizedBox(width: 5),
            Text(
              style.label,
              style: AppTypography.label.copyWith(
                fontSize: 11,
                letterSpacing: 0.2,
                color: style.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
