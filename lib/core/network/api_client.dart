import 'package:dio/dio.dart';

class ApiClient {
  static const bool isLocal = true;
  static const String protocol = isLocal ? 'http' : 'https';
  static const String baseUrl = isLocal ? '127.0.0.1:8000' : 'sentra.pbltifnganjuk.com/public';
  static const String wsUrl = isLocal ? 'ws://127.0.0.1:3021' : 'ws://18.136.209.83:3021';

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "$protocol://$baseUrl/api",
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<Response> getRequest(
    String url, {
    Map<String, dynamic>? params,
  }) async {
    try {
      return await dio.get(url, queryParameters: params);
    } catch (e) {
      throw Exception("Failed to load data");
    }
  }
  static Future<Response> putRequest(
    String url, {
    Map<String, dynamic>? data,
  }) async {
    try {
      return await dio.put(url, data: data);
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
    } catch (e) {
      throw Exception("Failed to send data.$e");
    }
  }
}
