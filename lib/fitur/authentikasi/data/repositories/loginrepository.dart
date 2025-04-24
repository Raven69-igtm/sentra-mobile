import 'package:dio/dio.dart';
import '../models/usermodel.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class LoginRepository {
  Future<UserModel?> login(String notelp, String password) async {
    try {
      Response response = await ApiClient.postRequest(Endpoints.login, {
        'notelp': notelp,
        'password': password,
      });

      if (response.statusCode == 200) {
        if (response.data['user'] != null) {
          print(response.data['user']);
          return UserModel.fromJson(response.data['user']);
        } else {
          throw Exception('User data not found');
        }
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      print(e);
      throw Exception("Login gagal: $e");
    }
  }
}
