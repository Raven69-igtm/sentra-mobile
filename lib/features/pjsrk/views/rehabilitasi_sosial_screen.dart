import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_form_chips.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_form_fields.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_form_foto.dart';

class RehabilitasiSosialFormScreen extends StatefulWidget {
  const RehabilitasiSosialFormScreen({super.key});

  @override
  State<RehabilitasiSosialFormScreen> createState() =>
      _RehabilitasiSosialFormScreenState();
}

class _RehabilitasiSosialFormScreenState
    extends State<RehabilitasiSosialFormScreen> {
  static const _orange = Color(0xFFD6762E);
  static const _bg = Color(0xFFFAFAFA);

  // ---------- STATE FORM ----------
  String jenis = 'Tunawisma';
  int jumlah = 2;
  String gender = 'Laki-laki';

  void _handleBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  String usia = 'Dewasa';
  String kondisi = 'Sakit';
  bool rahasia = true;

  // Koordinat yang dipilih di peta (null = belum dipilih)
  double? lat;
  double? lng;

  // 4 slot foto (XFile dari image_picker; null = kosong)
  final List<XFile?> photos = List<XFile?>.filled(4, null);

  final lokasiC = TextEditingController();
  final ciriC = TextEditingController();
  final kontakC = TextEditingController(text: '0812 3456 7890');

  @override
  void dispose() {
    lokasiC.dispose();
    ciriC.dispose();
    kontakC.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Mulish')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? const Color(0xFF3F8F63) : const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    );
  }

  void _submit() {
    if (lokasiC.text.trim().isEmpty && lat == null) {
      return _snack('Lokasi wajib diisi (ketuk peta atau "Lokasi saya")');
    }
    if (ciriC.text.trim().isEmpty) return _snack('Ciri-ciri wajib diisi');
    if (kontakC.text.trim().isEmpty) return _snack('Kontak wajib diisi');

    // TODO: kirim ke API
    // - lat, lng
    // - photos (XFile) → upload multipart
    // - field lain
    final jumlahFoto = photos.where((p) => p != null).length;
    _snack(
      'Laporan $jenis dikirim'
      '${lat != null ? " | ($lat, $lng)" : ""}'
      ' | $jumlahFoto foto',
      ok: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // Header oranye
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, top + 8, 16, 14),
              color: _orange,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Kembali',
                      onPressed: _handleBack,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Rehabilitasi Sosial',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab Tunawisma / Anak Terlantar
                    RehabJenisTabs(
                      value: jenis,
                      onChanged: (v) => setState(() => jenis = v),
                    ),
                    const SizedBox(height: 18),

                    RehabJumlahGender(
                      jumlah: jumlah,
                      gender: gender,
                      onJumlah: (v) => setState(() => jumlah = v),
                      onGender: (v) => setState(() => gender = v),
                    ),
                    const SizedBox(height: 16),

                    const RehabLabel('Kelompok usia'),
                    const SizedBox(height: 8),
                    RehabChips(
                      options: const ['Dewasa', 'Lansia', 'Bersama anak'],
                      value: usia,
                      onChanged: (v) => setState(() => usia = v),
                    ),
                    const SizedBox(height: 16),

                    const RehabLabel('Kondisi saat ditemukan'),
                    const SizedBox(height: 8),
                    RehabChips(
                      options: const ['Sehat', 'Sakit', 'Gangguan jiwa'],
                      value: kondisi,
                      onChanged: (v) => setState(() => kondisi = v),
                    ),
                    const SizedBox(height: 16),

                    // ---- PETA + GPS ----
                    const RehabLabel('Lokasi ditemukan'),
                    const SizedBox(height: 8),
                    RehabMapField(
                      controller: lokasiC,
                      // Simpan lat/lng ke state screen saat berubah
                      onLocationChanged: (la, ln) {
                        setState(() {
                          lat = la;
                          lng = ln;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    const RehabLabel('Ciri-ciri & keterangan'),
                    const SizedBox(height: 8),
                    RehabTextArea(
                      controller: ciriC,
                      hint:
                          'Pakaian, kondisi fisik, sudah berapa lama di lokasi…',
                    ),
                    const SizedBox(height: 16),

                    // ---- FOTO (max 4) ----
                    const RehabLabel('Foto (maks 4)'),
                    const SizedBox(height: 8),
                    RehabFotoRow(
                      photos: photos,
                      onChanged: (index, file) {
                        setState(() => photos[index] = file);
                      },
                    ),
                    const SizedBox(height: 16),

                    const RehabLabel('Kontak pelapor'),
                    const SizedBox(height: 8),
                    RehabPhoneField(controller: kontakC),
                    const SizedBox(height: 12),

                    RehabRahasiaToggle(
                      value: rahasia,
                      onChanged: (v) => setState(() => rahasia = v),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Kirim Laporan',
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
