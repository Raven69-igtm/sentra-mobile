import 'package:flutter/material.dart';

const _orange = Color(0xFFD6762E);
const _dark = Color(0xFF2A2A2A);
const _muted = Color(0xFF7A7F85);
const _border = Color(0xFFE8EBEE);
const _chipBg = Color(0xFFFCEFE2);

/// Label section di atas field (contoh: "Kelompok usia")
class RehabLabel extends StatelessWidget {
  final String text;
  const RehabLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Mulish',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _dark,
      ),
    );
  }
}

/// Tab Tunawisma / Anak Terlantar
class RehabJenisTabs extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const RehabJenisTabs({
    super.key,
    required this.value,
    required this.onChanged,
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
        children: ['Tunawisma', 'Anak Terlantar'].map((label) {
          final selected = value == label;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
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
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _dark : _muted,
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

/// Chip pilihan (Dewasa / Lansia / dll.)
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
          onTap: () => onChanged(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? _chipBg : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? _orange : _border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _orange : _muted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}