import 'package:flutter/material.dart';

/// ============================================================================
/// WIDGET: TagChip
/// ============================================================================
/// Widget badge / label kecil berbentuk kapsul rounded yang digunakan di dalam
/// card untuk menampilkan tag/kategori (misal: "Bencana", "Pengaduan Kekerasan").
/// ============================================================================
class TagChip extends StatelessWidget {
  /// Teks yang akan ditampilkan di dalam badge
  final String label;

  /// Warna latar belakang badge (biasanya warna pastel/muda)
  final Color bgColor;

  /// Warna teks di dalam badge
  final Color textColor;

  const TagChip({
    super.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Mulish',
        ),
      ),
    );
  }
}

