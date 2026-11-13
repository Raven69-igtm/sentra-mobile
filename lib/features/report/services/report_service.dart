import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';

class ReportService {
  Future<Map<String, Map<String, int>>> fetchReportStatistics() async {
    final response = await ApiClient.getRequest('/report-statistics');
    final dynamic body = response.data;
    if (body is! Map || body['data'] is! Map) {
      throw ApiException(message: 'Respons statistik tidak valid.');
    }

    final Map<String, Map<String, int>> statistics = {};
    (body['data'] as Map).forEach((month, stats) {
      if (stats is! Map) return;
      statistics[month.toString()] = {
        for (final entry in stats.entries)
          entry.key.toString(): _toInt(entry.value),
      };
    });
    return statistics;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
