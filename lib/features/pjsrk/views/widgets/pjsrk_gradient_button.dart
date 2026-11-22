import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Tombol utama oranye bergradasi (mis. "Lanjut", "Tinjau & Kirim").
///
/// Ukuran, radius, dan feedback tekan dibuat konsisten dengan tombol
/// utama lain di layanan PJSRK.
class PjsrkGradientButton extends StatefulWidget {
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
  State<PjsrkGradientButton> createState() => _PjsrkGradientButtonState();
}

class _PjsrkGradientButtonState extends State<PjsrkGradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed && !widget.loading ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE08A45), PjsrkColors.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: PjsrkColors.primary.withAlpha(70),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.loading ? null : widget.onTap,
            onHighlightChanged: (value) {
              setState(() => _pressed = value);
            },
            splashColor: Colors.white.withAlpha(40),
            highlightColor: Colors.white.withAlpha(20),
            child: Center(
              child:
                  widget.loading
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: Colors.white,
                        ),
                      )
                      : Text(
                        widget.text,
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
