<<<<<<< HEAD
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/endpoints.dart';
=======
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
>>>>>>> d4305948dd430ab7571f66d9b4fe3a458674b465
import '../models/pjsrk_report_event_model.dart';
import '../models/pjsrk_report_location_model.dart';

/// REPOSITORY: satu-satunya tempat yang bicara dengan server.
///
<<<<<<< HEAD
/// Nomor laporan selalu berasal dari backend SENTRA (tidak dikarang di sini).
=======
/// Pengaduan bencana dikirim ke endpoint PJSRK di backend admin SENTRA
/// (`POST /api/pjsrk/bencana`), tabel yang sama dengan Rehabilitasi Sosial
/// dan Permasalahan Sosial (laporan + detail_kasus + detail_pjsrk).
>>>>>>> d4305948dd430ab7571f66d9b4fe3a458674b465
class PjsrkReportRepository {
  Future<String> kirim({
    required int idAkun,
    required PjsrkReportEventModel event,
    required PjsrkReportLocationModel lokasi,
  }) async {
<<<<<<< HEAD
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
=======
    // Form multipart disusun manual: daftar berkas memakai kunci "foto[]"
    // agar PHP membentuk array berkas sesuai validasi API.
    final FormData form = FormData();

    form.fields.addAll(<MapEntry<String, String>>[
      MapEntry('id_akun', idAkun.toString()),
      MapEntry('jenis_bencana', event.jenisBencana),
      MapEntry('waktu_kejadian', _waktuKejadian(event)),
      MapEntry('tingkat_dampak', event.tingkatDampak),
      MapEntry('jiwa_terdampak', event.jiwaTerdampak.toString()),
      MapEntry('rumah_rusak', event.rumahRusak.toString()),
      MapEntry('keterangan', event.keterangan),
      // Wajib array (minimal 1) sesuai validasi API.
      for (final String kebutuhan in event.kebutuhan)
        MapEntry('kebutuhan_mendesak[]', kebutuhan),
      MapEntry('alamat', lokasi.alamat),
      MapEntry('kelurahan', lokasi.kelurahan),
      MapEntry('kecamatan', lokasi.kecamatan),
      MapEntry('patokan_lokasi', lokasi.patokan),
      MapEntry('latitude', lokasi.latitude.toString()),
      MapEntry('longitude', lokasi.longitude.toString()),
      MapEntry('kontak', lokasi.kontak),
    ]);

    for (final XFile foto in lokasi.foto) {
      final bytes = await foto.readAsBytes();
      final nama = _namaFoto(foto);
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

    final response = await ApiClient.postRequest('/pjsrk/bencana', form);
    return _bacaIdLaporan(response.data);
  }

  /// Kirim form ringkas "Laporan Cepat" PJSRK.
  ///
  /// Dipakai tiga form cepat (rehabilitasi sosial, bencana alam, permasalahan
  /// sosial) yang hanya meminta nama, telepon, lokasi, jenis, dan deskripsi.
  /// [idAkun] boleh null: menu Laporan Cepat bisa dibuka sebelum login, dan
  /// backend mencatat kiriman anonim pada akun pelapor guest.
  ///
  /// [layanan] harus salah satu nilai enum backend:
  /// pengaduan_bencana | rehabilitasi_sosial | permasalahan_sosial.
  Future<String> kirimCepat({
    int? idAkun,
    required String layanan,
    required String nama,
    required String telepon,
    required String lokasi,
    required String jenis,
    required String deskripsi,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      // Hanya dikirim bila user sedang login.
      if (idAkun != null && idAkun > 0) 'id_akun': idAkun,
      'layanan': layanan,
      'nama': nama,
      'telepon': telepon,
      'lokasi': lokasi,
      'jenis': jenis,
      'deskripsi': deskripsi,
    };

    final response = await ApiClient.postRequest('/pjsrk/cepat', payload);
    return _bacaIdLaporan(response.data);
  }

  /// Tanggal + jam kejadian dalam format ISO dengan offset WIB (+07:00),
  /// supaya jam yang tampil di admin tetap sesuai jam perangkat.
  String _waktuKejadian(PjsrkReportEventModel event) {
    final DateTime t = event.tanggal;
    final int jam = event.jam.hour;
    final int menit = event.jam.minute;
    final String tanggal =
        '${t.year.toString().padLeft(4, '0')}-'
        '${t.month.toString().padLeft(2, '0')}-'
        '${t.day.toString().padLeft(2, '0')}';
    final String waktu =
        '${jam.toString().padLeft(2, '0')}:'
        '${menit.toString().padLeft(2, '0')}:00';
    return '${tanggal}T$waktu+07:00';
  }

  /// Nomor tiket asli dibuat trigger database (contoh: RKN...).
  String _bacaIdLaporan(dynamic body) {
    if (body is Map && body['data'] is Map) {
      return (body['data'] as Map)['id_laporan']?.toString() ?? '';
    }
    return '';
  }

  /// Nama berkas aman: pastikan berekstensi gambar yang diterima API.
  String _namaFoto(XFile foto) {
    final String name = foto.name;
    final String lower = name.toLowerCase();
    final bool valid = lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
    if (valid) return name;
    return 'foto-${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  /// Tipe konten berkas agar header multipart sesuai ekstensi gambarnya.
  DioMediaType _tipeFoto(String nama) {
    final String lower = nama.toLowerCase();
    if (lower.endsWith('.png')) return DioMediaType('image', 'png');
    if (lower.endsWith('.webp')) return DioMediaType('image', 'webp');
    return DioMediaType('image', 'jpeg');
>>>>>>> d4305948dd430ab7571f66d9b4fe3a458674b465
  }
}
