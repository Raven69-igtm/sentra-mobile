import 'package:sentra/core/utils/informasi_image_urls.dart';

class Informasi {
  final String? id;
  final String judul;
  final String deskripsi;
  final String? gambar;

  /// URL gambar yang disajikan lewat endpoint API (sudah mengikuti origin
  /// API yang aktif dan membawa header CORS).
  final String? gambarUrl;
  final String? tanggal;
  final String? waktu;

  Informasi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.gambar,
    this.gambarUrl,
    this.tanggal,
    this.waktu,
  });

  factory Informasi.fromJson(Map<String, dynamic> json) {
    return Informasi(
      id: json['id']?.toString(),
      judul: (json['judul'] ?? '').toString(),
      deskripsi: (json['deskripsi'] ?? '').toString(),
      gambar: json['gambar']?.toString(),
      gambarUrl: json['gambar_url']?.toString(),
      tanggal: json['tanggal']?.toString(),
      waktu: json['waktu']?.toString(),
    );
  }

  /// Alamat gambar yang paling siap dipakai `Image.network`:
  /// endpoint API lebih diutamakan, fallback ke normalisasi URL lama.
  String? get resolvedGambar {
    final url = (gambarUrl ?? '').trim();
    if (url.isNotEmpty) return url;
    return InformasiImageUrls.resolve(gambar);
  }
}
