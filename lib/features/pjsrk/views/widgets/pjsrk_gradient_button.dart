import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/widgets/sentra_button.dart';

/// Tombol utama modul PJSRK — memakai `SentraButton.primary` dengan aksen
/// `ServicePalette.pjsrk.primary` (#A84F0F, radius 12, tinggi 52, tanpa bayangan).
class PjsrkGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool loading;

  const PjsrkGradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SentraButton.primary(
      label: text,
      isLoading: loading,
      onPressed: onTap,
      accentColor: ServicePalette.pjsrk.primary,
    );
  }
}
