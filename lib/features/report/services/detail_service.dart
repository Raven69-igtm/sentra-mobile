import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';

class ReportDetailService {
  /// Detail laporan memakai endpoint POST /track-report.
  /// Backend tidak menyediakan GET /laporan/{id}.
  Future<Map<String, dynamic>?> fetchReportDetailById(String idLaporan) async {
    final response = await ApiClient.postRequest('/track-report', {
      'id_laporan': idLaporan,
    });

    final data = response.data;
    if (data is Map && data['laporan'] is Map) {
      return Map<String, dynamic>.from(data['laporan'] as Map);
    }

    throw ApiException(
      message: 'Detail laporan tidak ditemukan pada respons server.',
      statusCode: response.statusCode,
    );
  }
}
