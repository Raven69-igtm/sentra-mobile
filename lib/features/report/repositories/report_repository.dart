import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/features/report/models/report_model.dart';

class LaporanRepository {
  Future<List<LaporanModel>> getUserReports(int userId) async {
    final response = await ApiClient.getRequest('/user-reports/$userId');
    return _parseLaporanList(response.data);
  }

  Future<List<LaporanModel>> getUserReportsByCategory(
    int userId,
    String kategori,
  ) async {
    final response = await ApiClient.getRequest(
      '/user-reports-by-category/$userId/$kategori',
    );
    return _parseLaporanList(response.data);
  }

  Future<Map<String, dynamic>> postReport(
    Map<String, dynamic> laporanData,
  ) async {
    final response = await ApiClient.postRequest('/post-report', laporanData);
    final data = response.data;
    if (data is Map && data['success'] == true) {
      final created = data['data'];
      if (created is Map && created['laporan'] is Map) {
        return Map<String, dynamic>.from(created['laporan'] as Map);
      }
      return <String, dynamic>{};
    }

    throw ApiException(
      message:
          data is Map && data['message'] is String
              ? data['message'] as String
              : 'Gagal membuat laporan.',
      statusCode: response.statusCode,
    );
  }

  Future<String> trackingReport(String trackingCode) async {
    final response = await ApiClient.postRequest('/track-report', {
      'id_laporan': trackingCode.trim(),
    });
    final data = response.data;
    if (data is Map && data['status'] is String) {
      return data['status'] as String;
    }
    throw ApiException(
      message: 'Status laporan tidak ditemukan pada respons server.',
      statusCode: response.statusCode,
    );
  }

  List<LaporanModel> _parseLaporanList(dynamic data) {
    if (data is Map && data['laporan'] is List) {
      return (data['laporan'] as List)
          .whereType<Map>()
          .map((json) => LaporanModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    if (data is List) {
      return data
          .whereType<Map>()
          .map((json) => LaporanModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    throw ApiException(message: 'Respons daftar laporan tidak valid.');
  }
}
