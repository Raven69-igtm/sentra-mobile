class Informasi {
  final String? id;
  final String judul;
  final String deskripsi;
  final String? gambar;
  final String? tanggal;
  final String? waktu;

  Informasi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.gambar,
    this.tanggal,
    this.waktu,
  });

  factory Informasi.fromJson(Map<String, dynamic> json) {
    return Informasi(
      id: json['id']?.toString(),
      judul: (json['judul'] ?? '').toString(),
      deskripsi: (json['deskripsi'] ?? '').toString(),
      gambar: json['gambar']?.toString(),
      tanggal: json['tanggal']?.toString(),
      waktu: json['waktu']?.toString(),
    );
  }
}
