import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sentra/features/report/controllers/report_controller.dart';
import 'package:sentra/features/report/models/report_model.dart';

/// Halaman Detail Laporan PJSRK
/// Desain: header oranye, kartu info, timeline status penanganan, foto, tombol aksi
class DetailLaporanScreen extends StatefulWidget {
  final LaporanModel laporan;

  const DetailLaporanScreen({
    super.key,
    required this.laporan,
  });

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  static const Color _primaryOrange = Color(0xFFD6762E);
  static const Color _bgGrey = Color(0xFFFAFAFA);
  static const Color _textDark = Color(0xFF2A2A2A);
  static const Color _textGrey = Color(0xFF7A7F85);
  static const Color _green = Color(0xFF58A97B);
  static const Color _greenDark = Color(0xFF3F8F63);

  final LaporanController _controller = Get.put(LaporanController());

  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    try {
      final result = await _controller.getReportDetailById(
        widget.laporan.id.toString(),
      );
      if (mounted) {
        setState(() {
          _detail = result;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _detail = null;
          _loading = false;
        });
      }
    }
  }

  String get _ticketId {
    // Nomor tiket apa adanya dari server, sama seperti di admin Dinsos.
    final id = widget.laporan.id.toString().trim();
    return id.isEmpty ? '-' : id;
  }

  String get _title {
    if (widget.laporan.deskripsi.isNotEmpty) return widget.laporan.deskripsi;
    return widget.laporan.kategori.isNotEmpty
        ? widget.laporan.kategori
        : 'Laporan';
  }

  String get _location {
    // Utamakan alamat pada detail_pjsrk agar sama dengan tampilan admin.
    final pjsrk = _detail?['detail_pjsrk'];
    if (pjsrk is Map) {
      final alamat = pjsrk['alamat']?.toString().trim() ?? '';
      if (alamat.isNotEmpty) return alamat;

      final wilayah = <String>[
        pjsrk['kelurahan']?.toString().trim() ?? '',
        pjsrk['kecamatan']?.toString().trim() ?? '',
      ].where((e) => e.isNotEmpty).join(', ');
      if (wilayah.isNotEmpty) return wilayah;
    }

    final kasus = _detail?['detail_kasus'];
    if (kasus is Map) {
      final tempat = kasus['tempat_kejadian']?.toString().trim() ?? '';
      if (tempat.isNotEmpty) return tempat;
    }

    final loc = _detail?['lokasi'] ??
        _detail?['alamat'] ??
        _detail?['kecamatan'] ??
        _detail?['detail_penerima_manfaat']?['alamat'];
    if (loc is String && loc.isNotEmpty) return loc;
    return 'Lokasi belum tersedia';
  }

  /// Foto lampiran PJSRK: server sudah mengirim URL lengkap pada foto_urls.
  List<String> get _fotoUrls {
    final pjsrk = _detail?['detail_pjsrk'];
    if (pjsrk is! Map) return const [];
    final urls = pjsrk['foto_urls'];
    if (urls is! List) return const [];
    return urls
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  _StatusVisual get _statusVisual {
    final s = widget.laporan.status.toLowerCase().trim();
    if (s.contains('menunggu') || s.contains('verifikasi') || s == 'dikirim') {
      return const _StatusVisual(
        label: 'Menunggu verifikasi',
        bg: Color(0xFFFDF1D8),
        fg: Color(0xFFB27A0B),
      );
    }
    if (s.contains('tindak') ||
        s.contains('proses') ||
        s == 'diproses' ||
        s == 'diterima') {
      return const _StatusVisual(
        label: 'Sedang ditindaklanjuti',
        bg: Color(0xFFE5F0FC),
        fg: Color(0xFF1F6FBF),
      );
    }
    if (s.contains('selesai')) {
      return const _StatusVisual(
        label: 'Selesai',
        bg: Color(0xFFE6F4EC),
        fg: Color(0xFF3F8F63),
      );
    }
    if (s.contains('tolak')) {
      return const _StatusVisual(
        label: 'Ditolak – di luar kewenangan',
        bg: Color(0xFFFDE8EA),
        fg: Color(0xFFC7283A),
      );
    }
    return _StatusVisual(
      label: widget.laporan.status.isNotEmpty
          ? widget.laporan.status
          : 'Tidak diketahui',
      bg: const Color(0xFFF0F0F0),
      fg: _textGrey,
    );
  }

  List<_TimelineStep> get _timelineSteps {
    final tracking = _detail?['tracking'] ??
        _detail?['status_penanganan'] ??
        _detail?['riwayat'];

    if (tracking is List && tracking.isNotEmpty) {
      return tracking.map((e) {
        final map =
            e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
        final done = map['selesai'] == true ||
            map['done'] == true ||
            map['status'] == 'selesai' ||
            map['completed'] == true;
        return _TimelineStep(
          title: (map['judul'] ?? map['title'] ?? map['status'] ?? '-').toString(),
          subtitle: (map['keterangan'] ??
                  map['subtitle'] ??
                  map['deskripsi'] ??
                  map['waktu'] ??
                  '')
              .toString(),
          isDone: done,
        );
      }).toList();
    }

    // Fallback sesuai desain Figma
    final created = widget.laporan.createdAt;
    final fmt = DateFormat('d MMM yyyy', 'id_ID');
    final fmtTime = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

    final status = widget.laporan.status.toLowerCase();
    final isSelesai = status.contains('selesai');
    final isProses = status.contains('proses') ||
        status.contains('tindak') ||
        status == 'diterima' ||
        status == 'diproses';
    final isVerifikasi = status.contains('verifikasi') || status == 'dikirim';

    return [
      _TimelineStep(
        title: 'Laporan diterima',
        subtitle: fmtTime.format(created),
        isDone: true,
      ),
      _TimelineStep(
        title: 'Diverifikasi petugas',
        subtitle:
            '${fmt.format(created.add(const Duration(hours: 5)))}, 14:30 · Data dinyatakan valid',
        isDone: !isVerifikasi,
      ),
      _TimelineStep(
        title: 'Survei lapangan',
        subtitle:
            '${fmt.format(created.add(const Duration(days: 2)))} · Tim TAGANA mengunjungi lokasi',
        isDone: isProses || isSelesai,
      ),
      _TimelineStep(
        title: 'Pemberian bantuan',
        subtitle: isSelesai ? 'Bantuan telah diberikan' : 'Menunggu',
        isDone: isSelesai,
      ),
      _TimelineStep(
        title: 'Selesai',
        subtitle:
            isSelesai ? fmt.format(created.add(const Duration(days: 5))) : '',
        isDone: isSelesai,
      ),
    ];
  }

  void _onHubungi() {
    final phone = _detail?['no_telp_petugas'] ??
        _detail?['telepon'] ??
        _detail?['kontak'];
    final number = (phone is String && phone.isNotEmpty) ? phone : null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          number != null
              ? 'Menghubungi $number...'
              : 'Nomor kontak petugas belum tersedia',
          style: const TextStyle(fontFamily: 'Mulish'),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    );
  }

  void _onTambahInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Fitur Tambah Info sedang dikembangkan',
          style: TextStyle(fontFamily: 'Mulish'),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _primaryOrange,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bgGrey,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: _primaryOrange),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoCard(),
                            const SizedBox(height: 18),
                            const Text(
                              'Status penanganan',
                              style: TextStyle(
                                color: _textDark,
                                fontSize: 12,
                                fontFamily: 'Mulish',
                                fontWeight: FontWeight.w800,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTimeline(),
                            const SizedBox(height: 18),
                            _buildPhotoPlaceholders(),
                            const SizedBox(height: 28),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: _primaryOrange,
      child: Column(
        children: [
          SizedBox(height: top),
          SizedBox(
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Material(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Detail Laporan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final status = _statusVisual;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F141E28),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: status.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.fg,
                    fontSize: 10,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                _ticketId,
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 11,
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _title,
            style: const TextStyle(
              color: _textDark,
              fontSize: 14,
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: _textGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _location,
                  style: const TextStyle(
                    color: _textGrey,
                    fontSize: 11,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = _timelineSteps;
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        final connectorColor = step.isDone &&
                !isLast &&
                steps[index + 1].isDone
            ? _green
            : const Color(0xFFE1E5E9);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _buildDot(step.isDone),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        constraints: const BoxConstraints(minHeight: 28),
                        color: connectorColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          color: step.isDone ? _textDark : _textGrey,
                          fontSize: 12.5,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (step.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          step.subtitle,
                          style: const TextStyle(
                            color: _textGrey,
                            fontSize: 11,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDot(bool isDone) {
    if (isDone) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: _green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(width: 2, color: const Color(0xFFCBD2D8)),
      ),
    );
  }

  Widget _buildPhotoPlaceholders() {
    final urls = _fotoUrls;
    final fotos = urls.isNotEmpty
        ? urls
        : (_detail?['foto'] ?? _detail?['gambar'] ?? _detail?['images']);
    if (fotos is List && fotos.isNotEmpty) {
      return SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: fotos.length.clamp(0, 5),
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final url = fotos[i]?.toString() ?? '';
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderBox(
                  const Color(0xFFD7E4EE),
                  const Color(0xFFB6C9D8),
                ),
              ),
            );
          },
        ),
      );
    }

    return Row(
      children: [
        _placeholderBox(const Color(0xFFD7E4EE), const Color(0xFFB6C9D8)),
        const SizedBox(width: 8),
        _placeholderBox(const Color(0xFFC8D8C0), const Color(0xFF9DB892)),
      ],
    );
  }

  Widget _placeholderBox(Color c1, Color c2) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c2],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _onTambahInfo,
              icon: const Icon(Icons.mail_outline_rounded, size: 18),
              label: const Text(
                'Tambah Info',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _greenDark,
                side: const BorderSide(color: _green, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(-0.6, -0.8),
                  end: Alignment(0.8, 1.2),
                  colors: [_green, _greenDark],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _greenDark.withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _onHubungi,
                icon: const Icon(Icons.phone_rounded, size: 18),
                label: const Text(
                  'Hubungi',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusVisual {
  final String label;
  final Color bg;
  final Color fg;

  const _StatusVisual({
    required this.label,
    required this.bg,
    required this.fg,
  });
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final bool isDone;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isDone,
  });
}