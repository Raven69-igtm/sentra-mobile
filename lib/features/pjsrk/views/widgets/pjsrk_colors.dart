import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';

/// Warna tema form pengaduan PJSRK — dimigrasikan ke `ServicePalette.pjsrk`
/// dan `AppColors` agar selaras dengan kontras WCAG AA (5,54:1).
class PjsrkColors {
  PjsrkColors._();

  static const primary = Color(0xFFA84F0F); // ServicePalette.pjsrk.primary
  static const primaryDark = Color(0xFF8B400B);
  static const primaryLight = Color(0xFFFCEBDC); // ServicePalette.pjsrk.softTint
  static const primaryText = Color(0xFFA84F0F);
  static const bg = AppColors.background;
  static const border = AppColors.border;
  static const muted = AppColors.textMuted;
  static const graySoft = AppColors.surfaceVariant;

  // ---- dipakai form Lokasi & Kirim ----
  static const mapBg = AppColors.primarySoft;
  static const mapBorder = Color(0xFFCFE5D5);
  static const pin = AppColors.error;
  static const green = AppColors.primary;
  static const noticeBg = AppColors.statusTerkirimBg;
  static const noticeBorder = Color(0xFFF6DDB0);
  static const noticeText = AppColors.statusTerkirimFg;
}

OutlineInputBorder pjsrkOutline(Color color, double radius) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: 1.5),
    );
