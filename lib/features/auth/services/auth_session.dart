import 'package:dio/dio.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/core/network/endpoints.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/auth/preferences/account_prefs.dart';

/// Pengelola sesi aplikasi.
///
/// Login mobile menerbitkan token Sanctum yang disimpan terenkripsi di
/// `FlutterSecureStorage` melalui [AkunPrefs] dan dipasang ke [ApiClient].
/// Validasi sesi menggunakan endpoint terautentikasi `GET /user`.
class AuthSession {
  static const Duration _validateTimeout = Duration(seconds: 5);

  static Future<UserModel?> restoreCached() async {
    final data = await AkunPrefs.getAkun();
    final id = int.tryParse(data['id_akun'] ?? '') ?? 0;
    final notelp = data['notelp'] ?? '';
    final token = await AkunPrefs.getToken();

    if (id <= 0 || notelp.isEmpty || token == null || token.isEmpty) {
      return null;
    }

    ApiClient.setAuthToken(token);

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
  /// - Token Sanctum valid (`200`): data profil terbaru dikembalikan dan disimpan.
  /// - Server menjawab `401` / `403` / `404`: sesi tidak valid, data lokal dihapus.
  /// - Gagal jaringan: sesi lokal tetap dipakai agar aplikasi bisa dibuka
  ///   offline; error data akan ditampilkan oleh masing-masing fitur.
  static Future<UserModel?> restore() async {
    final cached = await restoreCached();
    if (cached == null) {
      await clear();
      return null;
    }

    try {
      final fresh = await refreshProfile();
      if (fresh == null) {
        await clear();
        return null;
      }
      await persist(fresh);
      return fresh;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403 || e.statusCode == 404) {
        await clear();
        return null;
      }
      return cached;
    } catch (_) {
      return cached;
    }
  }

  /// Mengambil data akun terbaru dari `GET /user` menggunakan token Sanctum aktif.
  /// Mengembalikan `null` bila sesi tidak valid (401/403/404).
  static Future<UserModel?> refreshProfile([String? _legacyNotelp]) async {
    final token = ApiClient.authToken ?? await AkunPrefs.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    ApiClient.setAuthToken(token);

    try {
      final response = await ApiClient.getRequest(
        Endpoints.currentUser,
        options: Options(
          sendTimeout: _validateTimeout,
          receiveTimeout: _validateTimeout,
        ),
      );

      final data = response.data;
      if (data is Map) {
        final rawUser = data['user'] is Map ? data['user'] as Map : data;
        if (rawUser['id_akun'] != null) {
          return UserModel.fromJson(Map<String, dynamic>.from(rawUser));
        }
      }
      throw ApiException(
        message: 'Respons data akun dari server tidak valid.',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403 || e.statusCode == 404) {
        return null;
      }
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
