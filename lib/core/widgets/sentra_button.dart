import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';

enum SentraButtonVariant {
  primary,
  outlined,
  danger,
  onGradient,
  onGradientOutlined,
}

/// Tombol standar SENTRA: tinggi 52 dp, radius 12 simetris, ripple & loading state.
class SentraButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final SentraButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? accentColor;
  final Gradient? gradient;

  const SentraButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SentraButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.accentColor,
    this.gradient,
  });

  const SentraButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.accentColor,
    this.gradient,
  }) : variant = SentraButtonVariant.primary;

  const SentraButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.accentColor,
  }) : variant = SentraButtonVariant.outlined,
       gradient = null;

  const SentraButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  }) : variant = SentraButtonVariant.danger,
       accentColor = AppColors.error,
       gradient = null;

  const SentraButton.onGradient({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  }) : variant = SentraButtonVariant.onGradient,
       accentColor = null,
       gradient = null;

  const SentraButton.onGradientOutlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  }) : variant = SentraButtonVariant.onGradientOutlined,
       accentColor = null,
       gradient = null;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final primary = accentColor ?? AppColors.primary;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    );
    final minSize = Size(
      isFullWidth ? double.infinity : 0,
      AppSpacing.buttonHeight,
    );

    Widget buildChild(Color fgColor) {
      return Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: fgColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ] else if (icon != null) ...[
            Icon(icon, size: 20, color: fgColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyStrong.copyWith(color: fgColor),
            ),
          ),
        ],
      );
    }

    switch (variant) {
      case SentraButtonVariant.primary:
        if (gradient != null) {
          return Opacity(
            opacity: effectiveOnPressed == null ? 0.55 : 1.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: ElevatedButton(
                onPressed: effectiveOnPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  minimumSize: minSize,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  shape: shape,
                ),
                child: buildChild(Colors.white),
              ),
            ),
          );
        }
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: primary.withValues(alpha: 0.45),
            disabledForegroundColor: Colors.white,
            minimumSize: minSize,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            shape: shape,
          ),
          child: buildChild(Colors.white),
        );

      case SentraButtonVariant.outlined:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            disabledForegroundColor: primary.withValues(alpha: 0.45),
            minimumSize: minSize,
            side: BorderSide(color: primary, width: 1.4),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            shape: shape,
          ),
          child: buildChild(
            effectiveOnPressed == null
                ? primary.withValues(alpha: 0.45)
                : primary,
          ),
        );

      case SentraButtonVariant.danger:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            disabledForegroundColor: AppColors.error.withValues(alpha: 0.45),
            minimumSize: minSize,
            side: const BorderSide(color: AppColors.error, width: 1.4),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            shape: shape,
          ),
          child: buildChild(
            effectiveOnPressed == null
                ? AppColors.error.withValues(alpha: 0.45)
                : AppColors.error,
          ),
        );

      case SentraButtonVariant.onGradient:
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.65),
            disabledForegroundColor: AppColors.primary,
            minimumSize: minSize,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            shape: shape,
          ),
          child: buildChild(AppColors.primary),
        );

      case SentraButtonVariant.onGradientOutlined:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
            minimumSize: minSize,
            side: const BorderSide(color: Colors.white, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            shape: shape,
          ),
          child: buildChild(Colors.white),
        );
    }
  }
}
