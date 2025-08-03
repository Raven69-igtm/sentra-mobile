import 'package:sentra/core/network/api_client.dart';
import 'package:dio/dio.dart';

class LaporanCepatService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://${ApiClient.baseUrl}/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Map<String, dynamic>> kirimLaporanCepat({
    required int idAkun,
    required String nik,
    required String nama,
    required String noTelp,
    required String alamat,
    required String deskripsi,
  }) async {
    try {
      final response = await _dio.post(
        '/laporan-cepat',
        data: {
          "id_akun": idAkun,
          "nik": nik,
          "nama": nama,
          "no_telp": noTelp,
          "alamat": alamat,
          "deskripsi": deskripsi,
        },
      );
      
      print("id ko service ki:${response.data}");
      return {'success': true , 'data': response.data['data']['id_laporan']};
    } on DioException catch (e) {
      
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Terjadi kesalahan.',
        };
      } else {
        print(e.response);
        return {
          'success': false,
          'message': 'Tidak dapat terhubung ke server.',
        };
      }
    }
  }
}
