import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/features/report/models/report_model.dart';
import 'package:sentra/features/report/models/statistic_model.dart';
import 'package:sentra/features/report/repositories/report_repository.dart';
import 'package:sentra/features/report/services/detail_service.dart';

/// Kegagalan pengiriman laporan yang membawa pesan siap-tampil
/// (sudah dipetakan dari status HTTP / jenis error jaringan).
class LaporanException implements Exception {
  final String pesan;
  LaporanException(this.pesan);

  @override
  String toString() => pesan;
}

class LaporanController extends ChangeNotifier {
  final LaporanRepository _laporanRepo = LaporanRepository();
  final ReportDetailService _detailService = ReportDetailService();

  List<LaporanModel> _laporanList = <LaporanModel>[];
  List<LaporanModel> _laporanByCategoryList = <LaporanModel>[];
  StatistikModel _statistik = StatistikModel();
  String _trackingStatus = '';
  bool _isLoading = false;
  String _errorMessage = '';

  bool _detailLoading = false;
  String _detailError = '';
  Map<String, dynamic>? _selectedReportDetail;

  List<LaporanModel> get laporanList => _laporanList;
  List<LaporanModel> get laporanByCategoryList => _laporanByCategoryList;
  StatistikModel get statistik => _statistik;
  String get trackingStatus => _trackingStatus;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  bool get detailLoading => _detailLoading;
  String get detailError => _detailError;
  Map<String, dynamic>? get selectedReportDetail => _selectedReportDetail;

  void clearTrackingState() {
    _trackingStatus = '';
    _errorMessage = '';
    notifyListeners();
  }

  /// Membersihkan seluruh cache laporan saat logout / ganti akun.
  void reset() {
    _laporanList = <LaporanModel>[];
    _laporanByCategoryList = <LaporanModel>[];
    _statistik = StatistikModel();
    _trackingStatus = '';
    _isLoading = false;
    _errorMessage = '';
    _detailLoading = false;
    _detailError = '';
    _selectedReportDetail = null;
    notifyListeners();
  }

  Future<void> getUserReports(int userId, {String? scope}) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      _laporanList = await _laporanRepo.getUserReports(userId, scope: scope);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _laporanList = <LaporanModel>[];
    } catch (_) {
      _errorMessage =
          'Gagal memuat riwayat laporan. Periksa koneksi Anda dan coba lagi.';
      _laporanList = <LaporanModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUserReportsByCategory(
    int userId,
    String category, {
    String? scope,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      _laporanByCategoryList = await _laporanRepo.getUserReportsByCategory(
        userId,
        category,
        scope: scope,
      );
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _laporanByCategoryList = <LaporanModel>[];
    } catch (_) {
      _errorMessage =
          'Gagal memuat laporan berdasarkan status. Silakan coba lagi.';
      _laporanByCategoryList = <LaporanModel>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getReportDetailById(
    String idLaporan, {
    String? bearerToken,
  }) async {
    try {
      _detailLoading = true;
      _detailError = '';
      notifyListeners();
      final result = await _detailService.fetchReportDetailById(idLaporan);
      _selectedReportDetail = result;
      return result;
    } catch (e) {
      _detailError = e.toString();
      rethrow;
    } finally {
      _detailLoading = false;
      notifyListeners();
    }
  }

  /// Mengirim laporan ke backend.
  ///
  /// Sukses hanya jika respons 2xx dan `success == true` dari server.
  /// Kegagalan dilempar sebagai [LaporanException] berisi pesan yang
  /// aman untuk ditampilkan ke pengguna (tanpa detail internal server).
  Future<dynamic> createReport(Map<String, dynamic> laporanData) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      final hasil = await _laporanRepo.postReport(laporanData);
      final bool terkonfirmasi = hasil is Map && hasil['success'] == true;
      if (!terkonfirmasi) {
        throw LaporanException(
          'Server tidak mengonfirmasi laporan tersimpan. Silakan coba lagi.',
        );
      }
      return hasil;
    } on LaporanException {
      rethrow;
    } on ApiException catch (e) {
      final pesan = _pesanErrorDariApi(e);
      _errorMessage = pesan;
      throw LaporanException(pesan);
    } on DioException catch (e) {
      final pesan = _pesanErrorDariDio(e);
      _errorMessage = pesan;
      throw LaporanException(pesan);
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      throw LaporanException('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      _isLoading = false;
      notifyListeners();
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
    _laporanList = List<LaporanModel>.from(results);
    notifyListeners();
  }

  void clearSearchResults() {
    _laporanList = <LaporanModel>[];
    notifyListeners();
  }

  Future<void> trackingReport(String trackingCode) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      _trackingStatus = '';
      notifyListeners();

      final result = await _laporanRepo.trackingReport(trackingCode);

      if (result.isNotEmpty) {
        _trackingStatus = result;
      } else {
        _errorMessage = 'Tracking report kosong atau tidak ditemukan.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getStatistic() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      _statistik = await _laporanRepo.getReportStatistic();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
