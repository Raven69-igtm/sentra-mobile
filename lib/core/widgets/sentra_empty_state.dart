import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';
import 'package:sentra/core/widgets/sentra_button.dart';

/// Tampilan state kosong atau error standar SENTRA dalam Bahasa Indonesia.
class SentraEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;
  final Color? accentColor;

  const SentraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.isError = false,
    this.accentColor,
  });

  const SentraEmptyState.error({
    super.key,
    this.icon = Icons.wifi_off_rounded,
    this.title = 'Gagal Memuat Data',
    this.description =
        'Periksa sambungan internet Anda, lalu coba muat ulang halaman.',
    this.actionLabel = 'Coba Lagi',
    required this.onAction,
    this.accentColor,
  }) : isError = true;

  @override
  Widget build(BuildContext context) {
    final fg = isError ? AppColors.error : (accentColor ?? AppColors.primary);
    final bg =
        isError
            ? AppColors.errorSoft
            : (accentColor != null
                ? accentColor!.withValues(alpha: 0.12)
                : AppColors.primarySoft);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: fg),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.subtitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xl),
                SentraButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant:
                      isError
                          ? SentraButtonVariant.outlined
                          : SentraButtonVariant.primary,
                  accentColor: isError ? AppColors.error : accentColor,
                  isFullWidth: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
