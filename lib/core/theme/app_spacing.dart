import 'package:flutter/material.dart';

/// Token jarak, radius, dan batas lebar responsif SENTRA (grid 4 dp).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double section = 32;

  static const double pageHorizontal = 16;
  static const double authHorizontal = 24;
  static const double maxContentWidth = 640;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  static const double minTouchTarget = 48;
  static const double buttonHeight = 52;
  static const double bottomNavHeight = 64;

  /// Bayangan khusus untuk dialog dan bottom sheet (kartu putih tanpa bayangan).
  static const List<BoxShadow> dialogShadow = [
    BoxShadow(
      color: Color(0x1F0F172A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
