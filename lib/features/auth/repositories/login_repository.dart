import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/core/network/endpoints.dart';

class LoginRepository {
  Future<UserModel> login(String notelp, String password) async {
    final response = await ApiClient.postRequest(Endpoints.login, {
      'notelp': notelp.trim(),
      'password': password,
    });

    final data = response.data;
    if (data is Map && data['user'] is Map) {
      return UserModel.fromJson(
        Map<String, dynamic>.from(data['user'] as Map),
      );
    }

    throw ApiException(
      message: 'Respons login dari server tidak valid.',
      statusCode: response.statusCode,
    );
  }
}
