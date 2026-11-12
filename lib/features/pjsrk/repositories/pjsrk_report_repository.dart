import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
import '../models/pjsrk_report_event_model.dart';
import '../models/pjsrk_report_location_model.dart';

/// REPOSITORY: satu-satunya tempat yang bicara dengan server.
///
/// Nomor laporan selalu berasal dari backend SENTRA (tidak dikarang di sini).
class PjsrkReportRepository {
  Future<String> kirim({
    required int idAkun,
    required PjsrkReportEventModel event,
    required PjsrkReportLocationModel lokasi,
  }) async {
    final form = FormData();

    // 'foto' berisi path file lokal, jadi dikirim sebagai berkas multipart.
    final payload = <String, dynamic>{
      'id_akun': idAkun,
      ...event.toMap(),
      ...lokasi.toMap(),
    }..remove('foto');

    payload.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        for (final item in value) {
          form.fields.add(MapEntry('$key[]', item.toString()));
        }
        return;
      }
      form.fields.add(MapEntry(key, _teks(value)));
    });

    for (var i = 0; i < lokasi.foto.length; i++) {
      final path = lokasi.foto[i];
      if (path.trim().isEmpty || !File(path).existsSync()) continue;
      form.files.add(MapEntry(
        'foto[]',
        await MultipartFile.fromFile(path, filename: _namaFile(path, i)),
      ));
    }

    final response = await ApiClient.postMultipart(
      Endpoints.pjsrkBencana,
      form,
    );

    return _bacaNomorLaporan(response);
  }

  String _teks(dynamic value) =>
      value is bool ? (value ? '1' : '0') : value.toString();

  String _namaFile(String path, int index) {
    final nama = path.split(RegExp(r'[\\/]')).last;
    return nama.isEmpty ? 'pjsrk-bencana-$index.jpg' : nama;
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
