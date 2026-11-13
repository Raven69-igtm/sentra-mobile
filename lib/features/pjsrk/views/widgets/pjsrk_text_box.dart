import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pjsrk_colors.dart';

/// Kotak isian teks satu baris.
/// [icon] opsional, [highlight] = bingkai oranye (seperti kotak alamat).
class PjsrkTextBox extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final bool highlight;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const PjsrkTextBox({
    super.key,
    required this.controller,
    this.hint,
    this.icon,
    this.highlight = false,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    onTap: onTap,
    style: const TextStyle(
      fontFamily: 'Mulish',
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Mulish',
        color: PjsrkColors.muted,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: EdgeInsets.only(
        left: icon == null ? 16 : 0,
        right: 16,
        top: 15,
        bottom: 15,
      ),
      prefixIcon:
          icon == null
              ? null
              : Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(icon, size: 22, color: PjsrkColors.muted),
              ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      enabledBorder: pjsrkOutline(
        highlight ? PjsrkColors.primary : PjsrkColors.border,
        14,
      ),
      focusedBorder: pjsrkOutline(PjsrkColors.primary, 14),
    ),
  );
}
