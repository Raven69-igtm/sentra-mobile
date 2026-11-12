import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/features/dashboard/models/info_model.dart';

class InformasiService {
  static const String baseUrl =
      '${ApiClient.protocol}://${ApiClient.baseUrl}/api';
  final Dio _dio = Dio();

  Future<List<Informasi>> fetchInformasi() async {
    final response = await ApiClient.getRequest('/informasi');
    final body = response.data;
    if (body is! Map || body['data'] is! List) {
      throw ApiException(message: 'Respons informasi tidak valid.');
    }
    return (body['data'] as List)
        .whereType<Map>()
        .map((item) => Informasi.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
