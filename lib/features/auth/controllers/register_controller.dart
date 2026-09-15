import 'package:sentra/core/network/response_model.dart';
import 'package:flutter/material.dart';
import 'package:sentra/features/auth/repositories/register_repository.dart';
import 'package:sentra/features/auth/models/user_model.dart';

class RegisterController with ChangeNotifier {
  final RegisterRepository _registerRepository = RegisterRepository();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ResponseModel> register(
    String notelp,
    String nama,
    String password,
    String question,
    String answer,
    String gender,
    String alamat
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
     
      _user = await _registerRepository.register(
        notelp: notelp,
        nama: nama,
        password: password,
        emergencyQuestion: question,
        answer: answer,
        gender: gender,
        alamat: alamat
      );

      if (_user != null) {
        return ResponseModel(success: true, message: 'Pendaftaran berhasil');
      } else {
        return ResponseModel(success: false, message: 'Pendaftaran gagal');
      }
    } catch (e) {
      return ResponseModel(success: false, message: 'Terjadi kesalahan: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
