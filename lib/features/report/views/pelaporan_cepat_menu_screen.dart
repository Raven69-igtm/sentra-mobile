import 'package:flutter/material.dart';
import 'package:sentra/features/report/views/widgets/pelaporan_cepat/card_pjsrk.dart';
import 'package:sentra/features/report/views/widgets/pelaporan_cepat/card_pppa.dart';
import 'package:sentra/features/report/views/widgets/pelaporan_cepat/header_pelaporan_cepat.dart';

/// ============================================================================
/// HALAMAN: PelaporanCepatMenuScreen
/// ============================================================================
/// Halaman Menu Pemilihan Layanan Laporan Cepat (PJSRK & PPPA).
///
/// Struktur Halaman (Modular):
/// 1. [HeaderPelaporanCepat] : App bar, tombol back, lonceng, teks hero banner.
/// 2. [CardPjsrk]            : Kartu PJSRK dengan Accordion (Permasalahan Sosial,
///                             Rehabilitasi Sosial, dan Bencana Alam).
/// 3. [CardPppa]             : Kartu PPPA yang langsung membuka formulir laporan
///                             cepat Sentra saat ini (PppaQuickReportScreen).
///
/// *(Catatan Perubahan: Card kondisi darurat & badge 24 jam telah dihapus)*
/// ============================================================================
class PelaporanCepatMenuScreen extends StatelessWidget {
  /// Callback jika Anda ingin menghubungkan tombol "Permasalahan Sosial" ke halaman lain
  final VoidCallback? onPermasalahanSosialTap;

  /// Callback jika Anda ingin menghubungkan tombol "Rehabilitasi Sosial" ke halaman lain
  final VoidCallback? onRehabilitasiSosialTap;

  /// Callback jika Anda ingin menghubungkan tombol "Bencana Alam" ke halaman lain
  final VoidCallback? onBencanaAlamTap;

  /// Callback jika Anda ingin meng-override aksi tombol "PPPA"
  final VoidCallback? onPppaTap;

  const PelaporanCepatMenuScreen({
    super.key,
    this.onPermasalahanSosialTap,
    this.onRehabilitasiSosialTap,
    this.onBencanaAlamTap,
    this.onPppaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C7451), // Warna hijau emerald tema Sentra
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -----------------------------------------------------------------
            // 1. BAGIAN HEADER (App Bar + Hero Teks "Ada yang perlu dilaporkan?")
            // -----------------------------------------------------------------
            const HeaderPelaporanCepat(),

            const SizedBox(height: 10),

            // -----------------------------------------------------------------
            // 2. SHEET KONTEN PUTIH (Pilihan Layanan)
            // -----------------------------------------------------------------
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 20,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label Baris Judul: "Pilih layanan" & "2 layanan"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Pilih layanan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Mulish',
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              "2 layanan",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Mulish',
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // CARD 1: PJSRK (Sosial & Bencana Alam) + Accordion 3 Sub-layanan
                        CardPjsrk(
                          onPermasalahanSosialTap: onPermasalahanSosialTap,
                          onRehabilitasiSosialTap: onRehabilitasiSosialTap,
                          onBencanaAlamTap: onBencanaAlamTap,
                        ),

                        const SizedBox(height: 16),

                        // CARD 2: PPPA (Perempuan & Anak) -> Menuju Laporan Cepat Sentra
                        CardPppa(
                          onTap: onPppaTap,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
