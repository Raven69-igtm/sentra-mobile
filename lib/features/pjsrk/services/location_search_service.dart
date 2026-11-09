import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:sentra/features/pjsrk/models/location_search_result.dart';

/// Dilempar saat pencarian gagal (jaringan, timeout, respons tidak valid).
/// UI cukup menampilkan "Gagal mencari lokasi".
class LocationSearchException implements Exception {
  final String message;
  const LocationSearchException(this.message);

  @override
  String toString() => 'LocationSearchException: $message';
}

/// Pencarian alamat/tempat lewat OpenStreetMap Nominatim.
///
/// Murni logic jaringan: tanpa GPS, tanpa permission, tanpa dependensi UI.
/// Catatan kebijakan Nominatim: maksimal 1 request/detik, karena itu pemanggil
/// wajib memakai debounce (lihat RehabLocationField).
class LocationSearchService {
  LocationSearchService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const String _host = 'nominatim.openstreetmap.org';
  static const Duration _timeout = Duration(seconds: 10);

  /// Query lebih pendek dari ini tidak dikirim ke API.
  static const int minQueryLength = 3;

  Future<List<LocationSearchResult>> search(String query) async {
    final q = query.trim();
    if (q.length < minQueryLength) return const [];

    final uri = Uri.https(_host, '/search', {
      'q': q,
      'format': 'json',
      'addressdetails': '1',
      'limit': '5',
      // Aplikasi untuk wilayah Indonesia (DPPPA Nganjuk).
      'countrycodes': 'id',
      'accept-language': 'id',
    });

    // Browser melarang pengaturan header User-Agent; di Web header itu
    // dikirim otomatis oleh browser. Di mobile/desktop kita identifikasi app.
    final headers = <String, String>{
      if (!kIsWeb) 'User-Agent': 'SentraMobile/1.0 (DPPPA Nganjuk)',
    };

    try {
      final response =
          await _client.get(uri, headers: headers).timeout(_timeout);

      if (response.statusCode != 200) {
        throw LocationSearchException('HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) {
        throw const LocationSearchException('Format respons tidak valid');
      }

      return decoded
          .map(LocationSearchResult.tryParse)
          .whereType<LocationSearchResult>()
          .toList(growable: false);
    } on LocationSearchException {
      rethrow;
    } on Exception catch (e) {
      // TimeoutException, ClientException, FormatException, dsb.
      throw LocationSearchException(e.toString());
    }
  }

  void dispose() => _client.close();
}
