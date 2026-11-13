import 'package:flutter/material.dart';
import 'package:sentra/core/utils/app_colors.dart';

/// Data layanan PPA. Sumber konten: website SENTRA
/// (/layanan/perempuan dan /layanan/anak).
class PpaService {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color iconBackground;

  const PpaService({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.iconBackground,
  });
}

const List<PpaService> ppaPerempuanServices = [
  PpaService(
    title: 'Pelatihan Keterampilan',
    description:
        'Memberikan pelatihan keterampilan bagi perempuan agar lebih mandiri dan siap bersaing di dunia kerja.',
    icon: Icons.handyman_outlined,
    accentColor: Color(0xFF2563EB),
    iconBackground: Color(0xFFEFF4FF),
  ),
  PpaService(
    title: 'Dukungan UMKM Perempuan',
    description:
        'Membantu perempuan dalam mengembangkan usaha kecil dan menengah (UMKM) untuk meningkatkan taraf hidup.',
    icon: Icons.storefront_outlined,
    accentColor: Color(0xFF16A34A),
    iconBackground: Color(0xFFEAF7EF),
  ),
  PpaService(
    title: 'Edukasi Kesehatan Perempuan',
    description:
        'Menyediakan edukasi kesehatan, termasuk kesehatan reproduksi dan pencegahan penyakit bagi perempuan.',
    icon: Icons.monitor_heart_outlined,
    accentColor: Color(0xFFDC3545),
    iconBackground: Color(0xFFFDECEE),
  ),
  PpaService(
    title: 'Perlindungan Hukum dan Konseling',
    description:
        'Memberikan bantuan hukum dan layanan konseling bagi perempuan yang mengalami kekerasan atau diskriminasi.',
    icon: Icons.gavel_rounded,
    accentColor: Color(0xFFD97706),
    iconBackground: Color(0xFFFFF4E5),
  ),
  PpaService(
    title: 'Program Kepemimpinan Perempuan',
    description:
        'Mendukung perempuan untuk berpartisipasi dalam kepemimpinan dan pengambilan keputusan di berbagai sektor.',
    icon: Icons.workspace_premium_outlined,
    accentColor: Color(0xFF0891B2),
    iconBackground: Color(0xFFE6F7FA),
  ),
];

const List<PpaService> ppaAnakServices = [
  PpaService(
    title: 'Pendampingan Anak Korban Kekerasan',
    description:
        'Memberikan perlindungan dan pendampingan bagi anak-anak yang mengalami kekerasan fisik maupun psikis.',
    icon: Icons.health_and_safety_outlined,
    accentColor: Color(0xFFDC3545),
    iconBackground: Color(0xFFFDECEE),
  ),
  PpaService(
    title: 'Edukasi Hak Anak',
    description:
        'Meningkatkan kesadaran tentang hak-hak anak melalui edukasi bagi anak-anak, orang tua, dan komunitas.',
    icon: Icons.menu_book_outlined,
    accentColor: Color(0xFF2563EB),
    iconBackground: Color(0xFFEFF4FF),
  ),
  PpaService(
    title: 'Layanan Konseling Keluarga',
    description:
        'Menyediakan konseling bagi keluarga untuk menciptakan lingkungan yang aman dan nyaman bagi anak.',
    icon: Icons.forum_outlined,
    accentColor: Color(0xFF16A34A),
    iconBackground: Color(0xFFEAF7EF),
  ),
  PpaService(
    title: 'Program Anak Berprestasi',
    description:
        'Memberikan dukungan bagi anak-anak berbakat agar berkembang dan mencapai prestasi terbaiknya.',
    icon: Icons.emoji_events_outlined,
    accentColor: Color(0xFFD97706),
    iconBackground: Color(0xFFFFF4E5),
  ),
  PpaService(
    title: 'Respon Cepat Kasus Darurat',
    description:
        'Tim kami siap merespons cepat dalam menangani kasus darurat yang membahayakan anak-anak.',
    icon: Icons.notifications_active_outlined,
    accentColor: Color(0xFF0891B2),
    iconBackground: Color(0xFFE6F7FA),
  ),
];

/// Kartu layanan PPA yang responsif (icon + judul + deskripsi).
class PpaServiceCard extends StatelessWidget {
  final PpaService service;

  const PpaServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF0F3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: service.iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(service.icon, color: service.accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.description,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header bagian layanan PPA (judul + deskripsi singkat).
class PpaSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PpaSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7ED),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Warna.backgroundIjoDark, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
