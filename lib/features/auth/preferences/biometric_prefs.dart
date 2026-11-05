import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BioPrefs {
  static const String _keyNoHP = 'notelp';
  static final _storage = FlutterSecureStorage();

  static Future<void> simpanAkun({required String? noHP}) async {
    if (noHP != null && noHP.isNotEmpty) {
      await _storage.write(key: _keyNoHP, value: noHP);
      print("Saved noHP to secure storage: $noHP");
    } else {
      print("Error: noHP is null or empty, not saving");
    }
  }

  static Future<Map<String, String?>> getAkun() async {
    String? notelp = await _storage.read(key: _keyNoHP);
    print("Retrieved notelp: $notelp");
    return {'notelp': notelp};
  }

  static Future<void> hapusAkun() async {
    print("BioPrefs: Not removing notelp to support biometric login");
  }
}
