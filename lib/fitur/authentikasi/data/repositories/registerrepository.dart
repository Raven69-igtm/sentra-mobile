import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/usermodel.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class RegisterRepository {
  Future<UserModel?> register({
    required String notelp,
    required String nama,
    required String password,
    required String emergencyQuestion,
    required String answer,
    required String gender,
    required String alamat
  }) async {
    try {
      Response response = await ApiClient.postRequest(Endpoints.register, {
        'notelp': notelp,
        'nama': nama,
        'password': password,
        'role': "user",
        'emerquest': emergencyQuestion,
        'answquest': answer,
        'gender': gender,
        'alamat':alamat
      });

      if (response.statusCode == 200) {
        // Periksa apakah 'user' ada dan tidak null
        if (response.data['message'] != null) {
          print(response.data['message']);
          return null;
        } else {
          throw Exception('Gagal Daftar');
        }
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      debugPrint('Error saat register: $e', wrapWidth: 1024);
      throw Exception("Register gagal: $e");
    }
  }
}
