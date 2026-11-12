import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/core/network/endpoints.dart';

class RegisterRepository {
  Future<String> register({
    required String notelp,
    required String nama,
    required String password,
    required String emergencyQuestion,
    required String answer,
    required String gender,
    required String alamat,
  }) async {
    final response = await ApiClient.postRequest(Endpoints.register, {
      'notelp': notelp.trim(),
      'nama': nama.trim(),
      'password': password,
      'role': 'user',
      'emerquest': emergencyQuestion,
      'answquest': answer.trim(),
      'gender': gender,
      'alamat': alamat.trim(),
    });

    final data = response.data;
    if (data is Map && data['success'] == true) {
      return data['message'] as String? ?? 'Akun berhasil dibuat';
    }

    throw ApiException(
      message:
          data is Map && data['message'] is String
              ? data['message'] as String
              : 'Pendaftaran gagal.',
      statusCode: response.statusCode,
    );
  }
}
