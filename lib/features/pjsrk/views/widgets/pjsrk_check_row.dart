import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Baris kotak centang + teks. Ketuk di mana saja untuk mencentang.
class PjsrkCheckRow extends StatelessWidget {
  final bool value;
  final String text;
  final ValueChanged<bool> onChanged;

  const PjsrkCheckRow({
    super.key,
    required this.value,
    required this.text,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? PjsrkColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                  color: value ? PjsrkColors.primary : PjsrkColors.muted,
                  width: 1.5),
            ),
            child: value
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ]),
      );
}