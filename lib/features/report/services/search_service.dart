import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/core/network/endpoints.dart';

class SearchService {
  Future<List<dynamic>> fetchSearchResults(
    String keyword,
    int? id, {
    String? scope,
  }) async {
    final response = await ApiClient.getRequest(
      Endpoints.searchReports,
      params: {
        'keyword': keyword,
        'id_akun': id,
        if (scope != null && scope.isNotEmpty) 'scope': scope,
      },
    );
    final data = response.data;
    if (data is List) return data;
    throw ApiException(message: 'Respons pencarian tidak valid.');
  }
}
