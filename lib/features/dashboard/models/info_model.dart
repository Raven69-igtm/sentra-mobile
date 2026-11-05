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
      id: json['id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
      tanggal: json['tanggal'],
      waktu: json['waktu'],
    );
  }
}
