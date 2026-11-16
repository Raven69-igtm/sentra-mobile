import 'package:dio/dio.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/features/report/models/report_model.dart';
import 'package:sentra/features/report/models/statistic_model.dart';
import 'package:sentra/features/report/repositories/report_repository.dart';
import 'package:get/get.dart';
import 'package:sentra/features/report/services/detail_service.dart';

/// Kegagalan pengiriman laporan yang membawa pesan siap-tampil
/// (sudah dipetakan dari status HTTP / jenis error jaringan).
class LaporanException implements Exception {
  final String pesan;
  LaporanException(this.pesan);

  @override
  String toString() => pesan;
}

class LaporanController extends GetxController {
  final LaporanRepository _laporanRepo = LaporanRepository();

  var laporanList = <LaporanModel>[].obs;
  var laporanByCategoryList = <LaporanModel>[].obs;
  var statistik = StatistikModel().obs;
  var trackingStatus = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> getUserReports(int userId) async {
    try {
      isLoading.value = true;
      laporanList.value = await _laporanRepo.getUserReports(userId);
    } catch (e) {
      laporanList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserReportsByCategory(int userId, String category) async {
    try {
      isLoading.value = true;
      laporanByCategoryList.value = await _laporanRepo.getUserReportsByCategory(
        userId,
        category,
      );
    } catch (e) {
      laporanByCategoryList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  final RxBool detailLoading = false.obs;
  final RxString detailError = ''.obs;
  final Rxn<Map<String, dynamic>> selectedReportDetail =
      Rxn<Map<String, dynamic>>();

  final ReportDetailService _detailService = ReportDetailService();

  Future<Map<String, dynamic>?> getReportDetailById(
    String idLaporan, {
    String? bearerToken,
  }) async {
    try {
      detailLoading.value = true;
      detailError.value = '';
      final result = await _detailService.fetchReportDetailById(idLaporan);
      selectedReportDetail.value = result;
      return result;
    } catch (e) {
      detailError.value = e.toString();
      rethrow;
    } finally {
      detailLoading.value = false;
    }
  }

  /// Mengirim laporan ke backend.
  ///
  /// Sukses hanya jika respons 2xx dan `success == true` dari server.
  /// Kegagalan dilempar sebagai [LaporanException] berisi pesan yang
  /// aman untuk ditampilkan ke pengguna (tanpa detail internal server).
  Future<dynamic> createReport(Map<String, dynamic> laporanData) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final hasil = await _laporanRepo.postReport(laporanData);
      final bool terkonfirmasi = hasil is Map && hasil['success'] == true;
      if (!terkonfirmasi) {
        // Respons 2xx tetapi isi ambigu — jangan menyatakan laporan tersimpan.
        throw LaporanException(
          'Server tidak mengonfirmasi laporan tersimpan. Silakan coba lagi.',
        );
      }
      return hasil;
    } on LaporanException {
      rethrow;
    } on ApiException catch (e) {
      final pesan = _pesanErrorDariApi(e);
      errorMessage.value = pesan;
      throw LaporanException(pesan);
    } on DioException catch (e) {
      final pesan = _pesanErrorDariDio(e);
      errorMessage.value = pesan;
      throw LaporanException(pesan);
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi.';
      throw LaporanException('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  String _pesanErrorDariApi(ApiException e) {
    if (e.statusCode == 422 && e.errors != null && e.errors!.isNotEmpty) {
      final first = e.errors!.values.first;
      final detail =
          first is List && first.isNotEmpty
              ? first.first.toString()
              : first.toString();
      return 'Data belum sesuai: $detail';
    }

    switch (e.statusCode) {
      case 401:
      case 403:
        return 'Sesi Anda telah berakhir. Silakan login kembali.';
      case 404:
        return 'Layanan pengaduan tidak ditemukan. Silakan coba lagi.';
      case 422:
        return 'Data laporan belum lengkap. Periksa kembali isian Anda.';
      case 500:
      case 502:
      case 503:
        return 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
      default:
        return e.message;
    }
  }

  /// Memetakan kesalahan jaringan/status HTTP menjadi pesan yang informatif
  /// dan aman untuk pengguna (tidak membocorkan struktur internal server).
  String _pesanErrorDariDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi ke server kehabisan waktu. Periksa jaringan Anda dan coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      default:
        break;
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    switch (statusCode) {
      case 422:
        if (data is Map && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final first = errors.values.first;
            final pesan =
                (first is List && first.isNotEmpty)
                    ? first.first.toString()
                    : first.toString();
            return 'Data belum sesuai: $pesan';
          }
        }
        if (data is Map && data['message'] is String) {
          final pesan = data['message'] as String;
          if (pesan.isNotEmpty) return 'Data belum sesuai: $pesan';
        }
        return 'Data laporan belum lengkap. Periksa kembali isian Anda.';
      case 401:
      case 403:
        return 'Sesi Anda telah berakhir. Silakan login kembali.';
      case 404:
        return 'Layanan pengaduan tidak ditemukan. Silakan coba lagi.';
      case 500:
      case 502:
      case 503:
        return 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
      default:
        return 'Gagal mengirim laporan${statusCode != null ? ' (kode $statusCode)' : ''}. Silakan coba lagi.';
    }
  }

  void updateSearchResults(List<LaporanModel> results) {
    laporanList.assignAll(results);
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
