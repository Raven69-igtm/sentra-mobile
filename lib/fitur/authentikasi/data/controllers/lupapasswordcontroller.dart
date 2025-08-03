import 'package:sentra/fitur/authentikasi/data/repositories/lupapasswordrepository.dart';
import 'package:flutter/material.dart'; // Pastikan path file repository benar

class LupaPasswordController extends ChangeNotifier {
  final LupaPasswordRepository _repository = LupaPasswordRepository();

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  // Fungsi untuk mengganti nomor telepon
  Future<void> gantiNomor(String notelpLama, String notelpBaru,String answ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.gantiNomor(notelpLama, notelpBaru,answ);

    _isLoading = false;
    notifyListeners();

    if (result['error'] != null && result['error']) {
      _errorMessage = result['message'];
      _successMessage = '';
    } else {
      _errorMessage = '';
      _successMessage =
          'Nomor telepon berhasil diganti!';
    }

    notifyListeners();
  }

  // Fungsi untuk verifikasi OTP
  Future<void> verifikasiOtp(String notelpBaru, String otp) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.verifikasiOtp(notelpBaru, otp);

    _isLoading = false;
    notifyListeners();

    if (result['error'] != null && result['error']) {
      _errorMessage = result['message'];
      _successMessage = '';
    } else {
      _errorMessage = '';
      _successMessage =
          'OTP berhasil diverifikasi! Silakan buat password baru.';
    }

    notifyListeners();
  }

  // Fungsi untuk update password
  Future<void> updatePassword(String notelp,String password, String password2) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.updatePassword(notelp ,password,password2);

    _isLoading = false;
    notifyListeners();

    if (result['error'] != null && result['error']) {
      _errorMessage = result['message'];
      _successMessage = '';
    } else {
      _errorMessage = '';
      _successMessage = 'Password berhasil diubah!';
    }

    notifyListeners();
  }
}
