import 'package:sentra/core/network/response_model.dart';
import 'package:flutter/material.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/features/auth/repositories/register_repository.dart';

class RegisterController with ChangeNotifier {
  final RegisterRepository _registerRepository = RegisterRepository();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ResponseModel> register(
    String notelp,
    String nama,
    String password,
    String question,
    String answer,
    String gender,
    String alamat,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final message = await _registerRepository.register(
        notelp: notelp,
        nama: nama,
        password: password,
        emergencyQuestion: question,
        answer: answer,
        gender: gender,
        alamat: alamat,
      );
      return ResponseModel(success: true, message: message);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return ResponseModel(success: false, message: e.message);
    } catch (_) {
      _errorMessage = 'Pendaftaran gagal. Silakan coba lagi.';
      return ResponseModel(
        success: false,
        message: 'Pendaftaran gagal. Silakan coba lagi.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
