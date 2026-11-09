import 'package:flutter/foundation.dart';
import '../models/pjsrk_report_event_model.dart';
import '../models/pjsrk_report_location_model.dart';

/// REPOSITORY: satu-satunya tempat yang bicara dengan server.
class PjsrkReportRepository {
  /// Mengirim laporan. Mengembalikan nomor tiket.
  Future<String> kirim({
    required PjsrkReportEventModel event,
    required PjsrkReportLocationModel lokasi,
  }) async {
    // Gabungkan isi 2 kotak jadi satu paket
    final paket = {
      ...event.toMap(),
      ...lokasi.toMap(),
      'dibuat_pada': DateTime.now().toIso8601String(),
    };

    // TODO: GANTI bagian ini dengan pengiriman sungguhan, contoh:
    //  - Firebase : upload lokasi.fotoPaths ke Storage, lalu simpan `paket`
    //               ke Firestore
    //  - API PHP  : kirim `paket` + file foto lewat http.MultipartRequest
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('Paket laporan: $paket');

    final angka = DateTime.now().millisecondsSinceEpoch % 100000;
    return 'PJSRK-${angka.toString().padLeft(5, '0')}';
  }
}