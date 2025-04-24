import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class LineChartScreen extends StatelessWidget {
  const LineChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          // title: ChartTitle(text: 'Monitoring Laporan dalam Setahun',textStyle: TextStyle(fontFamily: 'Mulish',fontSize: 12)),
          legend: Legend(isVisible: true, position: LegendPosition.top),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <LineSeries<ChartData, String>>[
            LineSeries<ChartData, String>(
              name: 'KDRT',
              dataSource: [
                ChartData('Jan', 25),
                ChartData('Feb', 45),
                ChartData('Mar', 60),
                ChartData('Apr', 35),
                ChartData('May', 50),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(isVisible: false),
            ),
            LineSeries<ChartData, String>(
              name: 'Penelantaran',
              dataSource: [
                ChartData('Jan', 40),
                ChartData('Feb', 30),
                ChartData('Mar', 55),
                ChartData('Apr', 65),
                ChartData('May', 20),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(isVisible: false),
            ),
            LineSeries<ChartData, String>(
              name: 'Kekerasan Fisik',
              dataSource: [
                ChartData('Jan', 35),
                ChartData('Feb', 50),
                ChartData('Mar', 25),
                ChartData('Apr', 70),
                ChartData('May', 55),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(isVisible: false),
            ),
            LineSeries<ChartData, String>(
              name: 'Kekerasan Psikis',
              dataSource: [
                ChartData('Jan', 50),
                ChartData('Feb', 25),
                ChartData('Mar', 60),
                ChartData('Apr', 30),
                ChartData('May', 45),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(isVisible: false),
            ),
            LineSeries<ChartData, String>(
              name: 'Bullying',
              dataSource: [
                ChartData('Jan', 60),
                ChartData('Feb', 40),
                ChartData('Mar', 35),
                ChartData('Apr', 25),
                ChartData('May', 70),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(isVisible: false),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;
  ChartData(this.x, this.y);
}
