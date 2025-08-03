import 'package:dio/dio.dart';

class ApiClient {
  // static const String baseUrl = '10.0.2.2';
  static const String baseUrl = 'sentra.pbltifnganjuk.com/public';
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://$baseUrl/api",
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
