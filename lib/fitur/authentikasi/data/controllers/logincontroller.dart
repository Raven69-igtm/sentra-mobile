import 'package:flutter/material.dart';
import '../repositories/loginrepository.dart';
import '../models/usermodel.dart';

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
}
