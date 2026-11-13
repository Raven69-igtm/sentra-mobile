import '../models/pjsrk_report_event_model.dart';
import '../models/pjsrk_report_location_model.dart';

/// REPOSITORY: satu-satunya tempat yang bicara dengan server.
///
/// Backend SENTRA belum menyediakan endpoint pengiriman pengaduan PJSRK,
/// sehingga repository ini tidak boleh mengarang nomor tiket.
class PjsrkReportRepository {
  Future<String> kirim({
    required PjsrkReportEventModel event,
    required PjsrkReportLocationModel lokasi,
  }) async {
    throw UnsupportedError(
      'Endpoint pengiriman pengaduan PJSRK belum tersedia di backend SENTRA.',
    );
  }
}
