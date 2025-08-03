import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/fitur/laporan/data/models/laporanmodels.dart';
import 'package:sentra/fitur/laporan/data/models/statistikmodel.dart';
import 'package:dio/dio.dart';

class LaporanRepository {

  Future<List<LaporanModel>> getUserReports(int userId) async {
    try {
      final response = await ApiClient.getRequest('/user-reports/$userId');
      List data = response.data['laporan'];
      print(response.data['laporan']);
      return data.map((e) => LaporanModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil laporan user');
    }
  }

  Future<List<LaporanModel>> getUserReportsByCategory(
    int userId,
    String kategori,
  ) async {
    try {
      final response = await ApiClient.getRequest(
        '/user-reports-by-category/$userId/$kategori',
      );
      List data = response.data['laporan'];
      print(data);
      return data.map((e) => LaporanModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil laporan berdasarkan kategori');
    }
  }

  Future<void> postReport(Map<String, dynamic> laporanData) async {
    try {
      await ApiClient.postRequest('/post-report', laporanData);
    } catch (e) {
      throw Exception('Gagal membuat laporan');
    }
  }

  Future<String> trackingReport(String trackingCode) async {
    try {
      final response = await ApiClient.postRequest('/track-report', {
        "id_laporan": trackingCode
      });
      print(trackingCode);
      print(response.data);
      return response.data['status'];
    } catch (e) {
      print(e);
      throw Exception('Gagal tracking laporan : $e');
    }
  }

  Future<StatistikModel> getReportStatistic() async {
    try {
      final response = await ApiClient.getRequest('/report-statistics');
      return StatistikModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Gagal mengambil statistik laporan');
    }
  }
}
