import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';

/// REPOSITORY: pengiriman Laporan Cepat PJSRK ke backend SENTRA.
///
/// Form cepat hanya mengumpulkan lima data teks (nama, telepon, lokasi,
/// jenis, deskripsi) sehingga cukup dikirim sebagai JSON tanpa foto.
class PjsrkQuickReportRepository {
  /// Kode layanan PJSRK yang dikenali backend.
  static const String layananBencana = 'pengaduan_bencana';
  static const String layananRehabilitasi = 'rehabilitasi_sosial';
  static const String layananPermasalahan = 'permasalahan_sosial';

  Future<String> kirim({
    required int idAkun,
    required String layanan,
    required String nama,
    required String telepon,
    required String lokasi,
    required String jenis,
    required String deskripsi,
  }) async {
    final response = await ApiClient.postRequest(Endpoints.pjsrkCepat, {
      'id_akun': idAkun,
      'layanan': layanan,
      'nama': nama.trim(),
      'telepon': telepon.trim(),
      'lokasi': lokasi.trim(),
      'jenis': jenis.trim(),
      'deskripsi': deskripsi.trim(),
    });

    final body = response.data;
    if (body is Map) {
      final data = body['data'];
      if (data is Map && data['id_laporan'] != null) {
        final nomor = data['id_laporan'].toString().trim();
        if (nomor.isNotEmpty) return nomor;
      }
    }

    throw ApiException(
      message: 'Server tidak mengembalikan nomor laporan.',
      statusCode: response.statusCode,
    );
  }
}
