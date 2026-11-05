import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Indikator langkah: 1 Kejadian, 2 Lokasi, 3 Kirim.
/// [current] dimulai dari 1, jadi bisa dipakai ulang di halaman lain.
class PjsrkStepper extends StatelessWidget {
  final int current;
  const PjsrkStepper({super.key, this.current = 1});

  static const _labels = ['Kejadian', 'Lokasi', 'Kirim'];

  Widget _step(int n) {
    final active = n == current;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: active ? PjsrkColors.primary : const Color(0xFFE5E7EB),
          child: Text(
            '$n',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'Mulish',
              color: active ? Colors.white : const Color(0xFF7B7F86),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _labels[n - 1],
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            fontFamily: 'Mulish',
            color: active ? const Color(0xFF252525) : const Color(0xFF7B7F86),
          ),
        ),
      ],
    );
  }

  Widget _line() => Expanded(
        child: Container(
          height: 1.5,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          color: const Color(0xFFE5E7EB),
        ),
      );

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _step(1),
          _line(),
          _step(2),
          _line(),
          _step(3),
        ],
      );
}
