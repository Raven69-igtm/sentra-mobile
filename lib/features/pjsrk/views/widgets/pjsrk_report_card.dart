import 'package:flutter/material.dart';

/// Kartu khusus "Lihat laporan saya" untuk PJSRK dengan tema oren
class PjsrkReportCard extends StatelessWidget {
  final VoidCallback onTap;

  const PjsrkReportCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF3E0), // Light orange background
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Dokumen Oren di kiri
              const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Icon(
                    Icons.description_outlined,
                    color: Color(0xFFD8782E), // Orange untuk PJSRK
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Teks Tengah
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat laporan saya',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBF6919), // Dark orange
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Pantau status semua pengaduan Anda',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Chevron Right di kanan
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFD8782E), // Orange untuk PJSRK
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

