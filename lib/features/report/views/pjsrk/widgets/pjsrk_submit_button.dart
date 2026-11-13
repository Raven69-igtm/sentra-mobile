import 'package:flutter/material.dart';

/// ============================================================================
/// WIDGET: PjsrkSubmitButton
/// ============================================================================
/// Tombol submit berbentuk rounded hijau sesuai dengan mockup:
/// - Background hijau lembut / gradien khas Sentra (#38A169 / #2E7D5B).
/// - Teks "Submit" putih tebal.
/// - Menampilkan loading spinner ketika formulir sedang dikirim.
/// ============================================================================
class PjsrkSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const PjsrkSubmitButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF38A169), // Warna hijau sesuai gambar mockup
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38A169).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Mulish',
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

