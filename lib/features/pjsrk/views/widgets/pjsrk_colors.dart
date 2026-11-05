import 'package:flutter/material.dart';

/// Tema warna untuk form pengaduan PJSRK
class PjsrkColors {
  PjsrkColors._();

  static const primary = Color(0xFFD8782E);
  static const primaryDark = Color(0xFFC76A22);
  static const primaryLight = Color(0xFFFFF0E4);
  static const primaryText = Color(0xFFD8782E);
  static const bg = Color(0xFFF8F9FA);
  static const border = Color(0xFFE5E7EB);
  static const muted = Color(0xFF7B7F86);
  static const graySoft = Color(0xFFECEEF1);
}

OutlineInputBorder pjsrkOutline(Color color, double radius) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: 1.5),
    );
