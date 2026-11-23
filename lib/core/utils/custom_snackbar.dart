import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/widgets/sentra_snackbar.dart';

/// Jembatan kompatibilitas sementara untuk `CustomSnackbar`.
/// Sekarang mendelegasikan ke `SentraSnackbar` (floating Material SnackBar)
/// agar aman terhadap keyboard dan layar kecil.
@Deprecated('Gunakan SentraSnackbar di lib/core/widgets/sentra_snackbar.dart')
class CustomSnackbar {
  static void show(
    String message, {
    IconData icon = Icons.check_circle,
    String? actionText,
    Color? warna = AppColors.primary,
    VoidCallback? onAction,
    int? tinggi = 150,
  }) {
    SentraSnackbarType type = SentraSnackbarType.success;
    if (warna == Colors.red || warna == Colors.redAccent || warna == AppColors.error) {
      type = SentraSnackbarType.error;
    } else if (warna == Colors.orange || warna == AppColors.statusTerkirimFg) {
      type = SentraSnackbarType.warning;
    }

    SentraSnackbar.show(
      message,
      type: type,
      actionLabel: actionText,
      onAction: onAction,
    );
  }
}
