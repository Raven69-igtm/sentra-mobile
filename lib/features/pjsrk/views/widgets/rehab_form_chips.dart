import 'package:flutter/material.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_style.dart';

/// Label section di atas field (contoh: "Kelompok usia").
class RehabLabel extends StatelessWidget {
  final String text;
  const RehabLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text, style: RehabStyle.label);
}

/// Segmented tab Tunawisma / Anak Terlantar.
/// Hanya GestureDetector: tidak ada hover/ripple/MouseRegion.
class RehabJenisTabs extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const RehabJenisTabs({
    super.key,
    required this.value,
    required this.onChanged,
    this.options = const ['Tunawisma', 'Anak Terlantar'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((label) {
          final selected = value == label;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(label),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected
                      ? const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: RehabStyle.fontFamily,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? RehabStyle.dark : RehabStyle.muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Chip pilihan tunggal (Dewasa / Lansia / Sehat / Sakit / dst).
class RehabChips extends StatelessWidget {
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const RehabChips({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final selected = value == opt;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? RehabStyle.orangeSoft : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? RehabStyle.orange : RehabStyle.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontFamily: RehabStyle.fontFamily,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? RehabStyle.orange : RehabStyle.muted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
