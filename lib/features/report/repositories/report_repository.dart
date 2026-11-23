import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/endpoints.dart';
import 'package:sentra/features/report/models/report_model.dart';
import 'package:sentra/features/report/models/statistic_model.dart';

class LaporanRepository {
  Future<List<LaporanModel>> getUserReports(int userId) async {
    final response = await ApiClient.getRequest(
      '${Endpoints.userReports}/$userId',
    );
    final List<dynamic> data = (response.data['laporan'] as List?) ?? const [];
    return data
        .map((e) => LaporanModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<LaporanModel>> getUserReportsByCategory(
    int userId,
    String kategori,
  ) async {
    final response = await ApiClient.getRequest(
      '${Endpoints.userReportsByCategory}/$userId/$kategori',
    );
    final List<dynamic> data = (response.data['laporan'] as List?) ?? const [];
    return data
        .map((e) => LaporanModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Mengirim laporan ke backend dan mengembalikan isi respons ({success, message, data}).
  Future<dynamic> postReport(Map<String, dynamic> laporanData) async {
    final response = await ApiClient.postRequest(
      Endpoints.postReport,
      laporanData,
    );
    return response.data;
  }

  Future<String> trackingReport(String trackingCode) async {
    final response = await ApiClient.postRequest(Endpoints.trackReport, {
      'id_laporan': trackingCode,
    });
    return response.data['status']?.toString() ?? '';
  }

  Future<StatistikModel> getReportStatistic() async {
    final response = await ApiClient.getRequest(Endpoints.reportStatistics);
    return StatistikModel.fromJson(response.data['data']);
  }
}
