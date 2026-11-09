import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pjsrk_report_location_model.dart';

/// CONTROLLER langkah 2 (Lokasi).
class PjsrkReportLocationController extends ChangeNotifier {
  static const maksFoto = 4;
  final ImagePicker _picker = ImagePicker();

  // Titik peta.
  double latitude = -7.6051;
  double longitude = 111.9046;

  // Nilai awal diisi sesuai gambar desain. Kosongkan kalau mau form bersih.
  final alamatCtrl =
      TextEditingController(text: 'Jl. Mojoroto Gg. 3, RT 02 / RW 04');
  final kelurahanCtrl = TextEditingController(text: 'Mojoroto');
  final kecamatanCtrl = TextEditingController(text: 'Mojoroto');
  final patokanCtrl = TextEditingController();
  final kontakCtrl = TextEditingController(text: '0812 3456 7890');

  // Daftar file foto yang dipilih pengguna (dimulai dari kosong)
  final List<String> foto = [];

  /// Mengambil foto baru langsung dari kamera
  Future<void> ambilFoto() async {
    if (foto.length >= maksFoto) return;
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (file != null) {
        foto.add(file.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error ambilFoto: $e');
    }
  }

  /// Memilih foto dari galeri ponsel
  Future<void> pilihDariGaleri() async {
    if (foto.length >= maksFoto) return;
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (file != null) {
        foto.add(file.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error pilihDariGaleri: $e');
    }
  }

  /// Menambah foto (kompatibilitas pengujian/testing)
  void tambahFoto([String? path]) {
    if (foto.length >= maksFoto) return;
    foto.add(path ?? 'contoh_${foto.length + 1}');
    notifyListeners();
  }

  void hapusFoto(int index) {
    if (index >= 0 && index < foto.length) {
      foto.removeAt(index);
      notifyListeners();
    }
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