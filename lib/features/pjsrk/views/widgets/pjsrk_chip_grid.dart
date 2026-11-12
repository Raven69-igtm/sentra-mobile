import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Grid 3 kolom berisi chip pilihan.
/// Dipakai untuk "Jenis bencana" (pilih satu) dan "Kebutuhan" (pilih banyak);
/// bedanya hanya di [isSelected] dan [onTap] yang diberikan controller.
class PjsrkChipGrid extends StatelessWidget {
  final List<String> options;
  final bool Function(String) isSelected;
  final void Function(String) onTap;

  const PjsrkChipGrid({
    super.key,
    required this.options,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 20) / 3;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((o) {
              final sel = isSelected(o);
              return SizedBox(
                width: itemWidth,
                height: 44,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(o),
                    mouseCursor: SystemMouseCursors.click,
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: sel ? PjsrkColors.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? PjsrkColors.primary : PjsrkColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          o,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Mulish',
                            color: sel ? PjsrkColors.primaryText : const Color(0xFF252525),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      );
}
