import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Segmented control: kotak putih bergeser ke pilihan aktif.
class PjsrkSegmented extends StatelessWidget {
  final List<String> options;
  final String selected;
  final void Function(String) onChanged;

  const PjsrkSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final index = options.indexOf(selected);
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth / options.length;
          return Stack(
            children: [
              // Kotak putih yang bergeser
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: w * index,
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: options.map((o) {
                  final sel = o == selected;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(o),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
                            fontFamily: 'Mulish',
                            color: sel ? PjsrkColors.primaryText : const Color(0xFF7B7F86),
                          ),
                          child: Text(o),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
