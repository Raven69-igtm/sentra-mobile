import 'package:flutter/material.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/features/auth/repositories/login_repository.dart';
import 'package:sentra/features/auth/models/user_model.dart';

class LoginController with ChangeNotifier {
  final LoginRepository _loginRepository = LoginRepository();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String notelp, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _loginRepository.login(notelp, password);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Login gagal. Silakan coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
