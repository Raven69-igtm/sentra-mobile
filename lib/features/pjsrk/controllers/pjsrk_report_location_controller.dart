import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pjsrk_report_location_model.dart';

/// CONTROLLER langkah 2 (Lokasi).
class PjsrkReportLocationController extends ChangeNotifier {
  static const maksFoto = 4;

  double latitude = -7.6051;
  double longitude = 111.9046;

  final alamatCtrl = TextEditingController();
  final kelurahanCtrl = TextEditingController();
  final kecamatanCtrl = TextEditingController();
  final patokanCtrl = TextEditingController();
  final kontakCtrl = TextEditingController(text: '0812 3456 7890');

  // Foto bukti dari kamera / galeri (maks 4).
  final List<XFile> foto = [];

  void tambahFoto(XFile file) {
    if (foto.length >= maksFoto) return;
    foto.add(file);
    notifyListeners();
  }

  void hapusFoto(int index) {
    foto.removeAt(index);
    notifyListeners();
  }

  /// Mengembalikan pesan error, atau null jika semua benar.
  String? validasi() {
    if (alamatCtrl.text.trim().isEmpty) return 'Isi alamat lokasi bencana';
    if (kelurahanCtrl.text.trim().isEmpty) return 'Isi kelurahan';
    if (kecamatanCtrl.text.trim().isEmpty) return 'Isi kecamatan';
    final angka = kontakCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (angka.length < 10 || angka.length > 14) {
      return 'Nomor kontak belum benar';
    }
    return null;
  }

  PjsrkReportLocationModel buildModel() => PjsrkReportLocationModel(
    alamat: alamatCtrl.text.trim(),
    kelurahan: kelurahanCtrl.text.trim(),
    kecamatan: kecamatanCtrl.text.trim(),
    patokan: patokanCtrl.text.trim(),
    latitude: latitude,
    longitude: longitude,
    foto: List<XFile>.of(foto),
    kontak: kontakCtrl.text.trim(),
  );

  @override
  void dispose() {
    alamatCtrl.dispose();
    kelurahanCtrl.dispose();
    kecamatanCtrl.dispose();
    patokanCtrl.dispose();
    kontakCtrl.dispose();
    super.dispose();
  }
}
