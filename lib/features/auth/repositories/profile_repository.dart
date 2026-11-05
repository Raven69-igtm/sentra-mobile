import 'package:sentra/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:sentra/features/auth/models/user_model.dart';

class ProfileRepository {

  Future<String> updateAkun(String id, UserModel akun) async {
    try {
      final response = await ApiClient.putRequest('/auth/edit/$id', data: akun.toJson());
      return response.data['message'] ?? 'Akun berhasil diperbarui';
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Gagal memperbarui akun',
        );
      } else {
        throw Exception('Terjadi kesalahan jaringan');
      }
    }
  }
}
