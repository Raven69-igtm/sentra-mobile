import 'package:dio/dio.dart';

import 'api_exception.dart';

class ApiClient {
  // Base URL dapat diganti saat build tanpa mengubah kode, contoh:
  // flutter build apk --dart-define=SENTRA_API_ORIGIN=https://domain/api-host
  static const String _apiOriginOverride = String.fromEnvironment(
    'SENTRA_API_ORIGIN',
  );
  static const String _wsUrlOverride = String.fromEnvironment(
    'SENTRA_WS_URL',
  );

  static const bool isLocal = bool.fromEnvironment(
    'SENTRA_IS_LOCAL',
    defaultValue: true,
  );
  static const String protocol = isLocal ? 'http' : 'https';
  static const String baseUrl =
      isLocal ? '127.0.0.1:8000' : 'sentra.pbltifnganjuk.com/public';

  static String get apiOrigin =>
      _apiOriginOverride.isNotEmpty ? _apiOriginOverride : '$protocol://$baseUrl';

  static String get wsUrl =>
      _wsUrlOverride.isNotEmpty
          ? _wsUrlOverride
          : (isLocal ? 'ws://127.0.0.1:3021' : 'ws://18.136.209.83:3021');

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: '$apiOrigin/api',
      connectTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        // Laravel hanya mengembalikan JSON (422/401) bila diminta via header ini.
        'Accept': 'application/json',
      },
    ),
  );

  static String? _authToken;

  /// Menyimpan token Sanctum agar setiap request API membawa header Bearer.
  static void setAuthToken(String? token) {
    _authToken = token;
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  static String? get authToken => _authToken;

  static Future<Response> getRequest(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
  }) {
    return _guard(
      () => dio.get(url, queryParameters: params, options: options),
    );
  }

  static Future<Response> putRequest(
    String url, {
    Map<String, dynamic>? data,
    Options? options,
  }) {
    return _guard(() => dio.put(url, data: data, options: options));
  }

  static Future<Response> postRequest(
    String url,
    Map<String, dynamic> data, {
    Options? options,
  }) {
    return _guard(() => dio.post(url, data: data, options: options));
  }

  static Future<Response> _guard(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
