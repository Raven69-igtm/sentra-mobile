import 'package:dio/dio.dart';
import 'package:sentra/core/network/api_client.dart';

class ReportService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://${ApiClient.baseUrl}',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Map<String, Map<String, int>>?> fetchReportStatistics() async {
    try {
      final response = await _dio.get('/api/report-statistics');
      print('Raw response data: ${response.data}');
      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
        final data = jsonData['data'] as Map<String, dynamic>;
        return data.map(
          (month, stats) => MapEntry(
            month,
            (stats as Map<String, dynamic>).map((category, value) {
              final int count =
                  value is int
                      ? value
                      : (value is double
                          ? value.toInt()
                          : int.parse(value.toString()));
              print(
                'Parsing month: $month, category: $category, value: $value, type: ${value.runtimeType}, converted: $count',
              );
              return MapEntry(category, count);
            }),
          ),
        );
      } else {
        print('Failed to fetch statistics: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching statistics: $e');
      return null;
    }
  }
}
