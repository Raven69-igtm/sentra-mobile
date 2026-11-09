import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/auth/views/profile_screen.dart';
import 'package:sentra/features/notification/views/notification_screen.dart';
import 'package:sentra/features/pjsrk/models/location_search_result.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_bottom_nav.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_form_chips.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_form_fields.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_form_foto.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_location_field.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_style.dart';
import 'package:sentra/features/report/views/history_screen.dart';

/// Form pengaduan Rehabilitasi Sosial (Tunawisma / Anak Terlantar).
///
/// Lokasi ditentukan HANYA dari hasil pencarian yang dipilih user
/// (Nominatim). Tidak ada GPS, permission lokasi, input koordinat manual,
/// maupun peta interaktif.
class RehabilitasiSosialFormScreen extends StatefulWidget {
  const RehabilitasiSosialFormScreen({super.key});

  @override
  State<RehabilitasiSosialFormScreen> createState() =>
      _RehabilitasiSosialFormScreenState();
}

class _RehabilitasiSosialFormScreenState
    extends State<RehabilitasiSosialFormScreen> {
  static const String _tunawisma = 'Tunawisma';
  static const String _anak = 'Anak Terlantar';

  String _jenis = _tunawisma;
  bool get _isTunawisma => _jenis == _tunawisma;

  // ---------- LOKASI (dipakai bersama kedua form) ----------
  final TextEditingController _lokasiC = TextEditingController();
  LocationSearchResult? _selectedLocation;

  String? get selectedAddress => _selectedLocation?.displayName;
  double? get selectedLatitude => _selectedLocation?.latitude;
  double? get selectedLongitude => _selectedLocation?.longitude;

  // ---------- FOTO & PRIVASI (dipakai bersama) ----------
  final List<RehabPhoto?> _photos =
      List<RehabPhoto?>.filled(RehabFotoRow.maxPhotos, null);
  bool _rahasia = true;

  // ---------- TUNAWISMA ----------
  int _jumlah = 1;
  String _genderTuna = 'Laki-laki';
  String _usiaTuna = 'Dewasa';
  String _kondisiTuna = 'Sehat';
  final TextEditingController _ciriC = TextEditingController();
  final TextEditingController _kontakC = TextEditingController();

  // ---------- ANAK TERLANTAR ----------
  String _usiaAnak = '6–12 tahun';
  String _genderAnak = 'Laki-laki';
  String _kondisiAnak = 'Tidak diasuh';
  String _wali = 'Tidak tahu';
  final TextEditingController _keteranganAnakC = TextEditingController();

  @override
  void dispose() {
    _lokasiC.dispose();
    _ciriC.dispose();
    _kontakC.dispose();
    _keteranganAnakC.dispose();
    super.dispose();
  }

  // ============================================================
  // AKSI
  // ============================================================
  void _snack(String message, {bool ok = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: RehabStyle.fontFamily),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              ok ? RehabStyle.green : const Color(0xFF2C3E50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      );
  }

  void _onLocationChanged(LocationSearchResult? result) {
    if (!mounted) return;
    setState(() => _selectedLocation = result);
  }

  void _onPhotoChanged(int index, RehabPhoto? photo) {
    if (!mounted) return;
    setState(() => _photos[index] = photo);
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    // 1. Lokasi harus dipilih dari hasil pencarian (address + lat + lng).
    if (selectedAddress == null ||
        selectedLatitude == null ||
        selectedLongitude == null) {
      return _snack('Tentukan lokasi terlebih dahulu');
    }

    // 2. Field wajib sesuai jenis laporan.
    final keterangan =
        (_isTunawisma ? _ciriC : _keteranganAnakC).text.trim();
    if (keterangan.isEmpty) {
      return _snack(_isTunawisma
          ? 'Ciri-ciri & keterangan wajib diisi'
          : 'Keterangan wajib diisi');
    }

    if (_isTunawisma) {
      final kontak = _kontakC.text.trim();
      if (kontak.isEmpty) return _snack('Kontak pelapor wajib diisi');
      final digits = kontak.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 9 || digits.length > 15) {
        return _snack('Nomor kontak tidak valid');
      }
    }

    // 3. Mock submit: susun payload yang nanti siap dikirim ke backend.
    final payload = <String, dynamic>{
      'jenis': _isTunawisma ? 'tunawisma' : 'anak_terlantar',
      if (_isTunawisma) ...{
        'jumlah_orang': _jumlah,
        'jenis_kelamin': _genderTuna,
        'kelompok_usia': _usiaTuna,
        'kondisi': _kondisiTuna,
        'kontak_pelapor': _kontakC.text.trim(),
      } else ...{
        'perkiraan_usia': _usiaAnak,
        'jenis_kelamin': _genderAnak,
        'kondisi_anak': _kondisiAnak,
        'orang_tua_wali': _wali,
      },
      'keterangan': keterangan,
      'lokasi': _selectedLocation!.toJson(),
      'jumlah_foto': _photos.where((p) => p != null).length,
      'rahasiakan_identitas': _rahasia,
    };
    debugPrint('[Rehabilitasi Sosial] payload: ${jsonEncode(payload)}');

    // TODO(backend): kirim payload + foto (multipart) ke API.
    _snack('Data laporan berhasil disiapkan', ok: true);
  }

  /// Navigasi bottom nav, sama dengan perilaku di PjsrkScreen.
  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pop();
        break;
      case 1:
        final userId = Provider.of<UserProvider>(context, listen: false).idAkun;
        if (userId != null && userId > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryPage()),
          );
        } else {
          _snack('Silakan login terlebih dahulu untuk melihat riwayat laporan');
        }
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NotificationPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
        break;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: RehabStyle.background,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RehabJenisTabs(
                          value: _jenis,
                          options: const [_tunawisma, _anak],
                          onChanged: (v) => setState(() => _jenis = v),
                        ),
                        const SizedBox(height: 18),
                        ..._isTunawisma
                            ? _tunawismaTop()
                            : _anakTop(),
                        _section(
                          'Lokasi ditemukan',
                          RehabLocationField(
                            controller: _lokasiC,
                            selected: _selectedLocation,
                            onSelectionChanged: _onLocationChanged,
                          ),
                        ),
                        ..._isTunawisma
                            ? _tunawismaBottom()
                            : _anakBottom(),
                        _section(
                          'Foto (maks ${RehabFotoRow.maxPhotos})',
                          RehabFotoRow(
                            photos: _photos,
                            onChanged: _onPhotoChanged,
                          ),
                        ),
                        if (_isTunawisma)
                          _section(
                            'Kontak pelapor',
                            RehabPhoneField(controller: _kontakC),
                            gap: 12,
                          ),
                        RehabRahasiaToggle(
                          value: _rahasia,
                          onChanged: (v) => setState(() => _rahasia = v),
                        ),
                        const SizedBox(height: 24),
                        RehabPrimaryButton(
                          label: 'Kirim Laporan',
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: PjsrkBottomNav(
          selectedIndex: 0,
          onTabSelected: _onBottomNavTapped,
        ),
      ),
    );
  }

  /// Label + isi + jarak bawah.
  Widget _section(String label, Widget child, {double gap = 16}) {
    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RehabLabel(label),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // ---------------- TUNAWISMA ----------------
  List<Widget> _tunawismaTop() => [
        _section(
          'Jumlah orang',
          RehabJumlahField(
            value: _jumlah,
            onChanged: (v) => setState(() => _jumlah = v),
          ),
        ),
        _section(
          'Jenis kelamin',
          RehabChips(
            options: const ['Laki-laki', 'Perempuan', 'Campuran'],
            value: _genderTuna,
            onChanged: (v) => setState(() => _genderTuna = v),
          ),
        ),
        _section(
          'Kelompok usia',
          RehabChips(
            options: const ['Dewasa', 'Lansia', 'Bersama anak'],
            value: _usiaTuna,
            onChanged: (v) => setState(() => _usiaTuna = v),
          ),
        ),
        _section(
          'Kondisi saat ditemukan',
          RehabChips(
            options: const ['Sehat', 'Sakit', 'Gangguan jiwa'],
            value: _kondisiTuna,
            onChanged: (v) => setState(() => _kondisiTuna = v),
          ),
        ),
      ];

  List<Widget> _tunawismaBottom() => [
        _section(
          'Ciri-ciri & keterangan',
          RehabTextArea(
            controller: _ciriC,
            hint: 'Pakaian, kondisi fisik, sudah berapa lama di lokasi…',
          ),
        ),
      ];

  // ---------------- ANAK TERLANTAR ----------------
  List<Widget> _anakTop() => [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: RehabSafetyAlert(
            message:
                'Utamakan keselamatan anak. Jika anak dalam bahaya langsung, '
                'segera hubungi 110 atau SAPA 129. Jangan membawa anak pergi '
                'sendiri; tunggu petugas.',
          ),
        ),
        _section(
          'Perkiraan usia',
          RehabChips(
            options: const ['0–5 tahun', '6–12 tahun', '13–17 tahun'],
            value: _usiaAnak,
            onChanged: (v) => setState(() => _usiaAnak = v),
          ),
        ),
        _section(
          'Jenis kelamin',
          RehabChips(
            options: const ['Laki-laki', 'Perempuan'],
            value: _genderAnak,
            onChanged: (v) => setState(() => _genderAnak = v),
          ),
        ),
        _section(
          'Kondisi anak',
          RehabChips(
            options: const [
              'Tidak diasuh',
              'Mengemis / mengamen',
              'Putus sekolah',
              'Mengalami kekerasan',
              'Sakit',
              'Lainnya',
            ],
            value: _kondisiAnak,
            onChanged: (v) => setState(() => _kondisiAnak = v),
          ),
        ),
        _section(
          'Apakah ada orang tua / wali?',
          RehabChips(
            options: const ['Ada', 'Tidak ada', 'Tidak tahu'],
            value: _wali,
            onChanged: (v) => setState(() => _wali = v),
          ),
        ),
      ];

  List<Widget> _anakBottom() => [
        _section(
          'Keterangan',
          RehabTextArea(
            controller: _keteranganAnakC,
            hint: 'Ciri-ciri anak, pakaian, sudah berapa lama di lokasi…',
          ),
        ),
      ];

  // ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: statusBarHeight + 8,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      color: RehabStyle.orange,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  label: 'Kembali',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(56),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                'Rehabilitasi Sosial',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: RehabStyle.fontFamily,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
