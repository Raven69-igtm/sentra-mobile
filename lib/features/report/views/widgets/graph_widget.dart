import 'package:sentra/features/report/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class LineChartScreen extends StatefulWidget {
  const LineChartScreen({super.key});

  @override
  _LineChartScreenState createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  final ReportService _reportService = ReportService();
  Map<String, Map<String, int>>? _statistics;
  bool _isLoading = true;
  String _errorMessage = '';

  late final TrackballBehavior _trackballBehavior;
  late final ZoomPanBehavior _zoomPanBehavior;

  static const List<Color> _palette = <Color>[
    Color(0xFF4F46E5), // indigo
    Color(0xFF16A34A), // green
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
    Color(0xFF06B6D4), // cyan
    Color(0xFF8B5CF6), // violet
    Color(0xFF22C55E), // emerald
    Color(0xFFE11D48), // rose
  ];

  @override
  void initState() {
    super.initState();
    _trackballBehavior = TrackballBehavior(
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

    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enableDoubleTapZooming: false,
      enablePinching: true,
      zoomMode: ZoomMode.x,
    );

    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final data = await _reportService.fetchReportStatistics();
      setState(() {
        _statistics = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat statistik: $e';
        _isLoading = false;
      });
    }
  }

  List<String> _getMonths() {
    return const <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
  }

 List<String> _getCategories() {
    if (_statistics == null || _statistics!.isEmpty) return <String>[];
    final Set<String> cat =
        _statistics!.values
            .expand((stats) => stats.keys)
            .where(
              (category) => category.toLowerCase() != 'unset',
            ) 
            .toSet();
    final List<String> sorted =
        cat.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  List<CartesianSeries<ChartData, String>> _buildSeries() {
    final List<String> categories = _getCategories();
    final List<String> months = _getMonths();

    return List<CartesianSeries<ChartData, String>>.generate(categories.length, (int idx) {
      final String category = categories[idx];
      final Color color = _palette[idx % _palette.length];

      final List<ChartData> dataSource = months.map((String month) {
        final int count = _statistics?[month]?[category] ?? 0;
        return ChartData(month, count);
      }).toList();

      return SplineSeries<ChartData, String>(
        name: category,
        color: color,
        dataSource: dataSource,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
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
    final Widget content = _isLoading
        ? _buildShimmerChart()
        : _errorMessage.isNotEmpty
            ? Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : _statistics == null || _statistics!.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada data statistik',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    backgroundColor: Colors.white,
                    legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.top,
                      overflowMode: LegendItemOverflowMode.wrap,
                    ),
                    tooltipBehavior: TooltipBehavior(enable: false),
                    trackballBehavior: _trackballBehavior,
                    zoomPanBehavior: _zoomPanBehavior,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                      labelStyle: const TextStyle(fontSize: 11),
                      labelRotation: 0,
                    ),
                    primaryYAxis: NumericAxis(
                      majorGridLines: MajorGridLines(color: Colors.grey.shade300, width: 1),
                      axisLine: const AxisLine(width: 0),
                      numberFormat: NumberFormat.compact(),
                      labelStyle: const TextStyle(fontSize: 11),
                      title: const AxisTitle(text: 'Jumlah Laporan'),
                    ),
                    series: _buildSeries(),
                  );

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: content,
      ),
    );
  }
}

Widget _buildShimmerChart() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 22,
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.white,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[300]!),
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 20,
                    margin: const EdgeInsets.only(top: 8),
                    color: Colors.white,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(12, (int index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                            height: (index % 5 + 1) * 38.0,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class ChartData {
  final String x;
  final int y;
  ChartData(this.x, this.y);
}