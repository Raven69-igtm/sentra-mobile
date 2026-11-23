import 'package:flutter/material.dart';

/// Palet identitas per layanan SENTRA (PPPA, PJSRK, PSK).
class ServicePalette {
  final Color primary;
  final Color softTint;

  const ServicePalette({
    required this.primary,
    required this.softTint,
  });

  /// PPPA / SENTRA — Hijau tua (#1F5C42), putih di atasnya 7,87:1.
  static const ServicePalette pppa = ServicePalette(
    primary: Color(0xFF1F5C42),
    softTint: Color(0xFFE8F1EC),
  );

  /// PJSRK — Oranye tua (#A84F0F), putih di atasnya 5,54:1.
  static const ServicePalette pjsrk = ServicePalette(
    primary: Color(0xFFA84F0F),
    softTint: Color(0xFFFCEBDC),
  );

  /// PSK — Indigo (#4856A6), putih di atasnya 6,65:1.
  static const ServicePalette psk = ServicePalette(
    primary: Color(0xFF4856A6),
    softTint: Color(0xFFEEF0FA),
  );
}

/// Token warna terpusat SENTRA (Light Mode, terverifikasi WCAG 2.x).
class AppColors {
  AppColors._();

  // ---- Brand & Surface ----
  static const Color primary = Color(0xFF1F5C42);
  static const Color primarySoft = Color(0xFFE8F1EC);
  static const Color background = Color(0xFFF6F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F4F2);
  static const Color border = Color(0xFFE5E9EF);

  // ---- Typography ----
  static const Color textPrimary = Color(0xFF16231D);
  static const Color textSecondary = Color(0xFF4F5F57);
  static const Color textMuted = Color(0xFF5F6E67);

  // ---- Gradasi Asli Splash Screen & Curved Header ----
  static const Color splashGradientStart = Color(0xFF52AE77);
  static const Color splashGradientEnd = Color(0xFF5270AD);

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [splashGradientStart, splashGradientEnd],
  );

  static const LinearGradient headerCurvedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [splashGradientStart, splashGradientEnd],
  );

  /// Gradient Curved Header khusus modul PJSRK (Opsi B — warna per layanan, WCAG AA).
  static const LinearGradient pjsrkHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC4621D), Color(0xFFA84F0F)],
  );

  /// Gradient Curved Header khusus modul PPPA (Opsi B — warna per layanan, WCAG AA).
  static const LinearGradient pppaHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2B7A57), Color(0xFF1F5C42)],
  );

  // ---- Gradasi Brand (alternatif kontras tinggi) ----
  static const Color brandGradientTop = Color(0xFF277F55);
  static const Color brandGradientMid = Color(0xFF1F6F6B);
  static const Color brandGradientBottom = Color(0xFF2F4C8C);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandGradientTop, brandGradientMid, brandGradientBottom],
    stops: [0.0, 0.5, 1.0],
  );

  // ---- Semantic & Status Laporan ----
  static const Color statusTerkirimFg = Color(0xFFB45309);
  static const Color statusTerkirimBg = Color(0xFFFEF3C7);

  static const Color statusDiterimaFg = Color(0xFF1D4ED8);
  static const Color statusDiterimaBg = Color(0xFFDBEAFE);

  static const Color statusDiprosesFg = Color(0xFFC2410C);
  static const Color statusDiprosesBg = Color(0xFFFFEDD5);

  static const Color statusSelesaiFg = Color(0xFF15803D);
  static const Color statusSelesaiBg = Color(0xFFDCFCE7);

  static const Color statusDitolakFg = Color(0xFFB42318);
  static const Color statusDitolakBg = Color(0xFFFEE2E2);

  // ---- Feedback / Utility ----
  static const Color error = statusDitolakFg;
  static const Color errorSoft = statusDitolakBg;
  static const Color success = statusSelesaiFg;
  static const Color successSoft = statusSelesaiBg;
  static const Color warning = statusTerkirimFg;
  static const Color warningSoft = statusTerkirimBg;
  static const Color info = statusDiterimaFg;
  static const Color infoSoft = statusDiterimaBg;

  static const Color unreadNotificationBg = Color(0xFFF0FAF4);
  static const Color dateSeparatorBg = Color(0xFFE2E8F0);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
}
