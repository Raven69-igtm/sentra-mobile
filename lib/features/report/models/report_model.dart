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
    return LaporanModel(
      id: json['id_laporan'] ?? 0,
      kategori: json['kategori'] ?? '',
      deskripsi:
          json['detail_penerima_manfaat'] is Map
              ? json['detail_penerima_manfaat']['nama']?.toString() ?? 'N/A'
              : json['detail_penerima_manfaat']?.toString() ?? 'N/A',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
