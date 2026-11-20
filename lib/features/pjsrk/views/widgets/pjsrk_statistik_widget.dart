import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

/// Widget Statistik Laporan PJSRK — grafik spline per kategori per bulan.
/// Menggunakan data dummy sementara; nanti disambungkan ke endpoint admin Sentra.
class PjsrkStatistikWidget extends StatefulWidget {
  const PjsrkStatistikWidget({super.key});

  @override
  State<PjsrkStatistikWidget> createState() => _PjsrkStatistikWidgetState();
}

class _PjsrkStatistikWidgetState extends State<PjsrkStatistikWidget> {
  static const Color _primaryOrange = Color(0xFFD8782E);

  // ── Palet warna tiap kategori ────────────────────────────────────────────
  static const List<Color> _palette = <Color>[
    Color(0xFFD8782E), // oranye  — Bencana Alam
    Color(0xFF4F46E5), // indigo  — Rehabilitasi Sosial
    Color(0xFF16A34A), // hijau   — Permasalahan Sosial
    Color(0xFFEF4444), // merah   — Kekerasan Sosial
    Color(0xFF06B6D4), // cyan    — Lainnya
  ];

  // ── State ────────────────────────────────────────────────────────────────
  bool _isLoading = true;
  String _errorMessage = '';
  /// Format: { 'Jan': { 'Bencana Alam': 3, 'Rehabilitasi Sosial': 1, … }, … }
  Map<String, Map<String, int>>? _statistics;

  late final TrackballBehavior _trackball;
  late final ZoomPanBehavior _zoomPan;

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  // ── Kategori PJSRK ───────────────────────────────────────────────────────
  static const List<String> _categories = <String>[
    'Bencana Alam',
    'Rehabilitasi Sosial',
    'Permasalahan Sosial',
  ];

  @override
  void initState() {
    super.initState();
    _trackball = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      lineColor: Colors.grey.shade400,
      lineWidth: 1,
      tooltipAlignment: ChartAlignment.near,
      shouldAlwaysShow: false,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      tooltipSettings: const InteractiveTooltip(
        color: Colors.black87,
        textStyle: TextStyle(color: Colors.white),
        borderWidth: 0,
      ),
    );
    _zoomPan = ZoomPanBehavior(
      enablePanning: true,
      enableDoubleTapZooming: false,
      enablePinching: true,
      zoomMode: ZoomMode.x,
    );

