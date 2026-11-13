import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ============================================================================
/// WIDGET: PjsrkTextField
/// ============================================================================
/// Input form field dengan gaya visual lengkap seperti form PPPA:
/// - Label di bagian atas dilengkapi ikon berlatar belakang kotak warna lembut.
/// - Tanda bintang merah (*) otomatis jika ada validator.
/// - Kotak input dengan sudut rounded (border radius 12) dan fill lembut.
/// - Mendukung input teks 1 baris maupun multi-baris (untuk deskripsi).
/// ============================================================================
class PjsrkTextField extends StatelessWidget {
  /// Label teks di atas form (misal: "Nama Lengkap", "Nomor Telepon")
  final String label;

  /// Placeholder di dalam input (misal: "Masukkan nama lengkap")
  final String hintText;

  /// Controller untuk mengontrol dan membaca teks input
  final TextEditingController controller;

  /// Ikon di samping label form (gaya form PPPA)
  final IconData? icon;

  /// Warna tema ikon & highlight fokus
  final Color? iconColor;

  /// Jumlah baris input (1 untuk teks biasa, 4 untuk deskripsi)
  final int maxLines;

  /// Tipe keyboard (misal: TextInputType.phone untuk nomor telepon)
  final TextInputType? keyboardType;

  /// Filter karakter yang diperbolehkan (misal: hanya angka)
  final List<TextInputFormatter>? inputFormatters;

  /// Fungsi validasi form saat tombol submit ditekan
  final String? Function(String?)? validator;

  const PjsrkTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.icon,
    this.iconColor,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? const Color(0xFF2E7D5B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Baris Label + Ikon Kotak Warna (Seperti Form PPPA) + Bintang Wajib (*)
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 15, color: effectiveColor),
                ),
                const SizedBox(width: 8),
              ],
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

        // 2. Kotak Input Form
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            fontFamily: 'Mulish',
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
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
              borderSide: BorderSide(color: effectiveColor, width: 1.8),
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
              fontSize: 11,
              fontFamily: 'Mulish',
              color: Colors.red,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
