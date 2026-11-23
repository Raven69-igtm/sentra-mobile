import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/utils/pjsrk_photo_urls.dart';
import 'package:sentra/core/widgets/sentra_curved_header.dart';
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
  static const Color _primaryOrange = Color(0xFFA84F0F);
  static const Color _bgGrey = Colors.white;
  static const Color _textDark = AppColors.textPrimary;
  static const Color _textGrey = AppColors.textSecondary;
  static const Color _green = AppColors.primary;

  LaporanController? _controller;
  bool _ownsController = false;

  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    try {
      _controller = Provider.of<LaporanController>(context, listen: false);
    } catch (_) {
      _controller = LaporanController();
      _ownsController = true;
    }
    _loadDetail();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller?.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    try {
      final result = await _controller!.getReportDetailById(
        widget.laporan.id.toString(),
      );
      if (mounted) {
        setState(() {
          _detail = result;
          _loading = false;
        });
      }
    } catch (error) {
      debugPrint('Gagal memuat detail laporan PJSRK: $error');
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

  /// Foto lampiran PJSRK mengikuti format API: `detail_pjsrk.foto_urls`
  /// (URL absolut), dengan fallback `detail_pjsrk.foto` (nama berkas).
  /// Bila detail gagal dimuat, pakai foto yang sudah dibawa dari daftar.
  List<String> get _fotoUrls {
    final urls = PjsrkPhotoUrls.resolve(
      _detail?['detail_pjsrk'],
      idLaporan: widget.laporan.id,
    );
    if (urls.isNotEmpty) return urls;
    return widget.laporan.fotoUrls;
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
    return SentraCurvedHeader(
      gradient: AppColors.pjsrkHeaderGradient,
      backgroundAsset: 'assets/image/beranda/pjsrk.png',
      curveHeight: 26,
      padding: EdgeInsets.fromLTRB(12, top + 6, 12, 32),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Kembali',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const Text(
            'Detail Laporan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: 'Mulish',
              fontWeight: FontWeight.w800,
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
    final List<String> urls = _fotoUrls;

    if (urls.isEmpty) {
      return Row(
        children: [
          _placeholderBox(const Color(0xFFD7E4EE), const Color(0xFFB6C9D8)),
          const SizedBox(width: 8),
          _placeholderBox(const Color(0xFFC8D8C0), const Color(0xFF9DB892)),
        ],
      );
    }

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final String url = urls[i];
          return GestureDetector(
            onTap: () => _showPhoto(url),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                // File /uploads tidak membawa header CORS, sehingga fetch
                // CanvasKit gagal di Flutter web. Fallback ke elemen <img>
                // agar foto tetap tampil.
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _photoLoadingBox(),
                errorBuilder: (_, error, __) {
                  debugPrint('Gagal memuat foto PJSRK: $url ($error)');
                  return _photoErrorBox();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPhoto(String url) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _photoLoadingBox(),
                errorBuilder: (_, error, __) {
                  debugPrint('Gagal memuat foto PJSRK: $url ($error)');
                  return _photoErrorBox();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: IconButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoLoadingBox() {
    return Container(
      width: 72,
      height: 72,
      color: const Color(0xFFF2F4F6),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _primaryOrange,
        ),
      ),
    );
  }

  Widget _photoErrorBox() {
    return Container(
      width: 72,
      height: 72,
      color: const Color(0xFFFDE8EA),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 22,
        color: Color(0xFFC7283A),
      ),
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