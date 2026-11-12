import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ============================================================================
/// WIDGET: PppaTextField
/// ============================================================================
/// Widget Input Teks yang sudah dikustomisasi untuk formulir PPPA Sentra:
/// - Label dengan ikon dan tanda bintang (*) untuk kolom wajib.
/// - Otomatis format keyboard & filter (angka / huruf).
/// - Border elegan dengan shadow halus & highlight warna fokus.
/// ============================================================================
class PppaTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final int? maxLength;
  final String? Function(String?)? validator;
  final String? fieldType; // 'angka' atau 'huruf'

  const PppaTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.iconColor,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.hintText,
    this.maxLength,
    this.validator,
    this.fieldType,
  });

  @override
  Widget build(BuildContext context) {
    TextInputType effectiveKeyboard = keyboardType ?? TextInputType.text;
    List<TextInputFormatter> effectiveFormatters = inputFormatters ?? [];

    // Konfigurasi otomatis jika tipe field angka atau huruf
    if (fieldType != null) {
      switch (fieldType!.toLowerCase()) {
        case 'angka':
          effectiveKeyboard = TextInputType.number;
          effectiveFormatters = [
            FilteringTextInputFormatter.digitsOnly,
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ];
          break;
        case 'huruf':
          effectiveFormatters = [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ];
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris Label + Ikon Kecil + Tanda Wajib (*)
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 15, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  fontFamily: 'Mulish',
                ),
              ),
              if (validator != null)
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Text(
                    "*",
                    style: TextStyle(
                      color: Colors.red.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Input Form Lapangan
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: effectiveKeyboard,
          inputFormatters: effectiveFormatters,
          maxLength: maxLength,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Mulish',
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
              fontFamily: 'Mulish',
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 14 : 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: iconColor, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 11,
              fontFamily: 'Mulish',
            ),
            counterStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 10,
              fontFamily: 'Mulish',
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

