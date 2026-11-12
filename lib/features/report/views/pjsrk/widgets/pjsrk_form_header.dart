import 'package:flutter/material.dart';

/// ============================================================================
/// WIDGET: PjsrkFormHeader
/// ============================================================================
/// Header formulir laporan cepat sesuai mockup:
/// - Judul: "Form Laporan Cepat" (tengah, tebal)
/// - Subtitle: Nama kategori layanan (Permasalahan Sosial / Bencana Alam / Rehabilitasi Sosial)
/// - Tombol Tutup (X) di pojok kanan atas
/// ============================================================================
class PjsrkFormHeader extends StatelessWidget {
  final String subtitle;
  final VoidCallback onClose;

  const PjsrkFormHeader({
    super.key,
    required this.subtitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Teks Judul dan Subtitle di Tengah
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Form Laporan Cepat",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Mulish',
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Mulish',
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),

          // Tombol Tutup (X) di Pojok Kanan
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

