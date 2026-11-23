import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Jenis ilustrasi latar kartu layanan di Beranda.
enum LayananCardArt { pjsrk, psk, pppa }

/// Ilustrasi vektor halus di sisi kanan kartu layanan.
///
/// Dipakai sebagai pengganti foto background agar kartu tidak terlihat kosong,
/// tetap ringan (tanpa aset gambar), dan aman dari masalah lisensi.
class LayananBackgroundPainter extends CustomPainter {
  final LayananCardArt art;

  const LayananBackgroundPainter({required this.art});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cahaya lembut di kanan untuk memberi kedalaman tanpa mengganggu teks.
    final glowCenter = Offset(w * 0.88, h * 0.58);
    final glowRadius = w * 0.65;
    canvas.drawCircle(
      glowCenter,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withAlpha(42),
            Colors.white.withAlpha(0),
          ],
        ).createShader(
          Rect.fromCircle(center: glowCenter, radius: glowRadius),
        ),
    );

    final softFill = Paint()..color = Colors.white.withAlpha(22);
    final mediumFill = Paint()..color = Colors.white.withAlpha(34);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withAlpha(62);

    switch (art) {
      case LayananCardArt.pjsrk:
        _drawPjsrk(canvas, w, h, softFill, mediumFill, outline);
      case LayananCardArt.psk:
        _drawPsk(canvas, w, h, softFill, mediumFill, outline);
      case LayananCardArt.pppa:
        _drawPppa(canvas, w, h, softFill, mediumFill, outline);
    }

    // Titik-titik kecil sebagai tekstur.
    final dotPaint = Paint()..color = Colors.white.withAlpha(46);
    final dots = <(double, double, double)>[
      (0.62, 0.18, 2.2),
      (0.72, 0.30, 1.6),
      (0.94, 0.20, 2.6),
      (0.98, 0.44, 1.8),
      (0.66, 0.78, 2.0),
      (0.90, 0.86, 1.5),
    ];
    for (final dot in dots) {
      canvas.drawCircle(
        Offset(w * dot.$1, h * dot.$2),
        dot.$3,
        dotPaint,
      );
    }
  }

  /// PJSRK: hati peduli + rumah perlindungan + dua tangan yang saling助力.
  void _drawPjsrk(
    Canvas canvas,
    double w,
    double h,
    Paint soft,
    Paint medium,
    Paint outline,
  ) {
    final cx = w * 0.84;

    _drawHeart(
      canvas,
      Offset(cx, h * 0.34),
      w * 0.105,
      soft,
    );
    canvas.drawPath(
      _heartPath(Offset(cx, h * 0.34), w * 0.105),
      outline,
    );

    // Atap rumah.
    final roof = Path()
      ..moveTo(cx - w * 0.115, h * 0.60)
      ..lineTo(cx, h * 0.49)
      ..lineTo(cx + w * 0.115, h * 0.60)
      ..close();
    canvas.drawPath(roof, medium);

    // Badan rumah.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx - w * 0.085,
          h * 0.60,
          w * 0.17,
          h * 0.17,
        ),
        const Radius.circular(6),
      ),
      soft,
    );

    // Dua lengkung tangan yang saling mendukung.
    final hands = Path()
      ..moveTo(cx - w * 0.20, h * 0.84)
      ..quadraticBezierTo(cx - w * 0.06, h * 0.72, cx, h * 0.82)
      ..quadraticBezierTo(cx + w * 0.06, h * 0.72, cx + w * 0.20, h * 0.84);
    canvas.drawPath(hands, outline..strokeWidth = 2.6);
  }

  /// PSK: tugu pahlawan, bintang, dan sinar cahaya.
  void _drawPsk(
    Canvas canvas,
    double w,
    double h,
    Paint soft,
    Paint medium,
    Paint outline,
  ) {
    final cx = w * 0.85;
    final topY = h * 0.30;
    final baseY = h * 0.80;

    // Alas tugu.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - w * 0.13, baseY, w * 0.26, h * 0.075),
        const Radius.circular(4),
      ),
      medium,
    );

    // Tiang tugu yang meruncing ke atas.
    final tower = Path()
      ..moveTo(cx - w * 0.055, baseY)
      ..lineTo(cx - w * 0.020, topY)
      ..lineTo(cx + w * 0.020, topY)
      ..lineTo(cx + w * 0.055, baseY)
      ..close();
    canvas.drawPath(tower, soft);
    canvas.drawPath(tower, outline);

    // Bintang di atas tugu.
    _drawStar(canvas, Offset(cx, h * 0.24), w * 0.040, medium);

    // Sinar lembut.
    for (final angle in <double>[0.0, 0.6, 1.2, 1.8, 2.4, 3.0]) {
      final rad = angle + 0.3;
      canvas.drawLine(
        Offset(
          cx + math.cos(rad) * w * 0.055,
          h * 0.24 + math.sin(rad) * w * 0.055,
        ),
        Offset(
          cx + math.cos(rad) * w * 0.085,
          h * 0.24 + math.sin(rad) * w * 0.085,
        ),
        outline..strokeWidth = 1.6,
      );
    }
  }

  /// PPPA: perisai perlindungan + figur perempuan & anak + daun.
  void _drawPppa(
    Canvas canvas,
    double w,
    double h,
    Paint soft,
    Paint medium,
    Paint outline,
  ) {
    final cx = w * 0.84;
    final cy = h * 0.53;
    final s = w * 0.15;

    final shield = Path()
      ..moveTo(cx, cy - s)
      ..lineTo(cx + s * 0.82, cy - s * 0.58)
      ..lineTo(cx + s * 0.76, cy + s * 0.28)
      ..quadraticBezierTo(cx + s * 0.58, cy + s * 0.82, cx, cy + s)
      ..quadraticBezierTo(cx - s * 0.58, cy + s * 0.82, cx - s * 0.76, cy + s * 0.28)
      ..lineTo(cx - s * 0.82, cy - s * 0.58)
      ..close();
    canvas.drawPath(shield, soft);
    canvas.drawPath(shield, outline);

    // Ibu dan anak di dalam perisai.
    canvas.drawCircle(Offset(cx - s * 0.22, cy - s * 0.24), s * 0.15, medium);
    canvas.drawCircle(Offset(cx + s * 0.26, cy - s * 0.02), s * 0.11, medium);

    final bodies = Path()
      ..moveTo(cx - s * 0.48, cy + s * 0.48)
      ..quadraticBezierTo(cx - s * 0.46, cy + s * 0.06, cx - s * 0.22, cy + s * 0.02)
      ..quadraticBezierTo(cx + s * 0.02, cy + s * 0.06, cx + s * 0.04, cy + s * 0.48)
      ..moveTo(cx + s * 0.10, cy + s * 0.48)
      ..quadraticBezierTo(cx + s * 0.12, cy + s * 0.22, cx + s * 0.26, cy + s * 0.20)
      ..quadraticBezierTo(cx + s * 0.40, cy + s * 0.22, cx + s * 0.42, cy + s * 0.48);
    canvas.drawPath(bodies, outline..strokeWidth = 2.2);

    // Daun perlindungan di bawah perisai.
    canvas.save();
    canvas.translate(cx - s * 0.55, cy + s * 0.95);
    canvas.rotate(-0.5);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s * 0.70, height: s * 0.30), medium);
    canvas.restore();

    canvas.save();
    canvas.translate(cx + s * 0.55, cy + s * 0.95);
    canvas.rotate(0.5);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s * 0.70, height: s * 0.30), medium);
    canvas.restore();
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawPath(_heartPath(center, size), paint);
  }

  Path _heartPath(Offset center, double size) {
    return Path()
      ..moveTo(center.dx, center.dy + size * 0.62)
      ..cubicTo(
        center.dx - size * 1.30,
        center.dy - size * 0.20,
        center.dx - size * 0.62,
        center.dy - size * 1.20,
        center.dx,
        center.dy - size * 0.48,
      )
      ..cubicTo(
        center.dx + size * 0.62,
        center.dy - size * 1.20,
        center.dx + size * 1.30,
        center.dy - size * 0.20,
        center.dx,
        center.dy + size * 0.62,
      )
      ..close();
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? r : r * 0.44;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LayananBackgroundPainter oldDelegate) =>
      oldDelegate.art != art;
}
