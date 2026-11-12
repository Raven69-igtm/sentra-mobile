import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';

class LaporanCepatService {
  Future<Map<String, dynamic>> kirimLaporanCepat({
    required int idAkun,
    required String nik,
    required String nama,
    required String noTelp,
    required String alamat,
    required String deskripsi,
  }) async {
    try {
      final response = await ApiClient.postRequest('/laporan-cepat', {
        'id_akun': idAkun,
        'nik': nik,
        'nama': nama,
        'no_telp': noTelp,
        'alamat': alamat,
        'deskripsi': deskripsi,
      });

      final data = response.data;
      if (data is Map && data['success'] == true) {
        return {'success': true, 'data': data['data']?['id_laporan']};
      }
      return {
        'success': false,
        'message':
            data is Map && data['message'] is String
                ? data['message'] as String
                : 'Laporan gagal dikirim.',
      };
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }
}
