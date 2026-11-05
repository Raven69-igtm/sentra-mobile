import 'package:shared_preferences/shared_preferences.dart';

class AkunPrefs {
  static const _keyAkun = 'id_akun';
  static const _keyNama = 'nama';
  static const _keyJenisKelamin = 'jenis_kelamin';
  static const _keyNoHP = 'notelp';
  static const _keyRole = 'role';
  static const _keyEmail = 'email';
  static const _keyAlamat = 'alamat';

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
    await prefs.setString(_keyAkun, idAkun!);
    await prefs.setString(_keyNama, nama!);
    await prefs.setString(_keyJenisKelamin, jenisKelamin!);
    await prefs.setString(_keyNoHP, noHP!);
    await prefs.setString(_keyRole, role!);
    await prefs.setString(_keyEmail, email!);
    await prefs.setString(_keyAlamat, alamat!);
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

  // Hapus data akun (misalnya saat logout)
  static Future<void> hapusAkun() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAkun);
    await prefs.remove(_keyNama);
    await prefs.remove(_keyJenisKelamin);
    await prefs.remove(_keyNoHP);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyAlamat);
  }
}
