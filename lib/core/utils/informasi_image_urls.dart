import 'package:sentra/core/network/api_client.dart';

/// Menyamakan URL gambar "Informasi Terkini" dari API dengan URL yang bisa
/// diakses aplikasi mobile.
///
/// API mengirim URL absolut hasil `asset()` di Laravel. Nilainya mengikuti
/// host request API, sehingga bisa berupa:
/// - `http://127.0.0.1:8000/uploads/informasi/...` saat backend lokal, atau
/// - `https://domain/public/uploads/informasi/...` saat produksi.
///
/// Helper ini mengganti host lokal dengan origin API yang dipakai aplikasi
/// dan menambahkan base path (mis. `/public`) bila belum ada.
class InformasiImageUrls {
  const InformasiImageUrls._();

  static const Set<String> _localHosts = {'localhost', '127.0.0.1', '0.0.0.0'};

  static String? resolve(String? value) {
    final String raw = (value ?? '').trim();
    if (raw.isEmpty) return null;

    final Uri? uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) {
      return _buildFromFile(raw);
    }

    final Uri? api = Uri.tryParse(ApiClient.apiOrigin);
    if (api == null) return raw;

    final bool localHost = _localHosts.contains(uri.host);
    if (!localHost && uri.host != api.host) return raw;

    // apiOrigin seharusnya origin tanpa `/api`, tetapi tetap robust bila
    // konfigurasi menyertakan suffix tersebut.
    final String apiPath = _trimSlash(api.path);
    final String apiBasePath = apiPath.endsWith('/api')
        ? _trimSlash(apiPath.substring(0, apiPath.length - 4))
        : apiPath;
    final int uploadIndex = uri.path.indexOf('/uploads/');
    final String path =
        uploadIndex >= 0 ? uri.path.substring(uploadIndex) : uri.path;

    final bool basePathMissing = apiBasePath.isNotEmpty &&
        path.startsWith('/uploads/') &&
        !path.startsWith('$apiBasePath/');

    if (uri.origin == api.origin && !basePathMissing) return raw;

    return api
        .replace(
          path: '$apiBasePath$path',
          query: uri.query.isEmpty ? null : uri.query,
        )
        .toString();
  }

  static String _buildFromFile(String file) {
    final String name = file.split(RegExp(r'[\\/]')).last;
    if (name.isEmpty) return '';
    return '${ApiClient.apiOrigin}/uploads/informasi/$name';
  }

  static String _trimSlash(String path) {
    if (path.isEmpty || path == '/') return '';
    return path.endsWith('/') ? path.substring(0, path.length - 1) : path;
  }
}
