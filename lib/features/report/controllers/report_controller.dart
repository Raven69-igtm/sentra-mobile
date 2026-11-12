import 'package:get/get.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/features/report/models/report_model.dart';
import 'package:sentra/features/report/repositories/report_repository.dart';
import 'package:sentra/features/report/services/detail_service.dart';

class LaporanController extends GetxController {
  final LaporanRepository _laporanRepo = LaporanRepository();
  final ReportDetailService _detailService = ReportDetailService();

  final laporanList = <LaporanModel>[].obs;
  final laporanByCategoryList = <LaporanModel>[].obs;
  final trackingStatus = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final detailLoading = false.obs;
  final detailError = ''.obs;
  final Rxn<Map<String, dynamic>> selectedReportDetail =
      Rxn<Map<String, dynamic>>();

  Future<void> getUserReports(int userId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final reports = await _laporanRepo.getUserReports(userId);
      laporanList.assignAll(reports);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserReportsByCategory(int userId, String category) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final reports = await _laporanRepo.getUserReportsByCategory(
        userId,
        category,
      );
      laporanByCategoryList.assignAll(reports);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> getReportDetailById(String idLaporan) async {
    detailLoading.value = true;
    detailError.value = '';
    try {
      final result = await _detailService.fetchReportDetailById(idLaporan);
      selectedReportDetail.value = result;
      return result;
    } on ApiException catch (e) {
      detailError.value = e.message;
      rethrow;
    } finally {
      detailLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> createReport(
    Map<String, dynamic> laporanData,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      return await _laporanRepo.postReport(laporanData);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchResults(List<LaporanModel> results) {
    laporanList.assignAll(results);
  }

  void clearSearchResults() {
    laporanList.clear();
  }

  Future<void> trackingReport(String trackingCode) async {
    isLoading.value = true;
    errorMessage.value = '';
    trackingStatus.value = '';
    try {
      final result = await _laporanRepo.trackingReport(trackingCode);
      if (result.isEmpty) {
        errorMessage.value = 'Status laporan tidak ditemukan.';
        return;
      }
      trackingStatus.value = result;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    laporanList.clear();
    laporanByCategoryList.clear();
    trackingStatus.value = '';
    errorMessage.value = '';
    detailError.value = '';
    selectedReportDetail.value = null;
    isLoading.value = false;
    detailLoading.value = false;
  }
}
