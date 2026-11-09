/// Satu hasil pencarian lokasi (dipetakan dari respons OpenStreetMap Nominatim).
///
/// Mapping:
///   display_name -> [displayName] (dipakai sebagai address)
///   lat          -> [latitude]
///   lon          -> [longitude]
class LocationSearchResult {
  final String displayName;
  final double latitude;
  final double longitude;

  const LocationSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  /// Mengembalikan null jika data tidak lengkap / koordinat tidak valid,
  /// sehingga hasil rusak tidak pernah tampil di daftar autocomplete.
  static LocationSearchResult? tryParse(Object? json) {
    if (json is! Map) return null;

    final name = json['display_name'];
    // Nominatim mengirim lat/lon sebagai String, tetapi num juga ditangani.
    final lat = _toDouble(json['lat']);
    final lon = _toDouble(json['lon']);

    if (name is! String || name.trim().isEmpty) return null;
    if (lat == null || lon == null) return null;
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;

    return LocationSearchResult(
      displayName: name.trim(),
      latitude: lat,
      longitude: lon,
    );
  }

  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Bagian pertama alamat (mis. "Jalan Dhoho") untuk baris judul di daftar.
  String get title {
    final i = displayName.indexOf(',');
    return i == -1 ? displayName : displayName.substring(0, i).trim();
  }

  /// Sisa alamat (mis. "Payaman, Nganjuk, Jawa Timur") untuk baris kedua.
  String get subtitle {
    final i = displayName.indexOf(',');
    return i == -1 ? '' : displayName.substring(i + 1).trim();
  }

  /// Bentuk data lokasi yang siap dikirim ke backend nanti.
  Map<String, dynamic> toJson() => {
        'address': displayName,
        'latitude': latitude,
        'longitude': longitude,
      };
}
