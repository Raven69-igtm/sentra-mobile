import 'dart:convert';

import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/auth/views/login_screen.dart';
import 'package:sentra/features/report/controllers/report_controller.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'package:sentra/core/utils/address_field.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/features/report/views/widgets/stepper_widget.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _AnakFormData {
  final TextEditingController nama = TextEditingController();
  final TextEditingController tanggalLahir = TextEditingController();
  final TextEditingController umur = TextEditingController();
  String? jenisKelamin;
  String? pendidikan;
  String? agama;
  String? status;

  void dispose() {
    nama.dispose();
    tanggalLahir.dispose();
    umur.dispose();
  }
}

class _LaporanPageState extends State<LaporanPage> {
  int _currentStep = 1;
  final LaporanController laporanController = LaporanController();
  bool _isSubmitting = false;

  // Form 1 - Data Diri Pelapor
  final TextEditingController _nikform1 = TextEditingController();
  final TextEditingController _namaform1 = TextEditingController();
  final TextEditingController _telpform1 = TextEditingController();
  final TextEditingController _alamatform1 = TextEditingController();
  final TextEditingController _hubunganform1 = TextEditingController();

  // Form 1 - Penerima Manfaat
  bool _penerimaSamaDenganPelapor = true;
  final TextEditingController _nikPenerima = TextEditingController();
  final TextEditingController _namaPenerima = TextEditingController();
  final TextEditingController _tempatLahirPenerima = TextEditingController();
  final TextEditingController _tanggalLahirPenerima = TextEditingController();
  final TextEditingController _umurPenerima = TextEditingController();
  final TextEditingController _pekerjaanPenerima = TextEditingController();
  final TextEditingController _alamatPenerima = TextEditingController();
  final TextEditingController _hubunganTerlaporPenerima = TextEditingController();
  final TextEditingController _telpPenerima = TextEditingController();
  final TextEditingController _infoTambahanPenerima = TextEditingController();
  String? _jenisKelaminPenerima;
  String? _agamaPenerima;
  String? _pendidikanPenerima;

  // Form 1 - Terlapor (opsional)
  bool _sertakanTerlapor = false;
  final TextEditingController _nikTerlapor = TextEditingController();
  final TextEditingController _namaTerlapor = TextEditingController();
  final TextEditingController _umurTerlapor = TextEditingController();
  final TextEditingController _alamatTerlapor = TextEditingController();
  final TextEditingController _hubunganTerlapor = TextEditingController();
  final TextEditingController _infoTambahanTerlapor = TextEditingController();
  String? _jenisKelaminTerlapor;

  // Form 1 - Informasi Anak (opsional)
  bool _sertakanAnak = false;
  final List<_AnakFormData> _anakList = [];

  // Form 2 - Kronologi Kejadian
  final TextEditingController _kronologiform4 = TextEditingController();

  // Form 3 - Tanggal & Lokasi Kejadian
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _tempatkejadianform3 = TextEditingController();
  DateTime? _waktuKejadian;
  bool _isFetchingLocation = false;
  bool _hasRequestedLocation = false;

  void _addAutoCapitalizeListener(TextEditingController controller) {
    controller.addListener(() {
      final text = controller.text;
      final capitalized = text.replaceAllMapped(
        RegExp(r'(^\w{1}|\s+\w{1})'),
        (match) => match.group(0)!.toUpperCase(),
      );
      if (text != capitalized) {
        controller.value = controller.value.copyWith(
          text: capitalized,
          selection: TextSelection.collapsed(offset: capitalized.length),
        );
      }
    });
  }

  void _nextStep() {
    bool isValid = false;
    switch (_currentStep) {
      case 1:
        isValid = _validateForm1();
        break;
      case 2:
        isValid = _validateForm2();
        break;
      case 3:
        isValid = _validateForm3();
        break;
    }

    if (isValid) {
      final enteringIncidentDetails = _currentStep == 2;
      setState(() {
        if (_currentStep < 3) _currentStep++;
      });
      if (enteringIncidentDetails) {
        _initializeIncidentDateAndLocation();
      }
    }
  }

