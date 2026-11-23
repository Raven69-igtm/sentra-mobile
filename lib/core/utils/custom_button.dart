import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';

/// Jembatan kompatibilitas sementara untuk tombol legacy.
/// Sudah diperbarui ke radius 12 simetris, tinggi 52 dp, dan ripple bawaan Material.
@Deprecated('Gunakan SentraButton di lib/core/widgets/sentra_button.dart')
class CustomRoundedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final double horizontalMargin;
  final bool isFullWidth;
  final double iconSize;
  final bool isLoading;

  const CustomRoundedButton({
    super.key,
    required this.text,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.horizontalMargin = 20,
    this.isFullWidth = true,
    this.iconSize = 20,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.45),
          disabledForegroundColor: textColor,
          elevation: 0,
          minimumSize: Size(
            isFullWidth ? double.infinity : 0,
            AppSpacing.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ] else if (icon != null) ...[
              Icon(icon, color: textColor, size: iconSize),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              text,
              style: AppTypography.bodyStrong.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
