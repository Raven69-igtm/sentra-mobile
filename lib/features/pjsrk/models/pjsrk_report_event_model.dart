import 'package:flutter/material.dart';

/// MODEL: data langkah 1 (Kejadian) pada layanan pengaduan bencana PJSRK.
/// Nanti digabung dengan data Lokasi (langkah 2) lalu dikirim di langkah 3.
class PjsrkReportEventModel {
  final String jenisBencana;
  final DateTime tanggal;
  final TimeOfDay jam;
  final String tingkatDampak;
  final int jiwaTerdampak;
  final int rumahRusak;
  final String keterangan;
  final List<String> kebutuhan;

  const PjsrkReportEventModel({
    required this.jenisBencana,
    required this.tanggal,
    required this.jam,
    required this.tingkatDampak,
    required this.jiwaTerdampak,
    required this.rumahRusak,
    required this.keterangan,
    required this.kebutuhan,
  });

  /// Format siap kirim ke Firebase / API.
  Map<String, dynamic> toMap() {
    final waktu = DateTime(
      tanggal.year,
      tanggal.month,
      tanggal.day,
      jam.hour,
      jam.minute,
    );
    return {
      'jenis_bencana': jenisBencana,
      'waktu_kejadian': waktu.toIso8601String(),
      'tingkat_dampak': tingkatDampak,
      'jiwa_terdampak': jiwaTerdampak,
      'rumah_rusak': rumahRusak,
      'keterangan': keterangan,
      'kebutuhan_mendesak': kebutuhan,
    };
  }

  // ---- Teks siap tampil untuk halaman "Kirim" ----
  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String get tanggalText =>
      '${tanggal.day} ${_bulan[tanggal.month - 1]} ${tanggal.year}';

  String get jamText =>
      '${jam.hour.toString().padLeft(2, '0')}.${jam.minute.toString().padLeft(2, '0')} WIB';
}