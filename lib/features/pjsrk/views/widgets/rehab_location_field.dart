import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentra/features/pjsrk/models/location_search_result.dart';
import 'package:sentra/features/pjsrk/services/location_search_service.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_style.dart';

enum _SearchStatus { idle, loading, success, error }

/// Field "Cari lokasi..." dengan autocomplete.
///
/// Alur: user mengetik -> debounce 500 ms -> Nominatim -> daftar hasil inline
/// -> user menekan satu hasil -> [onSelectionChanged] menerima
/// [LocationSearchResult] (address + latitude + longitude).
///
/// Catatan desain:
/// * Tidak ada GPS, permission, ataupun peta interaktif.
/// * Daftar hasil dirender inline (bukan Overlay) dan memakai GestureDetector,
///   sehingga tidak ada MouseRegion/hover/overlay yang dibuat-buang saat
///   pointer bergerak.
/// * Pilihan disimpan oleh pemilik widget ([selected]); jika user mengetik lagi
///   setelah memilih, pilihan dibatalkan (null) agar teks dan koordinat tidak
///   pernah tidak sinkron.
class RehabLocationField extends StatefulWidget {
  final TextEditingController controller;
  final LocationSearchResult? selected;
  final ValueChanged<LocationSearchResult?> onSelectionChanged;

  /// Opsional, untuk pengujian. Jika null, dibuat & di-dispose sendiri.
  final LocationSearchService? service;

  const RehabLocationField({
    super.key,
    required this.controller,
    required this.selected,
    required this.onSelectionChanged,
    this.service,
  });

  @override
  State<RehabLocationField> createState() => _RehabLocationFieldState();
}

class _RehabLocationFieldState extends State<RehabLocationField> {
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  late final LocationSearchService _service;
  late final bool _ownsService;

  Timer? _debounce;
  int _requestId = 0; // untuk membuang respons lama (out-of-order)
  _SearchStatus _status = _SearchStatus.idle;
  List<LocationSearchResult> _results = const [];

