import 'package:flutter/material.dart';

/// Warna tema form pengaduan.
/// Jika di lib/core sudah ada file warna/tema, pindahkan ke sana.
class PjsrkColors {
  PjsrkColors._();

  static const primary = Color(0xFFD6762C);
  static const primaryDark = Color(0xFFC76A22);
  static const primaryLight = Color(0xFFFCEBDC);
  static const primaryText = Color(0xFFB85A14);
  static const bg = Color(0xFFFAFAFA);
  static const border = Color(0xFFE9E9EC);
  static const muted = Color(0xFF7B7F86);
  static const graySoft = Color(0xFFECEEF1);

  // ---- baru: dipakai form Lokasi & Kirim ----
  static const mapBg = Color(0xFFDDEEE2);
  static const mapBorder = Color(0xFFCFE5D5);
  static const pin = Color(0xFFF0506E);
  static const green = Color(0xFF3B8F5F);
  static const noticeBg = Color(0xFFFEF3E0);
  static const noticeBorder = Color(0xFFF6DDB0);
  static const noticeText = Color(0xFF8A5A14);
}

OutlineInputBorder pjsrkOutline(Color color, double radius) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: 1.5),
    );