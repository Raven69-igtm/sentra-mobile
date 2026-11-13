import 'package:flutter/material.dart';

/// Label tebal di atas setiap input.
class PjsrkLabel extends StatelessWidget {
  final String text;
  const PjsrkLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Mulish',
            color: Color(0xFF252525),
          ),
        ),
      );
}

/// Label + input dalam satu kolom (dipakai untuk pasangan kiri-kanan).
class PjsrkField extends StatelessWidget {
  final String label;
  final Widget child;
  const PjsrkField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PjsrkLabel(label),
          child,
        ],
      );
}
