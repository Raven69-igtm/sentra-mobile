import 'package:sentra/fitur/laporan/service/reportservice.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }
  Future<void> _fetchStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final data = await _reportService.fetchReportStatistics();
      print('Fetched statistics: $data');
      print('Statistics type: ${data.runtimeType}');
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
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
  }

  List<String> _getCategories() {
    if (_statistics == null || _statistics!.isEmpty) return [];
    return _statistics!.values.expand((stats) => stats.keys).toSet().toList();
  }

  List<LineSeries<ChartData, String>> _buildSeries() {
    final categories = _getCategories();
    final months = _getMonths();
    print('Categories: $categories');
    return categories.map((category) {
      final dataSource =
          months.map((month) {
            final count = _statistics?[month]?[category] ?? 0;
            return ChartData(month, count.toInt());
          }).toList();
      print(
        'Data source for $category: ${dataSource.map((d) => {d.x: d.y}).toList()}',
      );
      return LineSeries<ChartData, String>(
        name: category,
        dataSource: dataSource,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child:
          _isLoading
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
                primaryXAxis: const CategoryAxis(),
                primaryYAxis: const NumericAxis(
                  title: AxisTitle(text: 'Jumlah Laporan'),
                ),
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.top,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: _buildSeries(),
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            height: 20,
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
                      children: List.generate(
                        12,
                        (index) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            height: (index % 5 + 1) * 40.0, 
                          ),
                        ),
                      ),
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
