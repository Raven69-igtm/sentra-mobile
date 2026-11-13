import 'package:dio/dio.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/auth/preferences/account_prefs.dart';

/// Pengelola sesi aplikasi.
///
/// Login mobile menerbitkan token Sanctum. Token disimpan di preferensi dan
/// dipasang ke [ApiClient] agar endpoint terproteksi (mis. chat) mengenali
/// identitas pengguna dari backend, bukan dari payload frontend.
/// Validasi sesi memakai endpoint yang sudah ada: POST /auth/biometric.
class AuthSession {
  static const Duration _validateTimeout = Duration(seconds: 5);

  static Future<UserModel?> restoreCached() async {
    final data = await AkunPrefs.getAkun();
    final id = int.tryParse(data['id_akun'] ?? '') ?? 0;
    final notelp = data['notelp'] ?? '';
    if (id <= 0 || notelp.isEmpty) return null;

    ApiClient.setAuthToken(await AkunPrefs.getToken());

    return UserModel(
      id: id,
      nama: data['nama'] ?? '',
      notelp: notelp,
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      alamat: data['alamat'] ?? '',
      jeniskelamin: data['jenis_kelamin'] ?? '',
    );
  }

  /// Mengembalikan user yang sudah divalidasi/diperbarui dari server.
  ///
  /// - Server mengenali nomor telepon: data terbaru dikembalikan dan disimpan.
  /// - Server menjawab 404: sesi tidak valid, data lokal dihapus.
  /// - Gagal jaringan: sesi lokal tetap dipakai agar aplikasi bisa dibuka
  ///   offline; error data akan ditampilkan oleh masing-masing fitur.
  static Future<UserModel?> restore() async {
    final cached = await restoreCached();
    if (cached == null) return null;

    try {
      final fresh = await refreshProfile(cached.notelp!);
      if (fresh == null) {
        await AkunPrefs.hapusAkun();
        return null;
      }
      await persist(fresh);
      return fresh;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        await AkunPrefs.hapusAkun();
        return null;
      }
      return cached;
    } catch (_) {
      return cached;
    }
  }

  /// Mengambil data akun terbaru berdasarkan nomor telepon.
  /// Mengembalikan null bila akun tidak ditemukan di server.
  static Future<UserModel?> refreshProfile(String notelp) async {
    try {
      final response = await ApiClient.postRequest(
        '/auth/biometric',
        {'notelp': notelp},
        options: Options(
          sendTimeout: _validateTimeout,
          receiveTimeout: _validateTimeout,
        ),
      );

      final data = response.data;
      if (data is Map && data['user'] is Map) {
        final token = data['token'];
        if (token is String && token.isNotEmpty) {
          await AkunPrefs.simpanToken(token);
          ApiClient.setAuthToken(token);
        }
        return UserModel.fromJson(
          Map<String, dynamic>.from(data['user'] as Map),
        );
      }
      throw ApiException(
        message: 'Respons data akun dari server tidak valid.',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  static Future<void> persist(UserModel user) {
    return AkunPrefs.simpanAkun(
      idAkun: user.id?.toString(),
      nama: user.nama,
      jenisKelamin: user.jeniskelamin,
      alamat: user.alamat,
      email: user.email,
      noHP: user.notelp,
      role: user.role,
    );
  }

  static Future<void> clear() async {
    ApiClient.setAuthToken(null);
    await AkunPrefs.hapusAkun();
  }
}
