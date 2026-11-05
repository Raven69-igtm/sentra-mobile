import 'package:sentra/features/auth/repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:sentra/features/auth/models/user_model.dart';


class ProfileController with ChangeNotifier {
  final ProfileRepository repository;
  bool isLoading = false;
  String? message;

  ProfileController(this.repository);

  Future<void> updateAkun(String id, UserModel akun) async {
    isLoading = true;
    notifyListeners();

    try {
      message = await repository.updateAkun(id, akun);
    } catch (e) {
      message = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
