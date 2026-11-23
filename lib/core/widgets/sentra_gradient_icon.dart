import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';

/// Ikon dengan warna gradient brand SENTRA (#52AE77 -> #5270AD)
/// untuk tampilan utama aplikasi (non-layanan).
class SentraGradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient gradient;

  const SentraGradientIcon(
    this.icon, {
    super.key,
    this.size = 22,
    this.gradient = AppColors.headerCurvedGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

/// Teks dengan warna gradient brand SENTRA (#52AE77 -> #5270AD).
class SentraGradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextOverflow? overflow;
  final Gradient gradient;

  const SentraGradientText(
    this.text, {
    super.key,
    required this.style,
    this.maxLines,
    this.overflow,
    this.gradient = AppColors.headerCurvedGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
