import 'package:flutter/material.dart';

/// Kartu khusus "Lihat laporan saya" berwarna hijau mint lembut
class PjsrkReportCard extends StatelessWidget {
  final VoidCallback onTap;

  const PjsrkReportCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE5F4EB),
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFE5F4EB),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Dokumen Hijau di kiri
              const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Icon(
                    Icons.description_outlined,
                    color: Color(0xFF27845A),
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
                        color: Color(0xFF1E6B47),
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
                color: Color(0xFF27845A),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

