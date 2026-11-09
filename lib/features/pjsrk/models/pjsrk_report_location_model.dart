/// MODEL: data langkah 2 (Lokasi) pada pengaduan bencana PJSRK.
class PjsrkReportLocationModel {
  final String alamat;
  final String kelurahan;
  final String kecamatan;
  final String patokan;
  final double latitude;
  final double longitude;
  final List<String> foto;
  final String kontak;

  const PjsrkReportLocationModel({
    required this.alamat,
    required this.kelurahan,
    required this.kecamatan,
    required this.patokan,
    required this.latitude,
    required this.longitude,
    required this.foto,
    required this.kontak,
  });

  Map<String, dynamic> toMap() => {
        'alamat': alamat,
        'kelurahan': kelurahan,
        'kecamatan': kecamatan,
        'patokan_lokasi': patokan,
        'latitude': latitude,
        'longitude': longitude,
        'foto': foto,
        'kontak': kontak,
      };
}