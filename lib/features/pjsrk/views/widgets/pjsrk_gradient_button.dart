import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Tombol utama oranye bergradasi (mis. "Lanjut", "Tinjau & Kirim").
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
  Widget build(BuildContext context) => Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
              colors: [Color(0xFFE08A45), PjsrkColors.primaryDark]),
          boxShadow: const [
            BoxShadow(
                color: Color.fromRGBO(214, 118, 44, 0.35),
                blurRadius: 20,
                offset: Offset(0, 8))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: loading ? null : onTap,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 3, color: Colors.white),
                    )
                  : Text(text,
                      style: const TextStyle(
                          fontFamily: 'Mulish',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      );
}