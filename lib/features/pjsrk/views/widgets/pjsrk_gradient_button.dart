import 'package:flutter/material.dart';

/// Tombol utama oranye bergradasi (mis. "Lanjut").
class PjsrkGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const PjsrkGradientButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFE28236), Color(0xFFD8782E)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD8782E).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Mulish',
                ),
              ),
            ),
          ),
        ),
      );
}
