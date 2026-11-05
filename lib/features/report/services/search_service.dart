import 'package:dio/dio.dart';
import 'package:sentra/core/network/api_client.dart';

class SearchService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: '${ApiClient.protocol}://${ApiClient.baseUrl}',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<List<dynamic>?> fetchSearchResults(String keyword,int? id) async {
    try {
      final response = await _dio.get(
        '/api/search?',
        queryParameters: {'keyword': keyword,'id_akun': id},
      );
      print('Search response: ${response.data}');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        print('Failed to fetch search results: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching search results: $e');
      return null;
    }
  }
}
