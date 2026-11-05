import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/endpoints.dart';



class LupaPasswordRepository {
  // 1. Request untuk mengganti nomor telepon
  Future<Map<String, dynamic>> gantiNomor(
    String notelpLama,
    String notelpBaru,
    String answ
  ) async {
    try {
      final response = await ApiClient.postRequest(Endpoints.updatenomor, {
        'notelp_lama': notelpLama,
        'notelp_baru': notelpBaru,
        'answquest' : answ,
      });

      return response.data;
    } catch (e) {
      return {'error': true, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // 2. Verifikasi OTP
  Future<Map<String, dynamic>> verifikasiOtp(
    String notelpBaru,
    String otp,
  ) async {
    try {
      final response = await ApiClient.postRequest(Endpoints.verifikasiOTP, {
        'notelp': notelpBaru,
        'otp': otp,
      });

      return response.data;
    } catch (e) {
      return {'error': true, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // 3. Update password
  Future<Map<String, dynamic>> updatePassword(
    String notelpBaru,
    String password,
    String password2
  ) async {
    try {
      final response = await ApiClient.postRequest(Endpoints.ubahpassword, {
        'notelp': notelpBaru,
        'password': password,
        'password2': password2,
      });

      return response.data;
    } catch (e) {
      return {'error': true, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
