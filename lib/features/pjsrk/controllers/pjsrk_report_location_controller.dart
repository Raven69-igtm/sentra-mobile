import 'package:flutter/material.dart';
import '../models/pjsrk_report_location_model.dart';

/// CONTROLLER langkah 2 (Lokasi).
class PjsrkReportLocationController extends ChangeNotifier {
  static const maksFoto = 4;

  // Titik peta. TODO: ganti dengan hasil GPS (paket geolocator).
 double latitude = -7.6051;
 double longitude = 111.9046;

  // Nilai awal diisi sesuai gambar desain. Kosongkan kalau mau form bersih.
  final alamatCtrl =
      TextEditingController(text: 'Jl. Mojoroto Gg. 3, RT 02 / RW 04');
  final kelurahanCtrl = TextEditingController(text: 'Mojoroto');
  final kecamatanCtrl = TextEditingController(text: 'Mojoroto');
  final patokanCtrl = TextEditingController();
  final kontakCtrl = TextEditingController(text: '0812 3456 7890');

  // Daftar foto. Sekarang masih isi tiruan (2 kotak terisi seperti gambar).
  // TODO: ganti jadi [] dan isi path asli dari paket image_picker.
  final List<String> foto = ['contoh_1', 'contoh_2'];

  void tambahFoto() {
    if (foto.length >= maksFoto) return;
    // TODO: buka kamera/galeri pakai image_picker, lalu add path aslinya.
    foto.add('contoh_${foto.length + 1}');
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
        foto: List.of(foto),
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