import 'package:flutter/material.dart';

/// Warna & gaya bersama untuk form Rehabilitasi Sosial.
class RehabStyle {
  RehabStyle._();

  static const String fontFamily = 'Mulish';

  static const Color orange = Color(0xFFD6762E);
  static const Color orangeSoft = Color(0xFFFCEFE2);
  static const Color dark = Color(0xFF2A2A2A);
  static const Color muted = Color(0xFF7A7F85);
  static const Color border = Color(0xFFE8EBEE);
  static const Color background = Color(0xFFFAFAFA);
  static const Color green = Color(0xFF3F8F63);
  static const Color red = Color(0xFFE54D5E);

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: dark,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: dark,
  );

  static const TextStyle hint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    color: muted,
  );

  /// Kotak input putih ber-border (dipakai semua field).
  static BoxDecoration inputBox({Color borderColor = border}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      );
}
