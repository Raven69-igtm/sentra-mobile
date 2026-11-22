import 'package:flutter/material.dart';

import 'pjsrk_colors.dart';

/// Banner hero utama halaman PJSRK.
///
/// Menjadi pengantar visual halaman sekaligus menampilkan identitas
/// layanan PJSRK dengan aksen oranye yang konsisten.
class PjsrkInfoCard extends StatelessWidget {
  final String title;
  final String description;

  const PjsrkInfoCard({
    super.key,
    this.title = 'PJSRK',
    this.description =
        'Pilih jenis laporan yang ingin Anda sampaikan. Petugas akan menindaklanjuti dalam 2 hari kerja.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE78A3F),
            PjsrkColors.primary,
            PjsrkColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: PjsrkColors.primary.withAlpha(70),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(right: -42, top: -52, child: _decorCircle(150, 0x24)),
          Positioned(right: 36, bottom: -72, child: _decorCircle(164, 0x18)),
          Positioned(
            right: -6,
            bottom: -16,
            child: Icon(
              Icons.volunteer_activism_rounded,
              size: 124,
              color: Colors.white.withAlpha(22),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(42),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(60)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'LAYANAN TERPADU',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Pelayanan Jaminan Sosial & Rehabilitasi Kesejahteraan',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xF2FFFFFF),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xEEFFFFFF),
                  ),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroTag(icon: Icons.home_outlined, label: 'Rehabilitasi'),
                    _HeroTag(
                      icon: Icons.warning_amber_rounded,
                      label: 'Bencana',
                    ),
                    _HeroTag(icon: Icons.groups_2_outlined, label: 'Sosial'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, int alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(alpha),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(36),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(56)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
