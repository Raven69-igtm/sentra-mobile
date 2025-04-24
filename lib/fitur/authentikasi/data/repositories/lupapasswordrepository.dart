import 'package:SENTRA/core/network/api_client.dart';

class AuthForgotRepository {
  Future<void> forgotPassword(String notelp) async {
    try {
      await ApiClient.postRequest('/forgot-password', {'notelp': notelp});
    } catch (e) {
      throw Exception("Lupa password gagal: ${e.toString()}");
    }
  }

  Future<void> resetPassword(String notelp, String otp, String password) async {
    try {
      await ApiClient.postRequest('/reset-password', {
        'notelp': notelp,
        'otp': otp,
        'password': password,
      });
    } catch (e) {
      throw Exception("Reset password gagal: ${e.toString()}");
    }
  }

  Future<void> emergencyCheck(String notelp, String answer) async {
    try {
      await ApiClient.postRequest('/emergency-check', {
        'notelp': notelp,
        'answer': answer,
      });
    } catch (e) {
      throw Exception("Verifikasi darurat gagal: ${e.toString()}");
    }
  }
}
