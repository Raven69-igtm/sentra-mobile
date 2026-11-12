/// MODEL: data laporan rehabilitasi sosial PJSRK yang siap dikirim ke API.
class PjsrkRehabModel {
  final String jenisRehabilitasi;
  final int jumlahPenerima;
  final String jenisKelamin;
  final String kelompokUsia;
  final String kondisiSaatDitemukan;
  final String ciriCiri;
  final bool rahasia;
  final String alamat;
  final double latitude;
  final double longitude;
  final String kontak;

  const PjsrkRehabModel({
    required this.jenisRehabilitasi,
    required this.jumlahPenerima,
    required this.jenisKelamin,
    required this.kelompokUsia,
    required this.kondisiSaatDitemukan,
    required this.ciriCiri,
    required this.rahasia,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.kontak,
  });

  Map<String, dynamic> toMap() => {
        'jenis_rehabilitasi': jenisRehabilitasi,
        'jumlah_penerima': jumlahPenerima,
        'jenis_kelamin': jenisKelamin,
        'kelompok_usia': kelompokUsia,
        'kondisi_saat_ditemukan': kondisiSaatDitemukan,
        'ciri_ciri': ciriCiri,
        'rahasia': rahasia,
        'alamat': alamat,
        'latitude': latitude,
        'longitude': longitude,
        'kontak': kontak,
      };
}
