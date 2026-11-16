import 'package:flutter/material.dart';
import '../models/pjsrk_report_event_model.dart';
import '../models/pjsrk_report_location_model.dart';
import '../repositories/pjsrk_report_repository.dart';

/// CONTROLLER langkah 3 (Kirim).
class PjsrkReportSendController extends ChangeNotifier {
  final PjsrkReportEventModel event;
  final PjsrkReportLocationModel location;
  final PjsrkReportRepository _repository = PjsrkReportRepository();

  PjsrkReportSendController({required this.event, required this.location});

  bool setuju = false;
  bool isLoading = false;

  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String get waktuText {
    final t = event.tanggal;
    final j = event.jam;
    final jam = j.hour.toString().padLeft(2, '0');
    final menit = j.minute.toString().padLeft(2, '0');
    return '${t.day} ${_bulan[t.month - 1]} ${t.year}, $jam.$menit WIB';
  }

  List<MapEntry<String, String>> get ringkasanKejadian => [
        MapEntry('Jenis bencana', event.jenisBencana),
        MapEntry('Waktu', waktuText),
        MapEntry('Tingkat dampak', event.tingkatDampak),
        MapEntry('Jiwa terdampak', '± ${event.jiwaTerdampak} jiwa'),
        MapEntry('Rumah rusak', '${event.rumahRusak} unit'),
        MapEntry('Keterangan', event.keterangan),
        MapEntry('Kebutuhan', event.kebutuhan.join(', ')),
      ];

  List<MapEntry<String, String>> get ringkasanLokasi => [
        MapEntry('Alamat', location.alamat),
        MapEntry('Kelurahan', location.kelurahan),
        MapEntry('Kecamatan', location.kecamatan),
        MapEntry('Patokan', location.patokan.isEmpty ? '-' : location.patokan),
        MapEntry('Foto / video', '${location.foto.length} file'),
        MapEntry('Kontak', location.kontak),
      ];

  void toggleSetuju(bool v) {
    setuju = v;
    notifyListeners();
  }

  String? validasi() =>
      setuju ? null : 'Centang pernyataan dulu sebelum mengirim';

  /// Gabungan data kamar 1 + kamar 2, siap dikirim.
  Map<String, dynamic> get payload => {
        ...event.toMap(),
        ...location.toMap(),
      };

  /// Mengirim laporan ke server. Nomor laporan berasal dari backend.
  Future<String> kirim({required int idAkun}) async {
    isLoading = true;
    notifyListeners();
    try {
      return await _repository.kirim(
        idAkun: idAkun,
        event: event,
        lokasi: location,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}