    _loadStatistics();
  }

  /// TODO: Ganti implementasi ini dengan pemanggilan API ke admin Sentra.
  /// Endpoint yang perlu dibuat: GET /pjsrk/statistik?tahun=YYYY
  /// Response: { "data": { "Jan": { "Bencana Alam": 3, … }, … } }
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // ── DATA DUMMY ── hapus blok ini dan ganti dengan hasil HTTP request ──
      await Future.delayed(const Duration(milliseconds: 800)); // simulasi delay
      final Map<String, Map<String, int>> dummy = {
        'Jan': {'Bencana Alam': 2, 'Rehabilitasi Sosial': 1, 'Permasalahan Sosial': 0},
        'Feb': {'Bencana Alam': 1, 'Rehabilitasi Sosial': 2, 'Permasalahan Sosial': 1},
        'Mar': {'Bencana Alam': 0, 'Rehabilitasi Sosial': 3, 'Permasalahan Sosial': 2},
        'Apr': {'Bencana Alam': 3, 'Rehabilitasi Sosial': 1, 'Permasalahan Sosial': 4},
        'Mei': {'Bencana Alam': 1, 'Rehabilitasi Sosial': 0, 'Permasalahan Sosial': 2},
        'Jun': {'Bencana Alam': 2, 'Rehabilitasi Sosial': 2, 'Permasalahan Sosial': 1},
        'Jul': {'Bencana Alam': 4, 'Rehabilitasi Sosial': 3, 'Permasalahan Sosial': 2},
        'Agu': {'Bencana Alam': 5, 'Rehabilitasi Sosial': 1, 'Permasalahan Sosial': 3},
        'Sep': {'Bencana Alam': 3, 'Rehabilitasi Sosial': 4, 'Permasalahan Sosial': 1},
        'Okt': {'Bencana Alam': 2, 'Rehabilitasi Sosial': 2, 'Permasalahan Sosial': 2},
        'Nov': {'Bencana Alam': 1, 'Rehabilitasi Sosial': 3, 'Permasalahan Sosial': 4},
        'Des': {'Bencana Alam': 0, 'Rehabilitasi Sosial': 1, 'Permasalahan Sosial': 2},
      };
      // ── AKHIR DATA DUMMY ─────────────────────────────────────────────────

      if (mounted) setState(() { _statistics = dummy; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = 'Gagal memuat statistik: $e'; _isLoading = false; });
    }
  }

  List<CartesianSeries<_ChartPoint, String>> _buildSeries() {
    return List.generate(_categories.length, (int idx) {
      final String cat = _categories[idx];
      final Color color = _palette[idx % _palette.length];
      final List<_ChartPoint> points = _months.map((m) {
        final int val = _statistics?[m]?[cat] ?? 0;
        return _ChartPoint(m, val);
      }).toList();

      return SplineSeries<_ChartPoint, String>(
        name: cat,
        color: color,
        dataSource: points,
        xValueMapper: (p, _) => p.x,
        yValueMapper: (p, _) => p.y,
        width: 2.5,
        markerSettings: const MarkerSettings(
          isVisible: true,
          width: 6,
          height: 6,
          shape: DataMarkerType.circle,
          borderWidth: 1.2,
        ),
        dataLabelSettings: const DataLabelSettings(isVisible: false),
        animationDuration: 800,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Section ──────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBEADB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: _primaryOrange,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistik Laporan',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF252525),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Rekap laporan PJSRK di Kabupaten Nganjuk berdasarkan kategori.',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 12,
                      color: Color(0xFF8D9299),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Tombol refresh
            IconButton(
              onPressed: _isLoading ? null : _loadStatistics,
              icon: AnimatedRotation(
                turns: _isLoading ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                child: Icon(
                  Icons.refresh_rounded,
                  color: _isLoading ? Colors.grey.shade400 : _primaryOrange,
                  size: 20,
                ),
              ),
              tooltip: 'Perbarui statistik',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Grafik ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isLoading
                ? _PjsrkChartShimmer(key: const ValueKey('shimmer'))
                : _errorMessage.isNotEmpty
                    ? _PjsrkChartError(
                        key: const ValueKey('error'),
                        message: _errorMessage,
                        onRetry: _loadStatistics,
                      )
                    : _PjsrkChart(
                        key: const ValueKey('chart'),
                        series: _buildSeries(),
                        trackball: _trackball,
                        zoomPan: _zoomPan,
                      ),
          ),
        ),
      ],
    );
  }
}

// ── Chart widget ─────────────────────────────────────────────────────────────
class _PjsrkChart extends StatelessWidget {
  final List<CartesianSeries<_ChartPoint, String>> series;
  final TrackballBehavior trackball;
  final ZoomPanBehavior zoomPan;

  const _PjsrkChart({
    super.key,
    required this.series,
    required this.trackball,
    required this.zoomPan,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        backgroundColor: Colors.white,
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.top,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: TextStyle(fontFamily: 'Mulish', fontSize: 12),
        ),
        tooltipBehavior: TooltipBehavior(enable: false),
        trackballBehavior: trackball,
        zoomPanBehavior: zoomPan,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
          labelStyle: const TextStyle(fontFamily: 'Mulish', fontSize: 10),
        ),
        primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(color: Colors.grey.shade200, width: 1),
          axisLine: const AxisLine(width: 0),
          numberFormat: NumberFormat.compact(),
          labelStyle: const TextStyle(fontFamily: 'Mulish', fontSize: 10),
          title: const AxisTitle(
            text: 'Jumlah Laporan',
            textStyle: TextStyle(fontFamily: 'Mulish', fontSize: 10),
          ),
        ),
        series: series,
      ),
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────────────────────────
class _PjsrkChartShimmer extends StatelessWidget {
  const _PjsrkChartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: SizedBox(
        height: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Legend row
            Row(
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Container(width: 70, height: 10, color: Colors.white),
                ]),
              )),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Y-axis label
                  Container(width: 10, height: double.infinity, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(12, (i) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: (i % 5 + 1) * 30.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // X-axis labels
            Row(
              children: List.generate(12, (i) => Expanded(
                child: Container(height: 10, margin: const EdgeInsets.symmetric(horizontal: 2), color: Colors.white),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────────
class _PjsrkChartError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PjsrkChartError({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_rounded, size: 40, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Mulish',
                color: Colors.red,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi', style: TextStyle(fontFamily: 'Mulish')),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD8782E),
                side: const BorderSide(color: Color(0xFFD8782E)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _ChartPoint {
  final String x;
  final int y;
  const _ChartPoint(this.x, this.y);
}

