import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';

class SearchService {
  Future<List<dynamic>> fetchSearchResults(String keyword, int? id) async {
    final response = await ApiClient.getRequest(
      '/search',
      params: {'keyword': keyword, 'id_akun': id},
    );
    final data = response.data;
    if (data is List) return data;
    throw ApiException(message: 'Respons pencarian tidak valid.');
  }
}
