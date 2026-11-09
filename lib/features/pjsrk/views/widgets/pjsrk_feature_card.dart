import 'package:flutter/material.dart';

/// Kartu Fitur individual untuk layanan PJSRK
class PjsrkFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const PjsrkFeatureCard(required String title, {
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // ~4% opacity shadow
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          splashColor: iconColor.withAlpha(30),
          highlightColor: iconColor.withAlpha(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Container Ikon di sebelah kiri
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Bagian Teks (Judul dan Deskripsi)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF252525),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 12,
                          height: 1.35,
                          color: Color(0xFF8D9299),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Icon Chevron Right di sebelah kanan
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF252525),
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
