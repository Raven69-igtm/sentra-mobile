import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';

/// ============================================================================
/// HALAMAN: PjsrkHistoryScreen
/// ============================================================================
/// Menampilkan riwayat laporan milik pengguna yang masuk melalui layanan
/// PJSRK (Rehabilitasi Sosial, Pengaduan Bencana, Permasalahan Sosial).
/// Data diambil langsung dari API SENTRA: GET /api/user-reports/{id_akun}.
/// ============================================================================
class PjsrkHistoryScreen extends StatefulWidget {
  const PjsrkHistoryScreen({super.key});

  @override
  State<PjsrkHistoryScreen> createState() => _PjsrkHistoryScreenState();
}

class _PjsrkHistoryScreenState extends State<PjsrkHistoryScreen> {
  static const Color _primaryOrange = Color(0xFFD8782E);

  late Future<List<_RiwayatPjsrk>> _futureRiwayat;

  @override
  void initState() {
    super.initState();
    _futureRiwayat = _muatRiwayat();
  }

  void _handleBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<List<_RiwayatPjsrk>> _muatRiwayat() async {
    final int? idAkun =
        Provider.of<UserProvider>(context, listen: false).idAkun;

    if (idAkun == null || idAkun <= 0) {
      throw ApiException(
        message: 'Silakan login terlebih dahulu untuk melihat riwayat laporan.',
      );
    }

    final response = await ApiClient.getRequest(
      '${Endpoints.userReports}/$idAkun',
    );

    final body = response.data;
    final daftar = body is Map ? body['laporan'] : null;

    if (daftar is! List) return const <_RiwayatPjsrk>[];

    final items = daftar
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) => (e['layanan_pjsrk'] ?? '').toString().trim().isNotEmpty)
        .map(_RiwayatPjsrk.fromJson)
        .toList();

    items.sort((a, b) {
      final aWaktu = a.dibuat;
      final bWaktu = b.dibuat;
      if (aWaktu == null && bWaktu == null) return 0;
      if (aWaktu == null) return 1;
      if (bWaktu == null) return -1;
      return bWaktu.compareTo(aWaktu);
    });

    return items;
  }

  Future<void> _muatUlang() async {
    setState(() {
      _futureRiwayat = _muatRiwayat();
    });
    await _futureRiwayat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: _primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        title: const Text(
          'Riwayat PJSRK',
          style: TextStyle(
            fontFamily: 'Mulish',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _muatUlang();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<_RiwayatPjsrk>>(
        future: _futureRiwayat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryOrange),
            );
          }

          if (snapshot.hasError) {
            return _StatusPesan(
              icon: Icons.cloud_off_rounded,
              judul: 'Riwayat gagal dimuat',
              pesan: snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Terjadi kesalahan saat menghubungi server.',
              aksiLabel: 'Coba Lagi',
              onAksi: _muatUlang,
            );
          }

          final items = snapshot.data ?? const <_RiwayatPjsrk>[];

          if (items.isEmpty) {
            return const _StatusPesan(
              icon: Icons.history_rounded,
              judul: 'Belum ada laporan PJSRK',
              pesan:
                  'Laporan yang Anda kirim lewat layanan PJSRK akan muncul di sini.',
            );
          }

          return RefreshIndicator(
            color: _primaryOrange,
            onRefresh: _muatUlang,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _KartuRiwayat(item: items[index]),
            ),
          );
        },
      ),
    );
  }
}

/// Kartu satu baris riwayat laporan PJSRK.
class _KartuRiwayat extends StatelessWidget {
  final _RiwayatPjsrk item;

  const _KartuRiwayat({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Chip(
                teks: item.statusLabel,
                warna: item.statusWarna,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.idLaporan,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.layananLabel,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                item.tanggalLabel,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
          if (item.alasanPenolakan.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Alasan: ${item.alasanPenolakan}',
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 12,
                  color: Color(0xFFB42318),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String teks;
  final Color warna;

  const _Chip({required this.teks, required this.warna});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: warna.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        teks,
        style: TextStyle(
          fontFamily: 'Mulish',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: warna,
        ),
      ),
    );
  }
}

class _StatusPesan extends StatelessWidget {
  final IconData icon;
  final String judul;
  final String pesan;
  final String? aksiLabel;
  final Future<void> Function()? onAksi;

  const _StatusPesan({
    required this.icon,
    required this.judul,
    required this.pesan,
    this.aksiLabel,
    this.onAksi,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: const Color(0xFFD8782E).withAlpha(150)),
            const SizedBox(height: 16),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF252525),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF8D9299),
              ),
            ),
            if (aksiLabel != null && onAksi != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  onAksi!();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD8782E),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  aksiLabel!,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Satu baris riwayat laporan PJSRK hasil parsing JSON API.
class _RiwayatPjsrk {
  final String idLaporan;
  final String judul;
  final String layanan;
  final String status;
  final String alasanPenolakan;
  final DateTime? dibuat;

  const _RiwayatPjsrk({
    required this.idLaporan,
    required this.judul,
    required this.layanan,
    required this.status,
    required this.alasanPenolakan,
    required this.dibuat,
  });

  factory _RiwayatPjsrk.fromJson(Map<String, dynamic> json) {
    final idLaporan = (json['id_laporan'] ?? '').toString().trim();
    final judulMentah = (json['judul'] ?? '').toString().trim();
    final layanan = (json['layanan_pjsrk'] ?? '').toString().trim();

    return _RiwayatPjsrk(
      idLaporan: idLaporan.isEmpty ? '-' : idLaporan,
      judul: judulMentah.isEmpty ? _labelLayanan(layanan) : judulMentah,
      layanan: layanan,
      status: (json['status'] ?? '').toString().trim(),
      alasanPenolakan: (json['alasan_penolakan'] ?? '').toString().trim(),
      dibuat: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  static String _labelLayanan(String kode) {
    switch (kode) {
      case 'pengaduan_bencana':
        return 'Pengaduan Bencana';
      case 'rehabilitasi_sosial':
        return 'Rehabilitasi Sosial';
      case 'permasalahan_sosial':
        return 'Permasalahan Sosial';
      default:
        return 'Layanan PJSRK';
    }
  }

  String get layananLabel => _labelLayanan(layanan);

  String get statusLabel {
    switch (status) {
      case 'dikirim':
        return 'Menunggu';
      case 'diterima':
        return 'Menunggu Verifikasi';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      case 'dirujuk':
        return 'Dirujuk';
      default:
        return status.isEmpty ? 'Menunggu' : status;
    }
  }

  Color get statusWarna {
    switch (status) {
      case 'selesai':
        return const Color(0xFF2E7D5B);
      case 'ditolak':
        return const Color(0xFFB42318);
      case 'dirujuk':
        return const Color(0xFF6C4AB6);
      case 'diproses':
        return const Color(0xFF1D6FB8);
      case 'diterima':
        return const Color(0xFFB7791F);
      default:
        return const Color(0xFF64748B);
    }
  }

  String get tanggalLabel {
    final waktu = dibuat;
    if (waktu == null) return '-';
    const namaBulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hari = waktu.day.toString().padLeft(2, '0');
    final menit = waktu.minute.toString().padLeft(2, '0');
    return '$hari ${namaBulan[waktu.month - 1]} ${waktu.year} '
        '${waktu.hour.toString().padLeft(2, '0')}:$menit WIB';
  }
}
