import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';
import 'package:sentra/main.dart';

enum SentraSnackbarType { success, info, warning, error }

/// Helper floating SnackBar standar Material yang aman terhadap keyboard & layar kecil.
class SentraSnackbar {
  SentraSnackbar._();

  static void show(
    String message, {
    BuildContext? context,
    SentraSnackbarType type = SentraSnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger =
        context != null
            ? ScaffoldMessenger.maybeOf(context)
            : scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    final Color bgColor;
    final IconData icon;
    switch (type) {
      case SentraSnackbarType.success:
        bgColor = AppColors.primary;
        icon = Icons.check_circle_rounded;
        break;
      case SentraSnackbarType.warning:
        bgColor = AppColors.statusTerkirimFg;
        icon = Icons.warning_amber_rounded;
        break;
      case SentraSnackbarType.error:
        bgColor = AppColors.error;
        icon = Icons.error_outline_rounded;
        break;
      case SentraSnackbarType.info:
        bgColor = AppColors.textPrimary;
        icon = Icons.info_outline_rounded;
        break;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: bgColor,
          duration: duration,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.body.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          action:
              actionLabel != null
                  ? SnackBarAction(
                    label: actionLabel,
                    textColor: Colors.white,
                    onPressed: () {
                      onAction?.call();
                    },
                  )
                  : null,
        ),
      );
  }
}
