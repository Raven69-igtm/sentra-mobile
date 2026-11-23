import 'package:flutter/material.dart';
import 'package:sentra/features/report/controllers/report_controller.dart';

import 'pjsrk_colors.dart';

/// Kartu pelacakan status laporan PJSRK.
///
/// Memakai ulang [LaporanController.trackingReport] yang sudah ada sehingga
/// alur, endpoint, dan data tetap sama. Tampilan dibuat lebih modern dengan
/// input yang rapi, tombol pencarian menonjol, serta ringkasan progres status.
class PjsrkTrackingCard extends StatefulWidget {
  const PjsrkTrackingCard({super.key});

  @override
  State<PjsrkTrackingCard> createState() => _PjsrkTrackingCardState();
}

class _PjsrkTrackingCardState extends State<PjsrkTrackingCard> {
  final LaporanController _controller = LaporanController();
  final TextEditingController _idController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSearching = false;
  String _status = '';
  String _error = '';

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final String kode = _idController.text.trim();
    if (kode.isEmpty) {
      _showMessage('Masukkan ID laporan terlebih dahulu');
      return;
    }

    _focusNode.unfocus();
    setState(() {
      _isSearching = true;
      _error = '';
    });

    _controller.clearTrackingState();

    try {
      await _controller.trackingReport(kode);
      if (!mounted) return;

      final String status = _controller.trackingStatus.trim();
      if (status.isNotEmpty) {
        setState(() {
          _status = status;
          _error = '';
        });
        return;
      }

      final String message = _controller.errorMessage.trim();
      final String error =
          message.isNotEmpty
              ? message
              : 'Laporan tidak ditemukan. Periksa kembali ID laporan Anda.';
      setState(() {
        _status = '';
        _error = error;
      });
      _showMessage(error, isError: true);
    } catch (_) {
      if (!mounted) return;
      const String error = 'Gagal melacak laporan. Silakan coba lagi.';
      setState(() {
        _status = '';
        _error = error;
      });
      _showMessage(error, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _clear() {
    _idController.clear();
    _focusNode.unfocus();
    setState(() {
      _status = '';
      _error = '';
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? const Color(0xFFB42318) : PjsrkColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final _StatusInfo info = _resolveStatus(_status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF0F3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: PjsrkColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: PjsrkColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lacak Status Laporan',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Masukkan ID laporan untuk melihat perkembangan terbaru.',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _idController,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              if (!_isSearching) _search();
            },
            onChanged: (_) {
              setState(() {
                _status = '';
                _error = '';
              });
            },
            cursorColor: PjsrkColors.primary,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              hintText: 'Masukkan ID Laporan',
              hintStyle: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
              prefixIcon: const Icon(
                Icons.confirmation_number_outlined,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
              suffixIcon:
                  _idController.text.isNotEmpty
                      ? IconButton(
                        tooltip: 'Bersihkan',
                        onPressed: _clear,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 19,
                        ),
                      )
                      : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE9E9EC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: PjsrkColors.primary,
                  width: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE08A45), PjsrkColors.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: PjsrkColors.primary.withAlpha(70),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _isSearching ? null : _search,
                  mouseCursor: SystemMouseCursors.click,
                  splashColor: Colors.white.withAlpha(40),
                  highlightColor: Colors.white.withAlpha(20),
                  child: Center(
                    child:
                        _isSearching
                            ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Mencari laporan...',
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                            : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Lacak Laporan',
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF6C9C9)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: Color(0xFFB42318),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFFB42318),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child:
                _status.isEmpty
                    ? const SizedBox.shrink(key: ValueKey('empty-status'))
                    : Padding(
                      key: ValueKey('status-$_status'),
                      padding: const EdgeInsets.only(top: 14),
                      child: _buildStatusResult(info),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusResult(_StatusInfo info) {
    final String? note = _statusNote(_status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: info.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: info.color.withAlpha(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: info.color.withAlpha(24),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(info.icon, size: 18, color: info.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status laporan',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      info.label,
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: info.color,
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(190),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _idController.text.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: info.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _TrackingProgress(activeStep: info.step, color: info.color),
          if (note != null) ...[
            const SizedBox(height: 12),
            Text(
              note,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 11.5,
                height: 1.4,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _statusNote(String status) {
    switch (status.toLowerCase()) {
      case 'dirujuk':
        return 'Laporan Anda telah diteruskan ke instansi terkait untuk ditindaklanjuti.';
      case 'ditolak':
        return 'Laporan Anda belum dapat diproses. Silakan periksa detail laporan pada riwayat.';
      default:
        return null;
    }
  }

  _StatusInfo _resolveStatus(String status) {
    switch (status.toLowerCase()) {
      case 'dikirim':
        return const _StatusInfo(
          label: 'Dikirim',
          color: Color(0xFFD97706),
          background: Color(0xFFFFF7E6),
          icon: Icons.send_rounded,
          step: 0,
        );
      case 'diterima':
        return const _StatusInfo(
          label: 'Diterima',
          color: Color(0xFF2563EB),
          background: Color(0xFFEFF4FF),
          icon: Icons.fact_check_outlined,
          step: 1,
        );
      case 'diproses':
        return const _StatusInfo(
          label: 'Diproses',
          color: PjsrkColors.primary,
          background: PjsrkColors.primaryLight,
          icon: Icons.autorenew_rounded,
          step: 2,
        );
      case 'selesai':
        return const _StatusInfo(
          label: 'Selesai',
          color: Color(0xFF2E7D5B),
          background: Color(0xFFE6F4EC),
          icon: Icons.check_circle_outline_rounded,
          step: 3,
        );
      case 'dirujuk':
        return const _StatusInfo(
          label: 'Dirujuk',
          color: Color(0xFF6C4AB6),
          background: Color(0xFFF1EDFA),
          icon: Icons.forward_to_inbox_rounded,
          step: 2,
        );
      case 'ditolak':
        return const _StatusInfo(
          label: 'Ditolak',
          color: Color(0xFFB42318),
          background: Color(0xFFFDECEC),
          icon: Icons.cancel_outlined,
          step: 2,
        );
      default:
        return _StatusInfo(
          label: status.isEmpty ? 'Tidak diketahui' : status,
          color: const Color(0xFF6B7280),
          background: const Color(0xFFF3F4F6),
          icon: Icons.info_outline_rounded,
          step: 0,
        );
    }
  }
}

class _TrackingProgress extends StatelessWidget {
  final int activeStep;
  final Color color;

  const _TrackingProgress({required this.activeStep, required this.color});

  static const List<String> _labels = [
    'Dikirim',
    'Diterima',
    'Diproses',
    'Selesai',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(_labels.length * 2 - 1, (index) {
            if (index.isOdd) {
              final int leftStep = (index - 1) ~/ 2;
              final bool isFilled = leftStep < activeStep;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isFilled ? color : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }

            final int step = index ~/ 2;
            final bool isDone = step < activeStep;
            final bool isActive = step == activeStep;
            final bool isReached = step <= activeStep;

            return Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone ? color : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isReached ? color : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                boxShadow:
                    isActive
                        ? [
                          BoxShadow(
                            color: color.withAlpha(55),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                        : null,
              ),
              child:
                  isDone
                      ? const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      )
                      : isActive
                      ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      : null,
            );
          }),
        ),
        const SizedBox(height: 7),
        Row(
          children: List.generate(_labels.length, (index) {
            final bool isReached = index <= activeStep;
            return Expanded(
              child: Align(
                alignment:
                    index == 0
                        ? Alignment.centerLeft
                        : index == _labels.length - 1
                        ? Alignment.centerRight
                        : Alignment.center,
                child: Text(
                  _labels[index],
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 10.5,
                    fontWeight: isReached ? FontWeight.w700 : FontWeight.w500,
                    color:
                        isReached
                            ? const Color(0xFF374151)
                            : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  final Color background;
  final IconData icon;
  final int step;

  const _StatusInfo({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
    required this.step,
  });
}
