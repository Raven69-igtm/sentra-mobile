import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/features/dashboard/models/info_model.dart';
import 'package:dio/dio.dart';

class InformasiService {
  static const String baseUrl =
      '${ApiClient.protocol}://${ApiClient.baseUrl}/api';
  final Dio _dio = Dio();

  Future<List<Informasi>> fetchInformasi() async {
    try {
      final response = await _dio.get('$baseUrl/informasi');
      if (response.statusCode == 200) {
        final json = response.data;
        final List<dynamic> data = json['data'];
        return data.map((item) => Informasi.fromJson(item)).toList();
      } else {
        throw Exception(
          'Gagal mengambil data informasi: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching informasi: $e');
    }
  }
}
