import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Indikator langkah: 1 Kejadian, 2 Lokasi, 3 Kirim.
/// [current] = langkah yang sedang dibuka (1, 2, atau 3).
/// Langkah sebelum [current] otomatis tampil centang.
class PjsrkStepper extends StatelessWidget {
  final int current;
  const PjsrkStepper({super.key, this.current = 1});

  static const _labels = ['Kejadian', 'Lokasi', 'Kirim'];

  Widget _step(int n) {
    final done = n < current;
    final filled = n <= current;
    return Row(children: [
      CircleAvatar(
        radius: 14,
        backgroundColor: filled ? PjsrkColors.primary : PjsrkColors.graySoft,
        child: done
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text('$n',
                style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: filled ? Colors.white : PjsrkColors.muted)),
      ),
      const SizedBox(width: 8),
      Text(_labels[n - 1],
          style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: PjsrkColors.muted)),
    ]);
  }

  Widget _line(bool done) => Expanded(
        child: Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: done ? PjsrkColors.primary : PjsrkColors.graySoft,
        ),
      );

  @override
  Widget build(BuildContext context) => Row(children: [
        _step(1),
        _line(current > 1),
        _step(2),
        _line(current > 2),
        _step(3),
      ]);
}