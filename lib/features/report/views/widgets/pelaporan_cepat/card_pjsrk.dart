import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/features/report/views/pjsrk/form_bencana_alam_screen.dart';
import 'package:sentra/features/report/views/pjsrk/form_permasalahan_sosial_screen.dart';
import 'package:sentra/features/report/views/pjsrk/form_rehabilitasi_sosial_screen.dart';
import 'package:sentra/features/report/views/widgets/pelaporan_cepat/tag_chip.dart';

/// ============================================================================
/// WIDGET: CardPjsrk
/// ============================================================================
/// Card layanan PJSRK (Sosial & Bencana Alam) dengan fitur Accordion interaktif.
///
/// Fitur Utama:
/// 1. Tampilan Header Card dengan ikon hati oranye, judul, deskripsi, dan tag chip.
/// 2. Tombol Accordion bulat yang bisa dibuka/tutup dengan animasi rotasi panah.
/// 3. Ketika dibuka, menampilkan 3 sub-layanan:
///    - Permasalahan Sosial  -> FormPermasalahanSosialScreen
///    - Rehabilitasi Sosial  -> FormRehabilitasiSosialScreen
///    - Bencana Alam         -> FormBencanaAlamScreen
/// 4. Masing-masing tombol sub-layanan langsung membuka file halaman formulirnya
///    sendiri-sendiri secara terpisah.
/// ============================================================================
class CardPjsrk extends StatefulWidget {
  /// Callback opsional jika ingin meng-override navigasi tombol "Permasalahan Sosial"
  final VoidCallback? onPermasalahanSosialTap;

  /// Callback opsional jika ingin meng-override navigasi tombol "Rehabilitasi Sosial"
  final VoidCallback? onRehabilitasiSosialTap;

  /// Callback opsional jika ingin meng-override navigasi tombol "Bencana Alam"
  final VoidCallback? onBencanaAlamTap;

  /// Status awal accordion (default: true / terbuka sesuai desain referensi)
  final bool initialExpanded;

  const CardPjsrk({
    super.key,
    this.onPermasalahanSosialTap,
    this.onRehabilitasiSosialTap,
    this.onBencanaAlamTap,
    this.initialExpanded = true,
  });

  @override
  State<CardPjsrk> createState() => _CardPjsrkState();
}

class _CardPjsrkState extends State<CardPjsrk> {
  /// Variabel status apakah accordion sedang terbuka (true) atau tertutup (false)
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  /// Fungsi untuk membuka / menutup accordion dengan getaran halus (HapticFeedback)
  void _toggleAccordion() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  /// Navigasi ke Form Permasalahan Sosial
  void _openPermasalahanSosial() {
    HapticFeedback.mediumImpact();
    if (widget.onPermasalahanSosialTap != null) {
      widget.onPermasalahanSosialTap!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormPermasalahanSosialScreen(),
      ),
    );
  }

  /// Navigasi ke Form Rehabilitasi Sosial
  void _openRehabilitasiSosial() {
    HapticFeedback.mediumImpact();
    if (widget.onRehabilitasiSosialTap != null) {
      widget.onRehabilitasiSosialTap!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormRehabilitasiSosialScreen(),
      ),
    );
  }

  /// Navigasi ke Form Bencana Alam
  void _openBencanaAlam() {
    HapticFeedback.mediumImpact();
    if (widget.onBencanaAlamTap != null) {
      widget.onBencanaAlamTap!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormBencanaAlamScreen(),
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
      child: Column(
        children: [
          // -------------------------------------------------------------------
          // 1. BAGIAN HEADER CARD PJSRK (Dapat diklik untuk toggle accordion)
          // -------------------------------------------------------------------
          InkWell(
            onTap: _toggleAccordion,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Hati / Peduli (Warna Oranye)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDE7434),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Keterangan teks PJSRK
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PJSRK",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFF8D4F28),
                            fontFamily: 'Mulish',
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Sosial & Bencana Alam",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            fontFamily: 'Mulish',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Buat laporan cepat meliputi permasalahan sosial dan bencana alam.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.35,
                            fontFamily: 'Mulish',
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Chips: "Bencana" & "Permasalahan Sosial"
                        const Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            TagChip(
                              label: "Bencana",
                              bgColor: Color(0xFFFDF0E6),
                              textColor: Color(0xFFD36829),
                            ),
                            TagChip(
                              label: "Permasalahan Sosial",
                              bgColor: Color(0xFFFDF0E6),
                              textColor: Color(0xFFD36829),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tombol Bulat Accordion dengan Animasi Rotasi Panah
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDE7434),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedRotation(
                      turns: _isExpanded ? 0.0 : 0.5,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // 2. BAGIAN ACCORDION (Muncul saat terbuka / expanded)
          // -------------------------------------------------------------------
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // Garis pembatas teks: "— LAPORKAN TENTANG —"
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade200,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "LAPORKAN TENTANG",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Colors.grey.shade500,
                              fontFamily: 'Mulish',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade200,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Sub-tombol 1: Permasalahan Sosial
                  _buildSubCategoryButton(
                    title: "Permasalahan Sosial",
                    subtitle: "Gepeng, ODGJ, lansia terlantar, dll.",
                    icon: Icons.groups_outlined,
                    gradientColors: const [
                      Color(0xFFE58742),
                      Color(0xFFD46927),
                    ],
                    onTap: _openPermasalahanSosial,
                  ),

                  const SizedBox(height: 10),

                  // Sub-tombol 2: Rehabilitasi Sosial
                  _buildSubCategoryButton(
                    title: "Rehabilitasi Sosial",
                    subtitle: "Tunawisma dan Anak Terlantar",
                    icon: Icons.accessibility_new_rounded,
                    gradientColors: const [
                      Color(0xFFDF7434),
                      Color(0xFFCA5D1F),
                    ],
                    onTap: _openRehabilitasiSosial,
                  ),

                  const SizedBox(height: 10),

                  // Sub-tombol 3: Bencana Alam
                  _buildSubCategoryButton(
                    title: "Bencana Alam",
                    subtitle: "Banjir, longsor, kebakaran, gempa.",
                    icon: Icons.tsunami_rounded,
                    gradientColors: const [
                      Color(0xFFD7583F),
                      Color(0xFFBD4229),
                    ],
                    onTap: _openBencanaAlam,
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  /// Helper untuk membangun tombol gradien sub-kategori
  Widget _buildSubCategoryButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Icon Box Kiri
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),

                // Teks Judul & Deskripsi Singkat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Mulish',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontFamily: 'Mulish',
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol Panah Kanan Bulat (>)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.28),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 20,
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
