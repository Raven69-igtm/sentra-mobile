import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ============================================================================
/// WIDGET: HeaderPelaporanCepat
/// ============================================================================
/// Bagian paling atas (Header) dengan latar belakang hijau emerald yang memuat:
/// 1. Tombol Back (<) untuk kembali ke halaman sebelumnya.
/// 2. Judul di bagian tengah ("Pelaporan Cepat").
/// 3. Tombol Lonceng / Notifikasi di sisi kanan.
/// 4. Hero Banner Teks ("LAYANAN LAPORAN CEPAT" & "Ada yang perlu dilaporkan?").
/// *(Catatan: Badge "Petugas siaga 24 jam" sudah dihapus sesuai permintaan).*
/// ============================================================================
class HeaderPelaporanCepat extends StatelessWidget {
  const HeaderPelaporanCepat({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dekorasi visual lingkaran gradien lembut di pojok kanan atas
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // Konten utama App Bar dan Teks Hero
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -----------------------------------------------------------------
            // 1. TOP APP BAR (Tombol Kembali, Judul, Tombol Notifikasi)
            // -----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Kembali (<)
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  // Judul Header
                  const Text(
                    "Pelaporan Cepat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Mulish',
                    ),
                  ),

                  // Spacer kanan pengganti ikon lonceng agar judul tetap simetris di tengah
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // 2. HERO BANNER ("Ada yang perlu dilaporkan?")
            // -----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori kecil huruf kapital
                  Text(
                    "LAYANAN LAPORAN CEPAT",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 1.1,
                      fontFamily: 'Mulish',
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Judul besar 2 baris
                  const Text(
                    "Ada yang perlu\ndilaporkan?",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      fontFamily: 'Mulish',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Deskripsi singkat
                  Text(
                    "Pilih layanan yang Anda butuhkan, tim kami siap menindaklanjuti.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.35,
                      fontFamily: 'Mulish',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

