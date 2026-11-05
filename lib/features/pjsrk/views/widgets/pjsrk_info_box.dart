import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Kotak tampilan yang bisa diketuk (dipakai untuk tanggal dan jam).
class PjsrkInfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool active;
  final VoidCallback onTap;

  const PjsrkInfoBox({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? PjsrkColors.primary : PjsrkColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF7B7F86)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Mulish',
                      color: Color(0xFF252525),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
