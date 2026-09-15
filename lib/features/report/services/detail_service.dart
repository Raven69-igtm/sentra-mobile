import 'package:dio/dio.dart';
import 'package:sentra/core/network/api_client.dart';

class ReportDetailService {
  Future<Map<String, dynamic>?> fetchReportDetailById(String idLaporan) async {
    try {
      final Response response = await ApiClient.getRequest(
        '/laporan/$idLaporan',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['laporan'] as Map<String, dynamic>?;
        }
      }
      throw Exception('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception('HTTP $code: $body');
    } catch (e) {
      throw Exception('Failed to fetch detail: $e');
    }
  }
}
