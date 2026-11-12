import 'dart:io';

import 'package:dio/dio.dart';
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
    final form = FormData();

    final payload = <String, dynamic>{
      'id_akun': idAkun,
      ...data.toMap(),
    };

    payload.forEach((key, value) {
      if (value == null) return;
      form.fields.add(MapEntry(key, _teks(value)));
    });

    for (var i = 0; i < foto.length; i++) {
      final path = foto[i].path;
      if (path.trim().isEmpty || !File(path).existsSync()) continue;
      form.files.add(MapEntry(
        'foto[]',
        await MultipartFile.fromFile(path, filename: _namaFile(path, i)),
      ));
    }

    final response = await ApiClient.postMultipart(
      Endpoints.pjsrkRehabilitasi,
      form,
    );

    return _bacaNomorLaporan(response);
  }

  // Laravel hanya menerima "1"/"0" pada aturan validasi boolean.
  String _teks(dynamic value) =>
      value is bool ? (value ? '1' : '0') : value.toString();

  String _namaFile(String path, int index) {
    final nama = path.split(RegExp(r'[\\/]')).last;
    return nama.isEmpty ? 'pjsrk-rehab-$index.jpg' : nama;
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
