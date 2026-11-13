class LaporanModel {
  final String id;
  final String kategori;
  final String deskripsi;
  final String status;
  final DateTime createdAt;

  LaporanModel({
    required this.id,
    required this.kategori,
    required this.deskripsi,
    required this.status,
    required this.createdAt,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    final dynamic penerima = json['detail_penerima_manfaat'];
    return LaporanModel(
      id: json['id_laporan']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      deskripsi:
          penerima is Map
              ? penerima['nama']?.toString() ?? 'N/A'
              : penerima?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
