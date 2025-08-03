import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/fitur/dashboard/data/models/informasimodel.dart';
import 'package:dio/dio.dart';

class InformasiService {
  static const String baseUrl =
      'https://${ApiClient.baseUrl}/api'; // Ganti dengan URL server kamu
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
