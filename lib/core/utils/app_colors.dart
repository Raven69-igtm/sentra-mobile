import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';

/// Jembatan migrasi sementara menuju `AppColors` di `lib/core/theme/app_colors.dart`.
///
/// Jadwal penghapusan: setelah seluruh modul selesai dimigrasikan pada Fase 5.
@Deprecated('Gunakan AppColors atau ServicePalette di lib/core/theme/app_colors.dart')
class Warna {
  static const Color backgroundIjo = AppColors.primary;
  static const Color backgroundBiru = AppColors.brandGradientBottom;
  static const Color backgroundijotuek = AppColors.primary;
  static const Color backgroundIjoDark = Color(0xFF184934);

  // Perbaikan bug lama: opacity valid adalah 0.0..1.0 (sebelumnya 100).
  static const Color btngetstart = Color.fromRGBO(245, 250, 247, 1.0);
  static const Color btnquickaccess = Color.fromRGBO(254, 249, 238, 1.0);
  static const Color textcoklat = Color.fromRGBO(152, 105, 12, 1.0);

  static const Color birunom = AppColors.statusDiterimaFg;
  static const Color kuningtuek = AppColors.statusTerkirimFg;
  static const Color oren = Color(0xFFA84F0F);

  static const Color font = AppColors.textSecondary;

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
