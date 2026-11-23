import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';

/// Skala tipografi SENTRA berbasis font Mulish.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Mulish';

  /// 28 sp, ExtraBold (800) — Nama "SENTRA" di Welcome.
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// 20 sp, Bold (700) — Judul halaman.
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.30,
    color: AppColors.textPrimary,
  );

  /// 16 sp, Bold (700) — Judul kartu, judul seksi.
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.40,
    color: AppColors.textPrimary,
  );

  /// 14 sp, Regular (400) — Isi umum, input, chat bubble.
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.50,
    color: AppColors.textPrimary,
  );

  /// 14 sp, Bold (700) — Label tombol, judul item list.
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.40,
    color: AppColors.textPrimary,
  );

  /// 12 sp, Medium (500) — Deskripsi kartu, tanggal, helper text.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// 11 sp, Bold (700) — Badge, label navbar, label seksi kapital.
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.20,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );

  /// TextTheme untuk dipasang di ThemeData.
  static const TextTheme textTheme = TextTheme(
    displaySmall: display,
    headlineSmall: title,
    titleLarge: title,
    titleMedium: subtitle,
    titleSmall: bodyStrong,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: bodyStrong,
    labelMedium: caption,
    labelSmall: label,
  );
}
