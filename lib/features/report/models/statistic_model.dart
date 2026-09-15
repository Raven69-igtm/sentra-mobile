class StatistikModel {
  final int totalLaporan;
  final int laporanSelesai;
  final int laporanDiproses;
  final int laporanDitolak;

  StatistikModel({
    this.totalLaporan = 0,
    this.laporanSelesai = 0,
    this.laporanDiproses = 0,
    this.laporanDitolak = 0,
  });

  factory StatistikModel.fromJson(Map<String, dynamic> json) {
    return StatistikModel(
      totalLaporan: json['total_laporan'] ?? 0,
      laporanSelesai: json['laporan_selesai'] ?? 0,
      laporanDiproses: json['laporan_diproses'] ?? 0,
      laporanDitolak: json['laporan_ditolak'] ?? 0,
    );
  }
}
