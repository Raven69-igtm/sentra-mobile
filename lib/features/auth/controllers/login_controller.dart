import 'package:flutter/material.dart';
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
  

  Future<void> login(String notelp, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _loginRepository.login(notelp, password);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
  Future<void> Biometric(String notelp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _loginRepository.Biometic(notelp);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
  Future<void> LoginEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _loginRepository.LoginEmail(email);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
  
}
