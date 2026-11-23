import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AkunPrefs {
  static const _keyAkun = 'id_akun';
  static const _keyNama = 'nama';
  static const _keyJenisKelamin = 'jenis_kelamin';
  static const _keyNoHP = 'notelp';
  static const _keyRole = 'role';
  static const _keyEmail = 'email';
  static const _keyAlamat = 'alamat';
  static const _keyToken = 'auth_token';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Simpan data akun
  static Future<void> simpanAkun({
    required String? idAkun,
    required String? nama,
    required String? jenisKelamin,
    required String? noHP,
    required String? role,
    required String? email,
    required String? alamat,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAkun, idAkun ?? '');
    await prefs.setString(_keyNama, nama ?? '');
    await prefs.setString(_keyJenisKelamin, jenisKelamin ?? '');
    await prefs.setString(_keyNoHP, noHP ?? '');
    await prefs.setString(_keyRole, role ?? '');
    await prefs.setString(_keyEmail, email ?? '');
    await prefs.setString(_keyAlamat, alamat ?? '');
  }

  // Ambil data akun
  static Future<Map<String, String?>> getAkun() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id_akun': prefs.getString(_keyAkun),
      'nama': prefs.getString(_keyNama),
      'jenis_kelamin': prefs.getString(_keyJenisKelamin),
      'notelp': prefs.getString(_keyNoHP),
      'role': prefs.getString(_keyRole),
      'email': prefs.getString(_keyEmail),
      'alamat': prefs.getString(_keyAlamat),
    };
  }

  // Simpan token Sanctum di FlutterSecureStorage (terenkripsi di perangkat).
  static Future<void> simpanToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    if (!kIsWeb) {
      try {
        await _secureStorage.write(key: _keyToken, value: token);
        // Hapus salinan lama di SharedPreferences agar tidak tersimpan plaintext.
        await prefs.remove(_keyToken);
        return;
      } on MissingPluginException {
        // Fallback untuk lingkungan widget/unit test tanpa native channel.
      } on PlatformException {
        // Fallback aman bila keystore perangkat sedang tidak tersedia.
      }
    }
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!kIsWeb) {
      try {
        final secureToken = await _secureStorage.read(key: _keyToken);
        if (secureToken != null && secureToken.isNotEmpty) {
          return secureToken;
        }

        // Migrasi otomatis token lama dari SharedPreferences ke SecureStorage.
        final legacyToken = prefs.getString(_keyToken);
        if (legacyToken != null && legacyToken.isNotEmpty) {
          await _secureStorage.write(key: _keyToken, value: legacyToken);
          await prefs.remove(_keyToken);
          return legacyToken;
        }
        return null;
      } on MissingPluginException {
        // Fallback lingkungan test.
      } on PlatformException {
        // Fallback keystore error.
      }
    }
    return prefs.getString(_keyToken);
  }

  // Hapus data akun dan token (misalnya saat logout atau sesi 401)
  static Future<void> hapusAkun() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAkun);
    await prefs.remove(_keyNama);
    await prefs.remove(_keyJenisKelamin);
    await prefs.remove(_keyNoHP);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyAlamat);
    await prefs.remove(_keyToken);

    if (!kIsWeb) {
      try {
        await _secureStorage.delete(key: _keyToken);
      } on MissingPluginException {
        // Abaikan di lingkungan test.
      } on PlatformException {
        // Abaikan error keystore saat logout.
      }
    }
  }
}
