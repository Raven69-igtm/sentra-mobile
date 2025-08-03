import 'package:sentra/fitur/authentikasi/data/models/usermodel.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  String? get role => _user?.role;
  int? get idAkun => _user?.id;

  
  void setUser(UserModel newUser) {
    _user = newUser;
    notifyListeners();
  }

  
  void clearUser() {
    print("Clearing user...");
    _user = null;
    print(_user?.nama);
    notifyListeners();
  }
}