  Future<void> _initializeIncidentDateAndLocation() async {
    final now = DateTime.now();
    _waktuKejadian ??= now;
    if (_tanggalController.text.isEmpty) {
      _tanggalController.text = _formatDateForApi(now);
    }

    if (_hasRequestedLocation || _tempatkejadianform3.text.trim().isNotEmpty) {
      return;
    }
    _hasRequestedLocation = true;

    setState(() => _isFetchingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        CustomSnackbar.show(
          'GPS tidak aktif. Silakan isi lokasi kejadian secara manual.',
          warna: Colors.orange,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        CustomSnackbar.show(
          'Izin lokasi tidak tersedia. Silakan isi lokasi kejadian secara manual.',
          warna: Colors.orange,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;

      final coordinates =
          'Lat ${position.latitude.toStringAsFixed(5)}, '
          'Lng ${position.longitude.toStringAsFixed(5)}';
      if (_tempatkejadianform3.text.trim().isNotEmpty) return;
      _tempatkejadianform3.text = coordinates;

      try {
        final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
          'lat': '${position.latitude}',
          'lon': '${position.longitude}',
          'format': 'jsonv2',
          'addressdetails': '1',
          'zoom': '18',
        });
        final response = await http
            .get(
              uri,
              headers: const {
                'User-Agent': 'SENTRA-DPPPA-Nganjuk/1.0',
                'Accept-Language': 'id',
              },
            )
            .timeout(const Duration(seconds: 10));
        if (response.statusCode != 200) {
          throw Exception('Reverse geocoding gagal: ${response.statusCode}');
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address =
            (data['address'] as Map?)?.cast<String, dynamic>() ?? {};
        final addressParts = [
          address['road'],
          address['suburb'] ?? address['neighbourhood'] ?? address['village'],
          address['city_district'] ?? address['county'] ?? address['city'],
          address['state'],
        ].where((part) => part != null && '$part'.trim().isNotEmpty);
        final resolvedAddress =
            addressParts.isNotEmpty
                ? addressParts.join(', ')
                : (data['display_name'] as String?)
                    ?.split(',')
                    .take(4)
                    .join(',');

        if (mounted &&
            _tempatkejadianform3.text == coordinates &&
            resolvedAddress != null &&
            resolvedAddress.isNotEmpty) {
          _tempatkejadianform3.text = resolvedAddress;
        }
      } catch (error) {
        debugPrint('Gagal mendapatkan alamat dari koordinat GPS: $error');
        if (mounted) {
          CustomSnackbar.show(
            'Koordinat GPS terisi, tetapi alamat tidak dapat ditemukan.',
            warna: Colors.orange,
          );
        }
      }
    } catch (error) {
      debugPrint('Gagal mendapatkan lokasi GPS untuk laporan PPA: $error');
      if (mounted) {
        CustomSnackbar.show(
          'Lokasi GPS gagal didapatkan. Silakan isi lokasi kejadian secara manual.',
          warna: Colors.orange,
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  String _formatDateForApi(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  void _prevStep() {
    setState(() {
      if (_currentStep > 1) _currentStep--;
    });
  }

  void _handleBackNavigation() {
    if (_currentStep > 1) {
      _prevStep();
      return;
    }

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user != null) {
        if (user.nama != null &&
            user.nama!.isNotEmpty &&
            _namaform1.text.isEmpty) {
          _namaform1.text = user.nama!;
        }
        if (user.notelp != null &&
            user.notelp!.isNotEmpty &&
            _telpform1.text.isEmpty) {
          _telpform1.text = user.notelp!;
        }
        if (user.alamat != null &&
            user.alamat!.isNotEmpty &&
            _alamatform1.text.isEmpty) {
          _alamatform1.text = user.alamat!;
        }
      }
    });

    final namaControllers = [
      _namaform1,
      _alamatform1,
      _tempatkejadianform3,
      _namaPenerima,
      _tempatLahirPenerima,
      _alamatPenerima,
      _namaTerlapor,
      _alamatTerlapor,
    ];

    for (var controller in namaControllers) {
      _addAutoCapitalizeListener(controller);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _nikform1,
      _namaform1,
      _telpform1,
      _alamatform1,
      _hubunganform1,
      _nikPenerima,
      _namaPenerima,
      _tempatLahirPenerima,
      _tanggalLahirPenerima,
      _umurPenerima,
      _pekerjaanPenerima,
      _alamatPenerima,
      _hubunganTerlaporPenerima,
      _telpPenerima,
      _infoTambahanPenerima,
      _nikTerlapor,
      _namaTerlapor,
      _umurTerlapor,
      _alamatTerlapor,
      _hubunganTerlapor,
      _infoTambahanTerlapor,
      _kronologiform4,
      _tanggalController,
      _tempatkejadianform3,
    ]) {
      controller.dispose();
    }
    for (final anak in _anakList) {
      anak.dispose();
    }
    super.dispose();
  }

  // Validator untuk Form 1: Data Diri
  bool _validateForm1() {
    if (_nikform1.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi NIK", warna: Colors.red);
      return false;
    }
    if (_nikform1.text.trim().length != 16) {
      CustomSnackbar.show("NIK harus berjumlah 16 digit", warna: Colors.red);
      return false;
    }
    if (_namaform1.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi nama lengkap", warna: Colors.red);
      return false;
    }
    if (_telpform1.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi nomor telepon", warna: Colors.red);
      return false;
    }
    if (_alamatform1.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi alamat lengkap", warna: Colors.red);
      return false;
    }
    return true;
  }

  // Validator untuk Form 2: Kronologi Kejadian
  bool _validateForm2() {
    if (_kronologiform4.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi kronologi kejadian", warna: Colors.red);
      return false;
    }
    return true;
  }

  // Validator untuk Form 3: Tanggal & Lokasi Kejadian
  bool _validateForm3() {
    if (_tanggalController.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon pilih tanggal kejadian", warna: Colors.red);
      return false;
    }
    if (_tempatkejadianform3.text.trim().isEmpty) {
      CustomSnackbar.show(
        "Mohon isi lokasi / tempat kejadian",
        warna: Colors.red,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Warna.backgroundIjo, Warna.backgroundBiru],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleBackNavigation,
        ),
        title: Row(
          children: [
            Image.asset('assets/logo/Image.png', height: 30, width: 30),
            const SizedBox(width: 8),
            const Text(
              "SENTRA",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Spacer(),
            const Text(
              "Laporan",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getFormBackgroundColors(),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "FORMULIR PENGADUAN",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey[800],
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    MiniStepper(currentStep: _currentStep - 1),
                  ],
                ),
              ),

              // Make the entire content scrollable including buttons
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      _buildCurrentForm(),

                      SizedBox(height: 20),

                      // Button container moved here to be part of scrollable content
                      Container(
                        padding: EdgeInsets.only(
                          left: 12,
                          right: 12,
                          bottom: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentStep > 1)
                              Expanded(
                                child: Container(
                                  height: 52,
                                  margin: EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Warna.backgroundBiru.withOpacity(0.9),
                                        Warna().darken(
                                          Warna.backgroundBiru,
                                          0.15,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(0),
                                      topRight: Radius.circular(0),
                                      bottomRight: Radius.circular(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Warna.backgroundBiru.withOpacity(
                                          0.3,
                                        ),
                                        spreadRadius: 0,
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _prevStep,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_back_ios,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "Kembali",
                                          style: TextStyle(
                                            fontFamily: "Mulish",
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Container(
                                height: 52,
                                margin: EdgeInsets.only(
                                  left: _currentStep > 1 ? 0 : 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Warna.backgroundIjo,
                                      Warna().darken(Warna.backgroundIjo, 0.15),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(0),
                                    topRight: Radius.circular(0),
                                    bottomRight: Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Warna.backgroundIjo.withOpacity(
                                        0.3,
                                      ),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      _currentStep < 3
                                          ? _nextStep
                                          : _showPreviewDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentStep < 3 ? "Lanjut" : "Submit",
                                        style: TextStyle(
                                          fontFamily: "Mulish",
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        _currentStep < 3
                                            ? Icons.arrow_forward_ios
                                            : Icons.send,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(context).padding.bottom > 0 ? 70 : 80,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getFormBackgroundColors() {
    switch (_currentStep) {
      case 1:
        return [Colors.blue[50]!, Colors.white];
      case 2:
        return [Colors.deepOrange[50]!, Colors.white];
      case 3:
        return [Colors.teal[50]!, Colors.white];
      default:
        return [Colors.blue[50]!, Colors.white];
    }
  }

  Widget _buildCurrentForm() {
    switch (_currentStep) {
      case 1:
        return _buildFormulir1();
      case 2:
        return _buildFormulir2();
      case 3:
        return _buildFormulir3();
      default:
        return _buildFormulir1();
    }
  }

  /// Nilai opsional: string kosong dikirim sebagai null agar backend tidak
  /// menyimpan placeholder palsu.
  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  /// Satu sumber pembentukan payload PPA: setiap bagian diambil dari state
  /// pihaknya masing-masing, bukan disalin dari pelapor.
  Map<String, dynamic> _buildLaporanPayload(int idAkun) {
    final pelaporNik = _nikform1.text.trim();
    final pelaporNama = _namaform1.text.trim();
    final pelaporTelepon = _telpform1.text.trim();
    final pelaporAlamat = _alamatform1.text.trim();

    final pelapor = {
      'nik': pelaporNik,
      'nama': pelaporNama,
      'alamat': pelaporAlamat,
      'no_telp': pelaporTelepon,
      'hubungan_dengan_korban': _optionalText(_hubunganform1),
    };

    // Penerima = pelapor: identitas yang sama, diturunkan dari satu sumber.
    // Penerima berbeda: seluruh data berasal dari state penerima.
    final penerima =
        _penerimaSamaDenganPelapor
            ? {
              'nik': pelaporNik,
              'nama': pelaporNama,
              'alamat': pelaporAlamat,
              'notelp': pelaporTelepon,
            }
            : {
              'nik': _optionalText(_nikPenerima),
              'nama': _optionalText(_namaPenerima),
              'tempat_lahir': _optionalText(_tempatLahirPenerima),
              'tanggal_lahir': _optionalText(_tanggalLahirPenerima),
              'umur': _optionalText(_umurPenerima),
              'jenis_kelamin': _jenisKelaminPenerima,
              'pekerjaan': _optionalText(_pekerjaanPenerima),
              'agama': _agamaPenerima,
              'alamat': _optionalText(_alamatPenerima),
              'pendidikan': _pendidikanPenerima,
              'hubungan_dengan_terlapor': _optionalText(
                _hubunganTerlaporPenerima,
              ),
              'notelp': _optionalText(_telpPenerima),
              'informasi_tambahan': _optionalText(_infoTambahanPenerima),
            };

    final terlapor =
        _sertakanTerlapor
            ? {
              'nik': _optionalText(_nikTerlapor),
              'nama': _optionalText(_namaTerlapor),
              'umur': _optionalText(_umurTerlapor),
              'alamat': _optionalText(_alamatTerlapor),
              'jenis_kelamin': _jenisKelaminTerlapor,
              'hubungan_dengan_korban': _optionalText(_hubunganTerlapor),
              'informasi_tambahan': _optionalText(_infoTambahanTerlapor),
            }
            : null;

    final informasiAnak =
        _sertakanAnak
            ? _anakList
                .map(
                  (anak) => {
                    'nama': _optionalText(anak.nama),
                    'tanggal_lahir': _optionalText(anak.tanggalLahir),
                    'umur': _optionalText(anak.umur),
                    'jenis_kelamin': anak.jenisKelamin,
                    'pendidikan': anak.pendidikan,
                    'agama': anak.agama,
                    'status': anak.status,
                  },
                )
                .toList()
            : <Map<String, dynamic>>[];

    return {
      'id_akun': idAkun,
      'kategori': 'unset',
      'detail_pelapor': pelapor,
      'detail_penerima_manfaat': penerima,
      'detail_terlapor': terlapor,
      'detail_kasus': {
        'tanggal': _tanggalController.text.trim(),
        'waktu_kejadian': (_waktuKejadian ?? DateTime.now()).toIso8601String(),
        'tempat_kejadian': _tempatkejadianform3.text.trim(),
        'kronologi': _kronologiform4.text.trim(),
      },
      'informasi_anak': informasiAnak,
    };
  }

  void _showPreviewDialog() async {
    if (!_validateForm3()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idAkun = userProvider.idAkun;
    if (idAkun == null) {
      CustomSnackbar.show(
        "Silakan login terlebih dahulu untuk mengirim laporan",
        warna: Colors.orange,
        tinggi: 100,
        icon: Icons.error_outline_rounded,
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    Map<String, dynamic> laporanData = _buildLaporanPayload(idAkun);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Column(
              children: [
                // Header dengan desain menarik
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Warna.backgroundIjo,
                        Warna().darken(Warna.backgroundIjo, 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.preview_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pratinjau Laporan",
                              style: TextStyle(
                                fontFamily: "Mulish",
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Periksa kembali data sebelum mengirim",
                              style: TextStyle(
                                fontFamily: "Mulish",
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content dengan scroll
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEnhancedPreviewSection(
                          "Data Diri Pelapor",
                          {
                            'nik': _nikform1.text.trim(),
                            'nama': _namaform1.text.trim(),
                            'no_telepon': _telpform1.text.trim(),
                            'alamat': _alamatform1.text.trim(),
                          },
                          Icons.person_outline,
                          Colors.blue,
                        ),
                        ..._buildPartyPreviewSections(),
                        SizedBox(height: 16),

                        _buildEnhancedPreviewSection(
                          "Kronologi Kejadian",
                          {'kronologi': _kronologiform4.text.trim()},
                          Icons.history_edu_outlined,
                          Colors.deepOrange,
                        ),
                        SizedBox(height: 16),

                        _buildEnhancedPreviewSection(
                          "Waktu & Lokasi Kejadian",
                          {
                            'tanggal_kejadian': _tanggalController.text.trim(),
                            'waktu_kejadian':
                                (_waktuKejadian ?? DateTime.now())
                                    .toIso8601String(),
                            'lokasi_kejadian': _tempatkejadianform3.text.trim(),
                          },
                          Icons.location_on_outlined,
                          Colors.teal,
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.close, size: 18),
                        label: Text(
                          "Batal",
                          style: TextStyle(fontFamily: "Mulish"),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_isSubmitting) return;
                          _isSubmitting = true;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.black54,
                            builder:
                                (context) => PopScope(
                                  canPop: false,
                                  child: Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                        28,
                                        30,
                                        28,
                                        26,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.14,
                                            ),
                                            blurRadius: 28,
                                            offset: const Offset(0, 12),
                                          ),
                                        ],
                                      ),
                                      child: MediaQuery.withClampedTextScaling(
                                        minScaleFactor: 1.0,
                                        maxScaleFactor: 1.3,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 64,
                                              height: 64,
                                              padding: const EdgeInsets.all(18),
                                              decoration: BoxDecoration(
                                                color: Warna.backgroundIjo
                                                    .withValues(alpha: 0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child:
                                                  const CircularProgressIndicator(
                                                    strokeWidth: 3,
                                                    color:
                                                        Warna.backgroundIjo,
                                                  ),
                                            ),
                                            const SizedBox(height: 20),
                                            const Text(
                                              "Mengirim laporan...",
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: "Mulish",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1F2A37),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              "Mohon tunggu sebentar, jangan tutup aplikasi.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: "Mulish",
                                                fontSize: 12.5,
                                                height: 1.4,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          );

                          try {
                            final created = await laporanController
                                .createReport(laporanData);

                            if (!context.mounted) return;

                            Navigator.of(context).pop();
                            Navigator.of(context).pop();

                            final idLaporan =
                                created?['id_laporan']?.toString() ?? '';
                            CustomSnackbar.show(
                              idLaporan.isEmpty
                                  ? "Laporan berhasil dikirim"
                                  : "Laporan berhasil dikirim. ID: $idLaporan",
                              warna: Colors.green,
                              tinggi: 110,
                              icon: Icons.check_circle_outline_rounded,
                            );

                            _resetForm();
                          } catch (e) {
                            if (!context.mounted) return;

                            Navigator.of(context).pop();

                            final String message =
                                e.toString().replaceFirst(
                                  'ApiException: ',
                                  '',
                                );
                            CustomSnackbar.show(
                              message.isEmpty
                                  ? "Gagal mengirim laporan"
                                  : message,
                              warna: Colors.red,
                              tinggi: 110,
                              icon: Icons.error_outline_rounded,
                            );
                          } finally {
                            _isSubmitting = false;
                          }
                        },
                        icon: Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          "Kirim Laporan",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Warna().darken(
                            Warna.backgroundIjo,
                            0.1,
                          ),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedPreviewSection(
    String title,
    Map<String, dynamic> data,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: accentColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children:
                  data.entries.map((entry) {
                    String key = entry.key;
                    String value = entry.value?.toString() ?? '-';

                    String displayKey = _formatFieldName(key);

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              displayKey + ":",
                              style: TextStyle(
                                fontFamily: "Mulish",
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              value.isEmpty ? '-' : value,
                              style: TextStyle(
                                fontFamily: "Mulish",
                                fontSize: 13,
                                color:
                                    value.isEmpty
                                        ? Colors.grey
                                        : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Hanya menampilkan field yang benar-benar terisi agar data kosong tidak
  /// muncul sebagai placeholder "-" pada pratinjau.
  Map<String, String> _filledPreviewData(Map<String, String?> values) {
    return {
      for (final entry in values.entries)
        if ((entry.value ?? '').trim().isNotEmpty)
          entry.key: entry.value!.trim(),
    };
  }

  List<Widget> _buildPartyPreviewSections() {
    final widgets = <Widget>[];

    if (_penerimaSamaDenganPelapor) {
      final rows = _filledPreviewData({
        'NIK': _nikform1.text,
        'Nama': _namaform1.text,
        'No. Telepon': _telpform1.text,
        'Alamat': _alamatform1.text,
      });
      if (rows.isNotEmpty) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(
          _buildIdentitySummary(
            title: 'Penerima manfaat sama dengan pelapor',
            rows: rows,
          ),
        );
      }
    } else {
      final penerima = _filledPreviewData({
        'nik': _nikPenerima.text,
        'nama': _namaPenerima.text,
        'tempat_lahir': _tempatLahirPenerima.text,
        'tanggal_lahir': _tanggalLahirPenerima.text,
        'umur': _umurPenerima.text,
        'jenis_kelamin': _jenisKelaminPenerima,
        'pekerjaan': _pekerjaanPenerima.text,
        'agama': _agamaPenerima,
        'pendidikan': _pendidikanPenerima,
        'alamat': _alamatPenerima.text,
        'hubungan_dengan_terlapor': _hubunganTerlaporPenerima.text,
        'no_telepon': _telpPenerima.text,
        'informasi_tambahan': _infoTambahanPenerima.text,
      });
      if (penerima.isNotEmpty) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(
          _buildEnhancedPreviewSection(
            'Penerima Manfaat',
            penerima,
            Icons.volunteer_activism_outlined,
            Colors.indigo,
          ),
        );
      }
    }

    if (_sertakanTerlapor) {
      final terlapor = _filledPreviewData({
        'nik': _nikTerlapor.text,
        'nama': _namaTerlapor.text,
        'umur': _umurTerlapor.text,
        'alamat': _alamatTerlapor.text,
        'jenis_kelamin': _jenisKelaminTerlapor,
        'hubungan_dengan_korban': _hubunganTerlapor.text,
        'informasi_tambahan': _infoTambahanTerlapor.text,
      });
      if (terlapor.isNotEmpty) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(
          _buildEnhancedPreviewSection(
            'Terlapor',
            terlapor,
            Icons.gavel_outlined,
            Colors.deepOrange,
          ),
        );
      }
    }

    if (_sertakanAnak) {
      for (var index = 0; index < _anakList.length; index++) {
        final anak = _anakList[index];
        final data = _filledPreviewData({
          'nama': anak.nama.text,
          'tanggal_lahir': anak.tanggalLahir.text,
          'umur': anak.umur.text,
          'jenis_kelamin': anak.jenisKelamin,
          'pendidikan': anak.pendidikan,
          'agama': anak.agama,
          'status': anak.status,
        });
        if (data.isEmpty) continue;
        widgets.add(const SizedBox(height: 16));
        widgets.add(
          _buildEnhancedPreviewSection(
            'Anak ke-${index + 1}',
            data,
            Icons.child_care_outlined,
            Colors.purple,
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildChildInfoCard(String title, Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: "Mulish",
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.purple.shade600,
            ),
          ),
          SizedBox(height: 8),
          ...data.entries.map((entry) {
            String displayKey = _formatFieldName(entry.key);
            String value = entry.value?.toString() ?? '-';

            return Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      displayKey + ":",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value.isEmpty ? '-' : value,
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .split('_')
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : word,
        )
        .join(' ');
  }

  void _resetForm() {
    _nikform1.clear();
    _namaform1.clear();
    _alamatform1.clear();
    _telpform1.clear();
    _hubunganform1.clear();
    _nikPenerima.clear();
    _namaPenerima.clear();
    _tempatLahirPenerima.clear();
    _tanggalLahirPenerima.clear();
    _umurPenerima.clear();
    _pekerjaanPenerima.clear();
    _alamatPenerima.clear();
    _hubunganTerlaporPenerima.clear();
    _telpPenerima.clear();
    _infoTambahanPenerima.clear();
    _nikTerlapor.clear();
    _namaTerlapor.clear();
    _umurTerlapor.clear();
    _alamatTerlapor.clear();
    _hubunganTerlapor.clear();
    _infoTambahanTerlapor.clear();
    _kronologiform4.clear();
    _tanggalController.clear();
    _tempatkejadianform3.clear();
    _waktuKejadian = null;
    _hasRequestedLocation = false;
    _isFetchingLocation = false;
    for (final anak in _anakList) {
      anak.dispose();
    }
    _anakList.clear();
    setState(() {
      _currentStep = 1;
      _penerimaSamaDenganPelapor = true;
      _jenisKelaminPenerima = null;
      _agamaPenerima = null;
      _pendidikanPenerima = null;
      _sertakanTerlapor = false;
      _jenisKelaminTerlapor = null;
      _sertakanAnak = false;
    });
  }

  Widget _buildPreviewSection(String title, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: "Mulish",
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 5),
        ...data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Text(
              "${entry.key.replaceAll('_', ' ').capitalize()}: ${entry.value}",
              style: TextStyle(fontFamily: "Mulish", fontSize: 14),
            ),
          );
        }),
        SizedBox(height: 10),
      ],
    );
  }

  void _submitForm() {
    _showPreviewDialog();
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulir1() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[50]!, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Data Diri",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Formulir 1 dari 3: Data Diri Pelapor",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // NIK Field
              _buildEnhancedTextField(
                label: 'NIK (Nomor Induk Kependudukan)',
                controller: _nikform1,
                keyboardType: TextInputType.number,
                icon: Icons.credit_card,
                themeColor: Colors.blue[600]!,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),

              // Nama Field
              _buildEnhancedTextField(
                label: 'Nama Lengkap',
                controller: _namaform1,
                keyboardType: TextInputType.name,
                icon: Icons.person_outline,
                themeColor: Colors.blue[600]!,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  LengthLimitingTextInputFormatter(50),
                ],
              ),

              // Telepon Field
              _buildEnhancedTextField(
                label: 'No. Telepon / WhatsApp',
                controller: _telpform1,
                keyboardType: TextInputType.phone,
                icon: Icons.phone_outlined,
                themeColor: Colors.blue[600]!,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
              ),

              // Alamat Field
              AddressAutocompleteEnhanced(
                label: "Alamat Lengkap",
                themeColor: Colors.blue[600]!,
                controller: _alamatform1,
              ),

              SizedBox(height: 8),
              _buildPenerimaSection(),

              SizedBox(height: 16),
              _buildTerlaporSection(),

              SizedBox(height: 16),
              _buildAnakSection(),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    IconData? icon,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
    int maxLines = 1,
    Widget? suffixIcon,
    required Color themeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textCapitalization: textCapitalization ?? TextCapitalization.none,
              maxLines: maxLines,
              cursorColor: themeColor,
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 16,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: suffixIcon,
                prefixIcon:
                    icon != null
                        ? Container(
                          margin: EdgeInsets.all(12),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: themeColor, size: 20),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 1),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: maxLines > 1 ? 16 : 16,
                  horizontal: icon != null ? 8 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Mulish',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.grey[600],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  Widget _buildPenerimaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleCard(
          title: 'Penerima Manfaat',
          subtitle:
              _penerimaSamaDenganPelapor
                  ? 'Identitas penerima mengikuti pelapor'
                  : 'Isi identitas penerima manfaat',
          icon: Icons.volunteer_activism_outlined,
          color: Colors.indigo,
          value: _penerimaSamaDenganPelapor,
          onChanged: (value) {
            setState(() => _penerimaSamaDenganPelapor = value);
          },
        ),
        if (_penerimaSamaDenganPelapor)
          AnimatedBuilder(
            animation: Listenable.merge([
              _nikform1,
              _namaform1,
              _telpform1,
              _alamatform1,
            ]),
            builder:
                (context, _) => _buildIdentitySummary(
                  title: 'Data penerima disalin dari pelapor',
                  rows: {
                    'NIK': _nikform1.text.trim(),
                    'Nama': _namaform1.text.trim(),
                    'No. Telepon': _telpform1.text.trim(),
                    'Alamat': _alamatform1.text.trim(),
                  },
                ),
          )
        else
          _buildPartyFields(
            color: Colors.indigo,
            children: [
              _buildEnhancedTextField(
                label: 'NIK Penerima Manfaat',
                controller: _nikPenerima,
                keyboardType: TextInputType.number,
                icon: Icons.credit_card,
                themeColor: Colors.indigo,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              _buildEnhancedTextField(
                label: 'Nama Penerima Manfaat',
                controller: _namaPenerima,
                keyboardType: TextInputType.name,
                icon: Icons.person_outline,
                themeColor: Colors.indigo,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  LengthLimitingTextInputFormatter(50),
                ],
              ),
              _buildEnhancedTextField(
                label: 'Tempat Lahir',
                controller: _tempatLahirPenerima,
                icon: Icons.location_city_outlined,
                themeColor: Colors.indigo,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
              _buildDateField(
                label: 'Tanggal Lahir',
                controller: _tanggalLahirPenerima,
                themeColor: Colors.indigo,
              ),
              _buildEnhancedTextField(
                label: 'Umur',
                controller: _umurPenerima,
                keyboardType: TextInputType.number,
                icon: Icons.cake_outlined,
                themeColor: Colors.indigo,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              _buildDropdownField(
                label: 'Jenis Kelamin',
                icon: Icons.wc_outlined,
                themeColor: Colors.indigo,
                value: _jenisKelaminPenerima,
                items: const ['Laki-laki', 'Perempuan'],
                onChanged: (value) {
                  setState(() => _jenisKelaminPenerima = value);
                },
              ),
              _buildEnhancedTextField(
                label: 'Pekerjaan',
                controller: _pekerjaanPenerima,
                icon: Icons.work_outline,
                themeColor: Colors.indigo,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
              _buildDropdownField(
                label: 'Agama',
                icon: Icons.menu_book_outlined,
                themeColor: Colors.indigo,
                value: _agamaPenerima,
                items: const [
                  'Islam',
                  'Kristen',
                  'Katolik',
                  'Hindu',
                  'Buddha',
                  'Konghucu',
                  'Lainnya',
                ],
                onChanged: (value) {
                  setState(() => _agamaPenerima = value);
                },
              ),
              _buildDropdownField(
                label: 'Pendidikan',
                icon: Icons.school_outlined,
                themeColor: Colors.indigo,
                value: _pendidikanPenerima,
                items: const [
                  'Tidak Sekolah',
                  'SD',
                  'SMP',
                  'SMA',
                  'Diploma',
                  'S1',
                  'S2',
                  'S3',
                  'Lainnya',
                ],
                onChanged: (value) {
                  setState(() => _pendidikanPenerima = value);
                },
              ),
              _buildEnhancedTextField(
                label: 'Alamat Penerima Manfaat',
                controller: _alamatPenerima,
                icon: Icons.home_outlined,
                themeColor: Colors.indigo,
                maxLines: 2,
                inputFormatters: [LengthLimitingTextInputFormatter(255)],
              ),
              _buildEnhancedTextField(
                label: 'Hubungan dengan Terlapor',
                controller: _hubunganTerlaporPenerima,
                icon: Icons.people_alt_outlined,
                themeColor: Colors.indigo,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
              _buildEnhancedTextField(
                label: 'No. Telepon Penerima',
                controller: _telpPenerima,
                keyboardType: TextInputType.phone,
                icon: Icons.phone_outlined,
                themeColor: Colors.indigo,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
              ),
              _buildEnhancedTextField(
                label: 'Informasi Tambahan',
                controller: _infoTambahanPenerima,
                icon: Icons.notes_outlined,
                themeColor: Colors.indigo,
                maxLines: 3,
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTerlaporSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleCard(
          title: 'Terlapor (opsional)',
          subtitle:
              _sertakanTerlapor
                  ? 'Isi identitas terlapor jika diketahui'
                  : 'Aktifkan jika identitas terlapor diketahui',
          icon: Icons.gavel_outlined,
          color: Colors.deepOrange,
          value: _sertakanTerlapor,
          onChanged: (value) {
            setState(() => _sertakanTerlapor = value);
          },
        ),
        if (_sertakanTerlapor)
          _buildPartyFields(
            color: Colors.deepOrange,
            children: [
              _buildEnhancedTextField(
                label: 'NIK Terlapor',
                controller: _nikTerlapor,
                keyboardType: TextInputType.number,
                icon: Icons.credit_card,
                themeColor: Colors.deepOrange,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              _buildEnhancedTextField(
                label: 'Nama Terlapor',
                controller: _namaTerlapor,
                keyboardType: TextInputType.name,
                icon: Icons.person_outline,
                themeColor: Colors.deepOrange,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  LengthLimitingTextInputFormatter(100),
                ],
              ),
              _buildEnhancedTextField(
                label: 'Umur',
                controller: _umurTerlapor,
                keyboardType: TextInputType.number,
                icon: Icons.cake_outlined,
                themeColor: Colors.deepOrange,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              _buildEnhancedTextField(
                label: 'Alamat',
                controller: _alamatTerlapor,
                icon: Icons.home_outlined,
                themeColor: Colors.deepOrange,
                maxLines: 2,
                inputFormatters: [LengthLimitingTextInputFormatter(255)],
              ),
              _buildDropdownField(
                label: 'Jenis Kelamin',
                icon: Icons.wc_outlined,
                themeColor: Colors.deepOrange,
                value: _jenisKelaminTerlapor,
                items: const ['Laki-laki', 'Perempuan'],
                onChanged: (value) {
                  setState(() => _jenisKelaminTerlapor = value);
                },
              ),
              _buildEnhancedTextField(
                label: 'Hubungan dengan Korban',
                controller: _hubunganTerlapor,
                icon: Icons.people_alt_outlined,
                themeColor: Colors.deepOrange,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
              _buildEnhancedTextField(
                label: 'Informasi Tambahan',
                controller: _infoTambahanTerlapor,
                icon: Icons.notes_outlined,
                themeColor: Colors.deepOrange,
                maxLines: 3,
                inputFormatters: [LengthLimitingTextInputFormatter(255)],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAnakSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleCard(
          title: 'Informasi Anak (opsional)',
          subtitle:
              _sertakanAnak
                  ? 'Tambahkan data anak yang terlibat'
                  : 'Aktifkan jika kasus melibatkan anak',
          icon: Icons.child_care_outlined,
          color: Colors.purple,
          value: _sertakanAnak,
          onChanged: (value) {
            setState(() => _sertakanAnak = value);
          },
        ),
        if (_sertakanAnak) ...[
          if (_anakList.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.purple.shade400,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Belum ada data anak. Tekan "Tambah Anak" jika diperlukan.',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ...List.generate(_anakList.length, _buildAnakCard),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addAnak,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Tambah Anak'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: BorderSide(color: Colors.purple.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else if (_anakList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              '${_anakList.length} data anak tersimpan namun tidak akan dikirim.',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAnakCard(int index) {
    final anak = _anakList[index];
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.purple.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.child_care,
                  size: 18,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Anak ke-${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.purple,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Hapus data anak',
                onPressed: () => _removeAnak(index),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildEnhancedTextField(
            label: 'Nama Anak',
            controller: anak.nama,
            icon: Icons.person_outline,
            themeColor: Colors.purple,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              LengthLimitingTextInputFormatter(100),
            ],
          ),
          _buildDateField(
            label: 'Tanggal Lahir',
            controller: anak.tanggalLahir,
            themeColor: Colors.purple,
          ),
          _buildEnhancedTextField(
            label: 'Umur',
            controller: anak.umur,
            keyboardType: TextInputType.number,
            icon: Icons.cake_outlined,
            themeColor: Colors.purple,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
          ),
          _buildDropdownField(
            label: 'Jenis Kelamin',
            icon: Icons.wc_outlined,
            themeColor: Colors.purple,
            value: anak.jenisKelamin,
            items: const ['Laki-laki', 'Perempuan'],
            onChanged: (value) {
              setState(() => anak.jenisKelamin = value);
            },
          ),
          _buildDropdownField(
            label: 'Pendidikan',
            icon: Icons.school_outlined,
            themeColor: Colors.purple,
            value: anak.pendidikan,
            items: const [
              'Tidak Sekolah',
              'PAUD',
              'TK',
              'SD',
              'SMP',
              'SMA',
              'Lainnya',
            ],
            onChanged: (value) {
              setState(() => anak.pendidikan = value);
            },
          ),
          _buildDropdownField(
            label: 'Agama',
            icon: Icons.menu_book_outlined,
            themeColor: Colors.purple,
            value: anak.agama,
            items: const [
              'Islam',
              'Kristen',
              'Katolik',
              'Hindu',
              'Buddha',
              'Konghucu',
              'Lainnya',
            ],
            onChanged: (value) {
              setState(() => anak.agama = value);
            },
          ),
          _buildDropdownField(
            label: 'Status Anak',
            icon: Icons.family_restroom_outlined,
            themeColor: Colors.purple,
            value: anak.status,
            items: const ['Anak Kandung', 'Anak Angkat'],
            onChanged: (value) {
              setState(() => anak.status = value);
            },
          ),
        ],
      ),
    );
  }

  void _addAnak() {
    if (_anakList.length >= 10) {
      CustomSnackbar.show(
        'Maksimal 10 data anak dalam satu laporan',
        warna: Colors.orange,
      );
      return;
    }
    setState(() => _anakList.add(_AnakFormData()));
  }

  void _removeAnak(int index) {
    final removed = _anakList.removeAt(index);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPartyFields({
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildIdentitySummary({
    required String title,
    required Map<String, String> rows,
  }) {
    final entries =
        rows.entries.where((entry) => entry.value.trim().isNotEmpty).toList();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, size: 16, color: Colors.indigo),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            Text(
              'Lengkapi data pelapor di atas.',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            )
          else
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(
                        '${entry.key}:',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required Color themeColor,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(icon, color: themeColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      hint: Text(
                        'Pilih $label',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                      items:
                          items
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required Color themeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: true,
            onTap: () => _pickDate(controller: controller),
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 16,
              color: Colors.grey[800],
            ),
            decoration: InputDecoration(
              hintText: 'Pilih tanggal',
              hintStyle: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                color: Colors.grey[500],
              ),
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: Icon(
                Icons.calendar_month_outlined,
                color: themeColor,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required TextEditingController controller}) async {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(controller.text);
    final initialDate =
        parsed != null && !parsed.isAfter(now) ? parsed : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => controller.text = _formatDateForApi(picked));
    }
  }

  Widget _buildFormulir2() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepOrange[50]!, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange[600]!, Colors.deepOrange[400]!],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.history_edu_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kronologi Kejadian",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Formulir 2 dari 3: Ceritakan kronologi kejadian",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Kronologi Text Area
              _buildKronologiTextArea(themeColor: Colors.deepOrange[600]!),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormulir3() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal[50]!, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal[600]!, Colors.teal[400]!],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tanggal & Lokasi Kejadian",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Formulir 3 dari 3: Waktu dan tempat kejadian",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Date Picker Field
              _buildDatePickerField(themeColor: Colors.teal[600]!),

              // Tempat Kejadian Field
              _buildEnhancedTextField(
                label: 'Lokasi / Tempat Kejadian',
                controller: _tempatkejadianform3,
                keyboardType: TextInputType.streetAddress,
                icon: Icons.location_on_outlined,
                themeColor: Colors.teal[600]!,
                maxLines: 2,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                suffixIcon:
                    _isFetchingLocation
                        ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : null,
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKronologiTextArea({required Color themeColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Kronologi Kejadian',
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),

          // Character Counter Container
          Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tuliskan secara detail dan kronologis',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _kronologiform4,
                  builder: (context, value, child) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        '${value.text.length} karakter',
                        style: TextStyle(
                          fontSize: 11,
                          color: themeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _kronologiform4,
              maxLines: 15,
              cursorColor: themeColor,
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
                hintText:
                    'Ceritakan kejadian secara detail:\n\n• Kapan kejadian dimulai?\n• Siapa saja yang terlibat?\n• Apa yang terjadi?\n• Bagaimana urutan kejadiannya?\n• Dimana kejadian berlangsung?\n• Saksi yang melihat kejadian?',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.4,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeColor, width: 2),
                ),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),

          // Tips Container
          Container(
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: themeColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: themeColor, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tips: Semakin detail kronologi yang Anda berikan, semakin mudah untuk memproses kasus ini',
                    style: TextStyle(
                      fontSize: 11,
                      color: themeColor,
                      fontFamily: "Mulish",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({required Color themeColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tanggal Kejadian',
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _tanggalController,
              readOnly: true,
              cursorColor: themeColor,
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: themeColor,
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: themeColor,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  final previousTime = _waktuKejadian ?? DateTime.now();
                  setState(() {
                    _tanggalController.text = _formatDateForApi(pickedDate);
                    _waktuKejadian = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      previousTime.hour,
                      previousTime.minute,
                      previousTime.second,
                    );
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Pilih tanggal kejadian',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Container(
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: themeColor,
                    size: 20,
                  ),
                ),
                suffixIcon: Icon(Icons.keyboard_arrow_down, color: themeColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeColor, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // Date info
          if (_tanggalController.text.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Icon(Icons.check_circle_outline, color: themeColor, size: 14),
                  Text(
                    'Kejadian: ${_formatDateToReadable(_tanggalController.text)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: themeColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(_waktuKejadian ?? DateTime.now()).hour.toString().padLeft(2, '0')}:'
                    '${(_waktuKejadian ?? DateTime.now()).minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 11,
                      color: themeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Ubah waktu kejadian',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () async {
                      final currentTime = _waktuKejadian ?? DateTime.now();
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(currentTime),
                        builder:
                            (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: themeColor,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            ),
                      );
                      if (pickedTime != null && mounted) {
                        setState(() {
                          _waktuKejadian = DateTime(
                            currentTime.year,
                            currentTime.month,
                            currentTime.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: themeColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper method untuk format tanggal yang lebih readable
  String _formatDateToReadable(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      DateTime date = DateTime.parse(dateString);
      List<String> months = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
