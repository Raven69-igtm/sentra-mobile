import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/features/report/views/pppa_quick_report_screen.dart';
import 'package:sentra/features/report/views/widgets/pelaporan_cepat/tag_chip.dart';

/// ============================================================================
/// WIDGET: CardPppa
/// ============================================================================
/// Card layanan PPPA (Perempuan & Anak).
/// Sesuai instruksi: ketika diklik, card ini akan langsung membuka formulir
/// laporan cepat Sentra saat ini (PppaQuickReportScreen).
/// ============================================================================
class CardPppa extends StatelessWidget {
  /// Callback khusus jika Anda ingin meng-override aksi tap (opsional)
  final VoidCallback? onTap;

  const CardPppa({
    super.key,
    this.onTap,
  });

  /// Fungsi saat card PPPA diketuk
  void _handleTap(BuildContext context) {
    HapticFeedback.mediumImpact();

    // Jika ada callback khusus dari luar, jalankan callback tersebut
    if (onTap != null) {
      onTap!();
      return;
    }

    // Default: Buka halaman formulir Laporan Cepat PPPA Sentra saat ini
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PppaQuickReportScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Bendera (Warna Hijau PPPA)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E8B57),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.flag_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),

                // Keterangan Teks PPPA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PPPA",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Color(0xFF2E8B57),
                          fontFamily: 'Mulish',
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Perempuan & Anak",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          fontFamily: 'Mulish',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Laporan pengaduan kekerasan perempuan dan pemberdayaan anak.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.35,
                          fontFamily: 'Mulish',
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Chips: "Pengaduan Kekerasan" & "Pemberdayaan Anak"
                      const Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          TagChip(
                            label: "Pengaduan Kekerasan",
                            bgColor: Color(0xFFEBF7F0),
                            textColor: Color(0xFF2E8B57),
                          ),
                          TagChip(
                            label: "Pemberdayaan Anak",
                            bgColor: Color(0xFFEBF7F0),
                            textColor: Color(0xFF2E8B57),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tombol Bulat Panah Kanan (>) Warna Hijau Muda
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEBF7F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF2E8B57),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

