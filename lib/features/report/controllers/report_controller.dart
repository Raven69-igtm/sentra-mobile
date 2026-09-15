import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/features/report/models/report_model.dart';
import 'package:sentra/features/report/models/statistic_model.dart';
import 'package:sentra/features/report/repositories/report_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sentra/features/report/services/detail_service.dart';

class LaporanController extends GetxController {
  final LaporanRepository _laporanRepo = LaporanRepository();

  var laporanList = <LaporanModel>[].obs;
  var laporanByCategoryList = <LaporanModel>[].obs;
  var statistik = StatistikModel().obs;
  var trackingStatus = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://${ApiClient.baseUrl}',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<void> getUserReports(int userId) async {
    try {
      isLoading.value = true;
      final response = await _dio.get(
        '/api/user-reports/$userId'
      );
      print('getUserReports response: ${response.data}');
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['laporan'] ?? [];
        laporanList.value =
            data.map((json) => LaporanModel.fromJson(json)).toList();
        print('Updated laporanList: ${laporanList.length}');
      } else {
        print(
          'Failed to fetch reports: ${response.statusCode} - ${response.statusMessage}',
        );
        laporanList.clear();
      }
    } catch (e) {
      print('Error fetching reports: $e');
      if (e is DioException) {
        print(
          'DioError details: ${e.response?.data}, Status: ${e.response?.statusCode}',
        );
      }
      laporanList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserReportsByCategory(int userId, String category) async {
    try {
      isLoading.value = true;
      final response = await _dio.get(
        '/api/user-reports-by-category/$userId/$category',
      );
      print(
        'getUserReportsByCategory response (status: $category): ${response.data}',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['laporan'] ?? [];
        laporanByCategoryList.value =
            data.map((json) => LaporanModel.fromJson(json)).toList();
        print('Updated laporanByCategoryList: ${laporanByCategoryList.length}');
      } else {
        print(
          'Failed to fetch reports by category: ${response.statusCode} - ${response.statusMessage}',
        );
        laporanByCategoryList.clear();
      }
    } catch (e) {
      print('Error fetching reports by category: $e');
      if (e is DioException) {
        print(
          'DioError details: ${e.response?.data}, Status: ${e.response?.statusCode}',
        );
      }
      laporanByCategoryList.clear();
    } finally {
      isLoading.value = false;
    }
  }
   final RxBool detailLoading = false.obs;
  final RxString detailError = ''.obs;
  final Rxn<Map<String, dynamic>> selectedReportDetail =
      Rxn<Map<String, dynamic>>();

  final ReportDetailService _detailService = ReportDetailService(
  );

  Future<Map<String, dynamic>?> getReportDetailById(
    String idLaporan, {
    String? bearerToken,
  }) async {
    try {
      detailLoading.value = true;
      detailError.value = '';
      final result = await _detailService.fetchReportDetailById(
        idLaporan,
      );
      selectedReportDetail.value = result;
      return result;
    } catch (e) {
      detailError.value = e.toString();
      rethrow;
    } finally {
      detailLoading.value = false;
    }
  }

  Future<void> createReport(Map<String, dynamic> laporanData) async {
    try {
      isLoading.value = true;
      await _laporanRepo.postReport(laporanData);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  void updateSearchResults(List<LaporanModel> results) {
    laporanList.assignAll(
      results,
    );
  }

  void clearSearchResults() {
    laporanList.clear(); 
  }

  Future<void> trackingReport(String trackingCode) async {
    try {
      isLoading.value = true;

      final result = await _laporanRepo.trackingReport(trackingCode);

      if (result.isNotEmpty) {
        trackingStatus.value = result;
      } else {
        errorMessage.value = 'Tracking report kosong atau tidak ditemukan.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getStatistic() async {
    try {
      isLoading.value = true;
      statistik.value = await _laporanRepo.getReportStatistic();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
