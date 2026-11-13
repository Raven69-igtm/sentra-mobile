class LaporanModel {
  final String id;
  final String kategori;
  final String deskripsi;
  final String status;
  final DateTime createdAt;

  /// Jenis layanan PJSRK: rehabilitasi_sosial, permasalahan_sosial, atau
  /// pengaduan_bencana.
  final String layanan;

  /// Alamat kejadian dari detail_pjsrk (fallback ke detail_kasus).
  final String lokasi;

  /// URL foto lampiran dari detail_pjsrk.foto_urls.
  final List<String> fotoUrls;

  LaporanModel({
    required this.id,
    required this.kategori,
    required this.deskripsi,
    required this.status,
    required this.createdAt,
    this.layanan = '',
    this.lokasi = '',
    this.fotoUrls = const [],
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    final dynamic penerima = json['detail_penerima_manfaat'];
    final dynamic kasus = json['detail_kasus'];
    final Map<String, dynamic>? pjsrk = _asMap(json['detail_pjsrk']);
    final Map<String, dynamic>? kasusMap = _asMap(kasus);

    return LaporanModel(
      id: json['id_laporan']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      deskripsi: _resolveDeskripsi(json, penerima, pjsrk, kasusMap),
      status: json['status']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      layanan: json['layanan_pjsrk']?.toString() ?? '',
      lokasi: _resolveLokasi(json, pjsrk, kasusMap),
      fotoUrls: _resolveFotoUrls(pjsrk),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  /// Judul laporan yang tampil di daftar & detail.
  ///
  /// Admin Dinsos memakai kolom laporan.judul, jadi mobile ikut memakainya
  /// supaya teks laporan sama dengan yang dibaca petugas.
  static String _resolveDeskripsi(
    Map<String, dynamic> json,
    dynamic penerima,
    Map<String, dynamic>? pjsrk,
    Map<String, dynamic>? kasus,
  ) {
    final judul = json['judul']?.toString().trim() ?? '';
    if (judul.isNotEmpty) return judul;

    if (penerima is Map) {
      final nama = penerima['nama']?.toString().trim() ?? '';
      if (nama.isNotEmpty) return nama;
    }

    final jenis = [
      pjsrk?['jenis_permasalahan'],
      pjsrk?['jenis_rehabilitasi'],
      pjsrk?['jenis_bencana'],
    ]
        .map((e) => e?.toString().trim() ?? '')
        .firstWhere((e) => e.isNotEmpty, orElse: () => '');
    if (jenis.isNotEmpty) return jenis;

    final kronologi = kasus?['kronologi']?.toString().trim() ?? '';
    if (kronologi.isNotEmpty) return kronologi;

    final kategori = json['kategori']?.toString().trim() ?? '';
    if (kategori.isNotEmpty) return kategori;

    return 'N/A';
  }

  static String _resolveLokasi(
    Map<String, dynamic> json,
    Map<String, dynamic>? pjsrk,
    Map<String, dynamic>? kasus,
  ) {
    final alamat = pjsrk?['alamat']?.toString().trim() ?? '';
    if (alamat.isNotEmpty) return alamat;

    final wilayah = <String>[
      pjsrk?['kelurahan']?.toString().trim() ?? '',
      pjsrk?['kecamatan']?.toString().trim() ?? '',
    ].where((e) => e.isNotEmpty).join(', ');
    if (wilayah.isNotEmpty) return wilayah;

    final tempat = kasus?['tempat_kejadian']?.toString().trim() ?? '';
    if (tempat.isNotEmpty) return tempat;

    return json['kecamatan']?.toString().trim() ?? '';
  }

  static List<String> _resolveFotoUrls(Map<String, dynamic>? pjsrk) {
    final urls = pjsrk?['foto_urls'];
    if (urls is! List) return const [];

    return urls
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Label layanan PJSRK yang mudah dibaca.
  String get layananLabel {
    switch (layanan) {
      case 'rehabilitasi_sosial':
        return 'Rehabilitasi Sosial';
      case 'permasalahan_sosial':
        return 'Permasalahan Sosial';
      case 'pengaduan_bencana':
        return 'Pengaduan Bencana';
      default:
        return kategori.isNotEmpty ? kategori : 'Laporan';
    }
  }
}