import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/features/auth/models/user_model.dart';

class ProfileRepository {
  Future<String> updateAkun(String id, UserModel akun) async {
    final response = await ApiClient.putRequest(
      '/auth/edit/$id',
      data: akun.toJson(),
    );
    final data = response.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Akun berhasil diperbarui';
  }
}
