import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/pjsrk_rehab_model.dart';

/// REPOSITORY: pengiriman laporan rehabilitasi sosial PJSRK ke backend SENTRA.
class PjsrkRehabRepository {
  Future<String> kirim({
    required int idAkun,
    required PjsrkRehabModel data,
    required List<XFile> foto,
  }) async {
    final form = await buildFormData(idAkun: idAkun, data: data, foto: foto);

    final response = await ApiClient.postMultipart(
      Endpoints.pjsrkRehabilitasi,
      form,
    );

    return _bacaNomorLaporan(response);
  }

  @visibleForTesting
  Future<FormData> buildFormData({
    required int idAkun,
    required PjsrkRehabModel data,
    required List<XFile> foto,
  }) async {
    final form = FormData();

    final payload = <String, dynamic>{'id_akun': idAkun, ...data.toMap()};

    payload.forEach((key, value) {
      if (value == null) return;
      form.fields.add(MapEntry(key, _teks(value)));
    });

    for (var i = 0; i < foto.length; i++) {
      final XFile item = foto[i];
      final bytes = await item.readAsBytes();
      if (bytes.isEmpty) continue;
      final nama = _namaFoto(item, i);
      form.files.add(
        MapEntry(
          'foto[]',
          MultipartFile.fromBytes(
            bytes,
            filename: nama,
            contentType: _tipeFoto(nama),
          ),
        ),
      );
    }

    return form;
  }

  // Laravel hanya menerima "1"/"0" pada aturan validasi boolean.
  String _teks(dynamic value) =>
      value is bool ? (value ? '1' : '0') : value.toString();

  /// Nama berkas aman lintas platform (Web blob URL maupun path mobile).
  String _namaFoto(XFile foto, int index) {
    final String rawName = foto.name.trim();
    final String candidate =
        rawName.isNotEmpty
            ? rawName
            : foto.path.split(RegExp(r'[\\/]')).last.trim();
    final String lower = candidate.toLowerCase();
    final bool valid =
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
    if (valid) return candidate;

    final String mime = (foto.mimeType ?? '').toLowerCase();
    final String ext =
        mime.contains('png')
            ? 'png'
            : (mime.contains('webp') ? 'webp' : 'jpg');
    return 'pjsrk-rehab-$index-${DateTime.now().millisecondsSinceEpoch}.$ext';
  }

  DioMediaType _tipeFoto(String nama) {
    final String lower = nama.toLowerCase();
    if (lower.endsWith('.png')) return DioMediaType('image', 'png');
    if (lower.endsWith('.webp')) return DioMediaType('image', 'webp');
    return DioMediaType('image', 'jpeg');
  }

  String _bacaNomorLaporan(Response<dynamic> response) {
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
