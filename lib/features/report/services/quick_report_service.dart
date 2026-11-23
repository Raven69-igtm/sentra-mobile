import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';

class LaporanCepatService {
  /// [idAkun] boleh null: Laporan Cepat dapat dikirim tanpa login dan akan
  /// dicatat pada akun pelapor anonim oleh backend.
  Future<Map<String, dynamic>> kirimLaporanCepat({
    int? idAkun,
    required String nik,
    required String nama,
    required String noTelp,
    required String alamat,
    required String deskripsi,
  }) async {
    try {
      final payload = <String, dynamic>{
        // Hanya dikirim bila user sedang login. Tanpa id_akun, backend
        // mencatat laporan pada akun pelapor anonim (role guest).
        if (idAkun != null) 'id_akun': idAkun,
        'nik': nik,
        'nama': nama,
        'no_telp': noTelp,
        'alamat': alamat,
        'deskripsi': deskripsi,
      };
      final response = await ApiClient.postRequest('/laporan-cepat', payload);

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
