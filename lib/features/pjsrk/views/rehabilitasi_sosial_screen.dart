import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'package:sentra/features/pjsrk/views/laporan_sukses_screen.dart';
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

  // true saat laporan sedang dikirim ke API (menahan tap ganda)
  bool _sending = false;

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

  Future<void> _submit() async {
    if (lokasiC.text.trim().isEmpty && lat == null) {
      _snack('Lokasi wajib diisi (ketuk peta atau "Lokasi saya")');
      return;
    }
    if (ciriC.text.trim().isEmpty) {
      _snack('Ciri-ciri wajib diisi');
      return;
    }
    if (kontakC.text.trim().isEmpty) {
      _snack('Kontak wajib diisi');
      return;
    }

    final idAkun = Provider.of<UserProvider>(context, listen: false).idAkun;
    if (idAkun == null || idAkun <= 0) {
      _snack('Silakan login terlebih dahulu untuk mengirim laporan');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _sending = true);

    try {
      // Form multipart disusun manual. FormData.fromMap mengirim daftar berkas
      // dengan nama kunci yang sama ("foto"), sehingga PHP hanya menyisakan
      // satu berkas dan API menolak dengan "The foto field must be an array".
      // Kunci "foto[]" membuat PHP membentuk array berkas sesuai validasi API.
      final FormData form = FormData();
      form.fields.addAll(<MapEntry<String, String>>[
        MapEntry('id_akun', idAkun.toString()),
        MapEntry('jenis_rehabilitasi', jenis),
        MapEntry('jumlah_penerima', jumlah.toString()),
        MapEntry('jenis_kelamin', gender),
        MapEntry('kelompok_usia', usia),
        MapEntry('kondisi_saat_ditemukan', kondisi),
        MapEntry('ciri_ciri', ciriC.text.trim()),
        MapEntry('rahasia', rahasia ? '1' : '0'),
        MapEntry('alamat', lokasiC.text.trim()),
        MapEntry('kontak', kontakC.text.trim()),
      ]);

      if (lat != null && lng != null) {
        form.fields.add(MapEntry('latitude', lat.toString()));
        form.fields.add(MapEntry('longitude', lng.toString()));
      }

      final foto = <MultipartFile>[];
      for (final photo in photos) {
        if (photo == null) continue;
        final nama = _namaFileFoto(photo.name);
        final file = MultipartFile.fromBytes(
          await photo.readAsBytes(),
          filename: nama,
          contentType: _tipeFoto(nama),
        );
        foto.add(file);
        form.files.add(MapEntry('foto[]', file));
      }

      final response = await ApiClient.postRequest(
        '/pjsrk/rehabilitasi',
        form,
      );

      final idLaporan = _bacaIdLaporan(response.data);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LaporanSuksesScreen(
            reportData: {
              'id_laporan': idLaporan,
              'nomor_tiket': idLaporan,
              'jenis_rehabilitasi': jenis,
              'alamat': lokasiC.text.trim(),
              'jumlah_foto': foto.length,
            },
            nomorTiket: idLaporan.isEmpty ? null : idLaporan,
            tanggalWaktu: DateTime.now(),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('Gagal mengirim laporan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Nomor tiket asli dibuat trigger database (contoh: RKN...), bukan lagi
  /// dibuat di aplikasi supaya sama dengan nomor tiket admin Dinsos.
  String _bacaIdLaporan(dynamic body) {
    if (body is Map && body['data'] is Map) {
      return (body['data'] as Map)['id_laporan']?.toString() ?? '';
    }
    return '';
  }

  /// Pastikan nama berkas punya ekstensi gambar agar server menyimpannya
  /// dengan ekstensi yang benar.
  String _namaFileFoto(String name) {
    final lower = name.toLowerCase();
    final valid = lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
    if (valid) return name;
    return 'foto-${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  /// Tipe konten berkas agar header multipart sesuai ekstensi gambarnya.
  DioMediaType _tipeFoto(String nama) {
    final lower = nama.toLowerCase();
    if (lower.endsWith('.png')) return DioMediaType('image', 'png');
    if (lower.endsWith('.webp')) return DioMediaType('image', 'webp');
    return DioMediaType('image', 'jpeg');
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
                        onPressed: _sending ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _sending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
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
