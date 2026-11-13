import 'package:flutter/material.dart';
import '../models/pjsrk_report_event_model.dart';

/// CONTROLLER: menyimpan state form & logika (pilih chip, validasi, dll).
/// View hanya "mendengarkan" controller ini lewat ListenableBuilder.
class PjsrkReportEventController extends ChangeNotifier {
  // ---------- Pilihan tetap ----------
  static const jenisOptions = [
    'Banjir',
    'Tanah longsor',
    'Kebakaran',
    'Angin kencang',
    'Gempa bumi',
    'Lainnya',
  ];
  static const dampakOptions = ['Ringan', 'Sedang', 'Berat'];
  static const kebutuhanOptions = [
    'Evakuasi',
    'Makanan',
    'Air bersih',
    'Obat-obatan',
    'Selimut',
    'Tenda',
  ];

  // ---------- State (nilai awal sesuai desain Figma) ----------
  String jenisBencana = 'Banjir';
  DateTime tanggal = DateTime(2026, 10, 28);
  TimeOfDay jam = const TimeOfDay(hour: 9, minute: 30);
  String tingkatDampak = 'Sedang';
  final Set<String> kebutuhan = {'Evakuasi', 'Makanan'};

  final jiwaCtrl = TextEditingController(text: '40');
  final rumahCtrl = TextEditingController(text: '12');
  final keteranganCtrl = TextEditingController();

  String activeField = 'tanggal'; // 'tanggal' atau 'jam'

  // ---------- Aksi dari View ----------
  void pilihJenis(String v) {
    jenisBencana = v;
    notifyListeners();
  }

  void pilihDampak(String v) {
    tingkatDampak = v;
    notifyListeners();
  }

  void toggleKebutuhan(String v) {
    if (kebutuhan.contains(v)) {
      kebutuhan.remove(v);
    } else {
      kebutuhan.add(v);
    }
    notifyListeners();
  }

  Future<void> pilihTanggal(BuildContext context) async {
    activeField = 'tanggal';
    notifyListeners();
    final hasil = await showDatePicker(
      context: context,
      initialDate: tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (hasil != null) {
      tanggal = hasil;
      notifyListeners();
    }
  }

  Future<void> pilihJam(BuildContext context) async {
    activeField = 'jam';
    notifyListeners();
    final hasil = await showTimePicker(context: context, initialTime: jam);
    if (hasil != null) {
      jam = hasil;
      notifyListeners();
    }
  }

  // ---------- Format tampilan ----------
  static const _bulan = [
    'Okt', // default fallback index mapping
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String get tanggalText {
    final bulanName = (tanggal.month >= 1 && tanggal.month <= 12)
        ? _bulan[tanggal.month]
        : 'Okt';
    return '${tanggal.day} $bulanName ${tanggal.year}';
  }

  String get jamText =>
      '${jam.hour.toString().padLeft(2, '0')}.${jam.minute.toString().padLeft(2, '0')} WIB';

  // ---------- Validasi ----------
  /// Mengembalikan pesan error, atau null jika semua valid.
  String? validasi() {
    if (keteranganCtrl.text.trim().isEmpty) return 'Isi keterangan bencana';
    if (kebutuhan.isEmpty) return 'Pilih minimal 1 kebutuhan mendesak';
    return null;
  }

  /// Bentuk model untuk dikirim ke halaman berikutnya.
  PjsrkReportEventModel buildModel() => PjsrkReportEventModel(
        jenisBencana: jenisBencana,
        tanggal: tanggal,
        jam: jam,
        tingkatDampak: tingkatDampak,
        jiwaTerdampak: int.tryParse(jiwaCtrl.text) ?? 0,
        rumahRusak: int.tryParse(rumahCtrl.text) ?? 0,
        keterangan: keteranganCtrl.text.trim(),
        kebutuhan: kebutuhan.toList(),
      );

  @override
  void dispose() {
    jiwaCtrl.dispose();
    rumahCtrl.dispose();
    keteranganCtrl.dispose();
    super.dispose();
  }
}