  @override
  void initState() {
    super.initState();
    _ownsService = widget.service == null;
    _service = widget.service ?? LocationSearchService();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_ownsService) _service.dispose();
    super.dispose();
  }

  /// Hanya dipanggil untuk ketikan user (bukan saat controller.text diubah
  /// lewat kode), jadi memilih hasil tidak memicu pencarian baru.
  void _onChanged(String text) {
    if (widget.selected != null) widget.onSelectionChanged(null);

    _debounce?.cancel();
    _requestId++;

    final query = text.trim();
    if (query.length < LocationSearchService.minQueryLength) {
      setState(() {
        _status = _SearchStatus.idle;
        _results = const [];
      });
      return;
    }

    setState(() => _status = _SearchStatus.loading);
    _debounce = Timer(_debounceDuration, () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    final id = ++_requestId;
    try {
      final results = await _service.search(query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _status = _SearchStatus.success;
      });
    } on LocationSearchException {
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = const [];
        _status = _SearchStatus.error;
      });
    }
  }

  void _select(LocationSearchResult result) {
    _debounce?.cancel();
    _requestId++; // batalkan request yang mungkin masih berjalan

    widget.controller.text = result.displayName;
    widget.controller.selection =
        TextSelection.collapsed(offset: result.displayName.length);

    setState(() {
      _status = _SearchStatus.idle;
      _results = const [];
    });
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSelectionChanged(result);
  }

  void _clear() {
    _debounce?.cancel();
    _requestId++;
    widget.controller.clear();
    setState(() {
      _status = _SearchStatus.idle;
      _results = const [];
    });
    widget.onSelectionChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final panel = _buildPanel();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInput(selected),
        if (panel != null) ...[const SizedBox(height: 6), panel],
        const SizedBox(height: 10),
        _LocationPreview(address: selected?.displayName),
      ],
    );
  }

  Widget _buildInput(LocationSearchResult? selected) {
    final isSelected = selected != null;

    Widget? trailing;
    if (_status == _SearchStatus.loading) {
      trailing = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: RehabStyle.orange,
        ),
      );
    } else if (isSelected || _status != _SearchStatus.idle) {
      trailing = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _clear,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.close_rounded, size: 18, color: RehabStyle.muted),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: RehabStyle.inputBox(
        borderColor: isSelected ? RehabStyle.orange : RehabStyle.border,
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.place_rounded : Icons.search_rounded,
            size: 20,
            color: isSelected ? RehabStyle.orange : RehabStyle.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: _onChanged,
              maxLines: 1,
              textInputAction: TextInputAction.search,
              // Beri ruang agar daftar hasil tetap terlihat saat keyboard muncul.
              scrollPadding: const EdgeInsets.only(bottom: 320),
              style: RehabStyle.body,
              decoration: const InputDecoration(
                hintText: 'Cari lokasi...',
                hintStyle: RehabStyle.hint,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing],
        ],
      ),
    );
  }

  Widget? _buildPanel() {
    switch (_status) {
      case _SearchStatus.idle:
      case _SearchStatus.loading:
        return null;
      case _SearchStatus.error:
        return _buildMessage(
          icon: Icons.error_outline_rounded,
          color: RehabStyle.red,
          text: 'Gagal mencari lokasi',
        );
      case _SearchStatus.success:
        if (_results.isEmpty) {
          return _buildMessage(
            icon: Icons.location_off_outlined,
            color: RehabStyle.muted,
            text: 'Tidak ditemukan lokasi',
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RehabStyle.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < _results.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: RehabStyle.border),
                _ResultRow(
                  result: _results[i],
                  onTap: () => _select(_results[i]),
                ),
              ],
            ],
          ),
        );
    }
  }

  Widget _buildMessage({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: RehabStyle.inputBox(),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: RehabStyle.fontFamily,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final LocationSearchResult result;
  final VoidCallback onTap;

  const _ResultRow({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.place_outlined,
                  size: 18, color: RehabStyle.orange),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: RehabStyle.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: RehabStyle.dark,
                    ),
                  ),
                  if (result.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        result.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: RehabStyle.fontFamily,
                          fontSize: 12,
                          height: 1.3,
                          color: RehabStyle.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// AREA VISUAL LOKASI (statis, bukan peta interaktif)
// ------------------------------------------------------------
class _LocationPreview extends StatelessWidget {
  final String? address;
  const _LocationPreview({required this.address});

  @override
  Widget build(BuildContext context) {
    final hasAddress = address != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _MapPatternPainter()),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 40,
                  color: hasAddress
                      ? RehabStyle.red
                      : RehabStyle.muted.withAlpha(150),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  address ?? 'Pilih lokasi dari hasil pencarian',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: RehabStyle.fontFamily,
                    fontSize: 12,
                    fontWeight: hasAddress ? FontWeight.w600 : FontWeight.w400,
                    color: hasAddress ? RehabStyle.dark : RehabStyle.muted,
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

/// Pola jalan sederhana agar area terlihat seperti peta (murni dekorasi).
class _MapPatternPainter extends CustomPainter {
  const _MapPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8EEE3),
    );

    final block = Paint()..color = const Color(0xFFD9E5D0);
    for (final r in <Rect>[
      Rect.fromLTWH(w * 0.05, h * 0.10, w * 0.22, h * 0.32),
      Rect.fromLTWH(w * 0.62, h * 0.08, w * 0.30, h * 0.26),
      Rect.fromLTWH(w * 0.55, h * 0.62, w * 0.20, h * 0.26),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(8)), block);
    }

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final lane = Paint()
      ..color = const Color(0xFFF7F3EA)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, h * 0.55), Offset(w, h * 0.45), road);
    canvas.drawLine(Offset(w * 0.36, 0), Offset(w * 0.46, h), road);
    canvas.drawLine(Offset(0, h * 0.20), Offset(w * 0.36, h * 0.52), lane);
    canvas.drawLine(Offset(w * 0.46, h * 0.50), Offset(w, h * 0.85), lane);
    canvas.drawLine(Offset(w * 0.80, 0), Offset(w * 0.86, h * 0.46), lane);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
