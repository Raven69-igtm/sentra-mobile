import 'dart:convert';

import 'package:sentra/core/network/api_client.dart';

/// Menyamakan data foto PJSRK dari API dengan URL yang bisa diakses mobile.
///
/// API mengirim dua bentuk pada `detail_pjsrk`:
/// - `foto_urls`: URL absolut hasil `asset()` di Laravel
/// - `foto`: nama berkas di `public/uploads/pjsrk/{id_laporan}`
///
/// `asset()` mengikuti host request API. Saat backend dijalankan di komputer
/// pengembang, host bisa berupa `localhost`/`127.0.0.1` yang tidak bisa
/// diakses perangkat mobile. Karena itu host lokal diganti dengan origin API
/// yang dipakai aplikasi, dan base path (mis. `/public`) ikut disesuaikan.
class PjsrkPhotoUrls {
  const PjsrkPhotoUrls._();

  static const Set<String> _localHosts = {'localhost', '127.0.0.1', '0.0.0.0'};

  static List<String> resolve(dynamic detailPjsrk, {String? idLaporan}) {
    final Map<String, dynamic>? pjsrk = _asMap(detailPjsrk);
    if (pjsrk == null) return const [];

    final String id =
        (idLaporan ?? pjsrk['id_laporan']?.toString() ?? '').trim();

    final List<String> urls =
        _asFileList(pjsrk['foto_urls'])
            .map((url) => _normalize(url, id))
            .where((url) => url.isNotEmpty)
            .toList();
    if (urls.isNotEmpty) return urls;

    final List<String> files = _asFileList(pjsrk['foto']);
    if (id.isEmpty) return const [];

    return files
        .map((file) => _buildFromFile(id, file))
        .where((url) => url.isNotEmpty)
        .toList();
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  /// Kolom JSON di backend bisa terkirim sebagai List atau string JSON.
  static List<String> _asFileList(dynamic value) {
    dynamic decoded = value;

    if (decoded is String) {
      final String text = decoded.trim();
      if (text.isEmpty) return const [];
      try {
        decoded = jsonDecode(text);
      } catch (_) {
        return [text];
      }
    }

    if (decoded is Map) {
      // Kolom JSON dengan key tidak berurutan bisa terkirim sebagai objek.
      decoded = decoded.values.toList();
    }

    if (decoded is! List) return const [];

    return decoded
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static String _normalize(String value, String idLaporan) {
    final String raw = value.trim();
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      return _buildFromFile(idLaporan, raw);
    }

    final Uri? uri = Uri.tryParse(raw);
    final Uri? api = Uri.tryParse(ApiClient.apiOrigin);
    if (uri == null || api == null) return raw;

    final bool localHost = _localHosts.contains(uri.host);
    if (!localHost && uri.host != api.host) return raw;

    final String apiBasePath = _trimSlash(api.path);
    final bool originDifferent = uri.origin != api.origin;
    final bool basePathMissing =
        apiBasePath.isNotEmpty &&
        uri.path.startsWith('/uploads/') &&
        !uri.path.startsWith('$apiBasePath/');
    if (!originDifferent && !basePathMissing) return raw;

    final int uploadIndex = uri.path.indexOf('/uploads/');
    final String path =
        uploadIndex >= 0 ? uri.path.substring(uploadIndex) : uri.path;

    return api
        .replace(
          path: '$apiBasePath$path',
          query: uri.query.isEmpty ? null : uri.query,
        )
        .toString();
  }

  static String _buildFromFile(String idLaporan, String file) {
    final String raw = file.trim();
    if (raw.isEmpty || idLaporan.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return _normalize(raw, idLaporan);
    }

    final String name = raw.split(RegExp(r'[\\/]')).last;
    if (name.isEmpty) return '';

    return '${ApiClient.apiOrigin}/uploads/pjsrk/$idLaporan/$name';
  }

  static String _trimSlash(String path) {
    if (path.isEmpty || path == '/') return '';
    return path.endsWith('/') ? path.substring(0, path.length - 1) : path;
  }
}
