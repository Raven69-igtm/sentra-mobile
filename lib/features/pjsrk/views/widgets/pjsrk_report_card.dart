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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5F4EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          splashColor: const Color(0xFF27845A).withAlpha(35),
          highlightColor: const Color(0xFF27845A).withAlpha(15),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Dokumen Hijau di kiri
                SizedBox(
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
                SizedBox(width: 10),

                // Teks Tengah
                Expanded(
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
                SizedBox(width: 8),

                // Chevron Right di kanan
                Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF27845A),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
