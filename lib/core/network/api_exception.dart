import 'package:dio/dio.dart';

/// Error yang berasal dari API SENTRA.
///
/// Membawa status HTTP dan pesan dari server agar UI dapat menampilkan
/// penyebab kegagalan yang sebenarnya, bukan pesan generik.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, this.statusCode, this.errors});

  bool get isNetworkError => statusCode == null;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;

    if (response == null) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException(
            message: 'Koneksi ke server timeout. Silakan coba lagi.',
          );
        case DioExceptionType.connectionError:
          return ApiException(
            message:
                'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
          );
        case DioExceptionType.cancel:
          return ApiException(message: 'Permintaan dibatalkan.');
        default:
          return ApiException(
            message: 'Terjadi kesalahan jaringan. Silakan coba lagi.',
          );
      }
    }

    final data = response.data;
    String? message;
    Map<String, dynamic>? errors;

    if (data is Map) {
      final rawMessage = data['message'];
      if (rawMessage is String && rawMessage.trim().isNotEmpty) {
        message = rawMessage;
      }
      final rawErrors = data['errors'];
      if (rawErrors is Map) {
        errors = rawErrors.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        if (message == null && rawErrors.isNotEmpty) {
          final first = rawErrors.values.first;
          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          } else if (first != null) {
            message = first.toString();
          }
        }
      }
    }

    final status = response.statusCode;
    message ??= switch (status) {
      400 => 'Permintaan tidak valid.',
      401 => 'Sesi tidak valid. Silakan login kembali.',
      403 => 'Anda tidak memiliki akses.',
      404 => 'Data tidak ditemukan.',
      422 => 'Data yang dikirim belum lengkap atau tidak valid.',
      _ when (status ?? 0) >= 500 =>
        'Terjadi kesalahan pada server. Silakan coba lagi.',
      _ => 'Permintaan gagal (HTTP ${status ?? '-'}).',
    };

    return ApiException(message: message, statusCode: status, errors: errors);
  }

  @override
  String toString() => message;
}
