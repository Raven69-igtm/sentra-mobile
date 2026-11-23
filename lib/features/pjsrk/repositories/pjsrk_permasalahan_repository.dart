import 'package:dio/dio.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/endpoints.dart';

/// Repository khusus pengiriman laporan Permasalahan Sosial (PJSRK).
///
/// Memisahkan penyusunan `FormData` multipart dari lapisan UI agar
/// konsisten dengan [PjsrkReportRepository] dan [PjsrkRehabRepository].
class PjsrkPermasalahanRepository {
  Future<String> kirim({
    required int idAkun,
    required String jenisPermasalahan,
    required String judul,
    required String uraian,
    required String alamat,
    required double latitude,
    required double longitude,
    required bool rahasia,
    List<MultipartFile> fotoFiles = const <MultipartFile>[],
  }) async {
    final FormData formData = FormData();
    formData.fields.addAll(<MapEntry<String, String>>[
      MapEntry('id_akun', idAkun.toString()),
      MapEntry('jenis_permasalahan', jenisPermasalahan),
      MapEntry('judul', judul),
      MapEntry('uraian', uraian),
      MapEntry('alamat', alamat),
      MapEntry('latitude', latitude.toString()),
      MapEntry('longitude', longitude.toString()),
      MapEntry('rahasia', rahasia ? '1' : '0'),
    ]);

    for (final MultipartFile file in fotoFiles) {
      formData.files.add(MapEntry('foto[]', file));
    }

    final response = await ApiClient.postMultipart(
      Endpoints.pjsrkPermasalahanSosial,
      formData,
    );

    final body = response.data;
    if (body is Map && body['data'] is Map) {
      return (body['data'] as Map)['id_laporan']?.toString() ?? '';
    }
    return '';
  }
}
