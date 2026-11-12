import 'package:dio/dio.dart';

/// Base URL dapat dioverride lewat build command tanpa mengubah kode:
///
///   flutter run --dart-define=SENTRA_API_URL=10.0.2.2:8000          (emulator Android)
///   flutter run --dart-define=SENTRA_API_URL=192.168.1.10:8000      (perangkat fisik, IP host)
///   flutter build apk --dart-define=SENTRA_API_URL=https://domain.com/public
///
/// Konversi scheme http/https mengikuti URL yang diberikan.
/// Jangan pernah menghardcode kredensial di sini.
class ApiClient {
  static const String _configuredUrl = String.fromEnvironment(
    'SENTRA_API_URL',
    defaultValue: '127.0.0.1:8000',
  );

  static const bool isLocal = _configuredUrl == '127.0.0.1:8000';
  static String get protocol =>
      _configuredUrl.startsWith('https') ? 'https' : 'http';
  static String get baseUrl =>
      _configuredUrl.replaceFirst(RegExp(r'^https?://'), '');
  static const String wsUrl = isLocal
      ? 'ws://127.0.0.1:3021'
      : 'ws://18.136.209.83:3021';

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: '$protocol://$baseUrl/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        // Wajib: tanpa header ini backend Laravel membalas error validasi
        // dengan 302 redirect (behavior web) alih-alih JSON 422.
        'Accept': 'application/json',
      },
    ),
  );

  static Future<Response> getRequest(
    String url, {
    Map<String, dynamic>? params,
  }) async {
    try {
      return await dio.get(url, queryParameters: params);
    } on DioException {
      // Dilempar kembali apa adanya agar pemanggil dapat
      // membedakan status HTTP (422/401/500) dan jenis error jaringan.
      rethrow;
    } catch (e) {
      throw Exception("Failed to load data: $e");
    }
  }

  static Future<Response> putRequest(
    String url, {
    Map<String, dynamic>? data,
  }) async {
    try {
      return await dio.put(url, data: data);
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception("Failed to update data: $e");
    }
  }

  static Future<Response> postRequest(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      return await dio.post(url, data: data);
    } on DioException {
      // Dilempar kembali apa adanya agar pemanggil dapat
      // membedakan status HTTP (422/401/403/500) dan jenis error jaringan.
      rethrow;
    } catch (e) {
      throw Exception("Failed to send data: $e");
    }
  }
}
