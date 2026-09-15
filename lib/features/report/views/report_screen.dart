import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/report/controllers/report_controller.dart';
import 'package:sentra/core/utils/address_field.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/features/report/views/widgets/stepper_widget.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';
import 'package:sentra/core/utils/custom_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class AnakFormController {
  TextEditingController namaController = TextEditingController();
  TextEditingController tanggalLahirController = TextEditingController();
  TextEditingController jenis_kelaminController = TextEditingController();
  TextEditingController umurController = TextEditingController();
  TextEditingController pendidikanController = TextEditingController();
  TextEditingController agamaController = TextEditingController();
  TextEditingController statusController = TextEditingController();
}

class _LaporanPageState extends State<LaporanPage> {
  int _currentStep = 1;
  final int _jumlah = 1;
  String? _selectedOptionAnak;
  String? _selectedOptionPelaku;
  String? _selectedDropdownValue;
  final LaporanController laporanController = LaporanController();
  List<AnakFormController> listAnakControllers = [];
  List<Map<String, String>> informasiAnak = [];

  // Form 1
  final TextEditingController _nikform1 = TextEditingController();
  final TextEditingController _namaform1 = TextEditingController();
  final TextEditingController _umurform1 = TextEditingController();
  final TextEditingController _alamatform1 = TextEditingController();
  final TextEditingController _hubunganform1 = TextEditingController();
  final TextEditingController _telpform1 = TextEditingController();
  // Form 2
  final TextEditingController _nikform2 = TextEditingController();
  final TextEditingController _namaform2 = TextEditingController();
  final TextEditingController _templform2 = TextEditingController();
  final TextEditingController _tanglform2 = TextEditingController();
  final TextEditingController _umurform2 = TextEditingController();
  final TextEditingController _jeniskelaminform2 = TextEditingController();
  final TextEditingController _alamatform2 = TextEditingController();
  final TextEditingController _pekerjaanform2 = TextEditingController();
  final TextEditingController _agamaform2 = TextEditingController();
  final TextEditingController _pendidikanform2 = TextEditingController();
  final TextEditingController _hubunganform2 = TextEditingController();
  final TextEditingController _telpform2 = TextEditingController();
  final TextEditingController _infromasitambahanform2 = TextEditingController();
  // Form 3
  final TextEditingController _nikform3 = TextEditingController();
  final TextEditingController _namaform3 = TextEditingController();
  final TextEditingController _umurform3 = TextEditingController();
  final TextEditingController _alamatform3 = TextEditingController();
  final TextEditingController _jeniskelaminform3 = TextEditingController();
  final TextEditingController _hubunganform3 = TextEditingController();
  final TextEditingController _informasitambahanform3 = TextEditingController();
  // Form 4
  final TextEditingController _kronologiform4 = TextEditingController();
  // Form 5
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _tempatkejadianform3 = TextEditingController();

  late AnakFormController anakForm;
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

  void _handleRadioAnak(String? value) {
    setState(() {
      _selectedOptionAnak = value;
    });
  }

  void _handleRadioPelaku(String? value) {
    setState(() {
      _selectedOptionPelaku = value;
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
      case 4:
        isValid = _validateForm4();
        break;
      case 5:
        isValid = _validateForm5();
        break;
    }

    if (isValid) {
      setState(() {
        if (_currentStep < 5) _currentStep++;
        if (_selectedOptionPelaku == 'Tidak' && _currentStep == 3) {
          _currentStep++;
        }
      });
    }
  }

  void _prevStep() {
    setState(() {
      if (_selectedOptionPelaku == 'Tidak' && _currentStep == 4) {
        _currentStep--;
      }
      if (_currentStep > 1) _currentStep--;
    });
  }

  @override
  void initState() {
    super.initState();

    anakForm = AnakFormController();

    final namaControllers = [
      _namaform1,
      _namaform2,
      _namaform3,
      _alamatform1,
      _alamatform2,
      _alamatform3,
      _hubunganform1,
      _hubunganform2,
      _hubunganform3,
      _templform2,
      _pekerjaanform2,

      anakForm.namaController,
    ];

    for (var controller in namaControllers) {
      _addAutoCapitalizeListener(controller);
    }
  }

  bool _validateForm1() {
    if (_nikform1.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi NIK pelapor", warna: Colors.red);
      return false;
    }
    if (_namaform1.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi nama lengkap pelapor", warna: Colors.red);
      return false;
    }
    if (_alamatform1.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi alamat pelapor", warna: Colors.red);
      return false;
    }
    if (_hubunganform1.text.trim().isEmpty) {
      CustomSnackbar.show(
        "Mohon isi hubungan dengan korban",
        warna: Colors.red,
      );
      return false;
    }
    if (_telpform1.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi nomor telepon pelapor", warna: Colors.red);
      return false;
    }
    return true;
  }

  // Validator untuk Form 2
  bool _validateForm2() {
    if (_nikform2.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi NIK penerima manfaat", warna: Colors.red);
      return false;
    }
    if (_namaform2.text.trim().isEmpty) {
      CustomSnackbar.show(
        "Mohon isi nama lengkap penerima manfaat",
        warna: Colors.red,
      );
      return false;
    }
    if (_templform2.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi tempat lahir", warna: Colors.red);
      return false;
    }
    if (_tanglform2.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi tanggal lahir", warna: Colors.red);
      return false;
    }
    if (_umurform2.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi umur", warna: Colors.red);
      return false;
    }
    if (_jeniskelaminform2.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon pilih jenis kelamin", warna: Colors.red);
      return false;
    }
    if (_alamatform2.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi alamat", warna: Colors.red);
      return false;
    }
    if (_pekerjaanform2.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi pekerjaan", warna: Colors.red);
      return false;
    }
    if (_agamaform2.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon pilih agama", warna: Colors.red);
      return false;
    }
    if (_pendidikanform2.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon pilih pendidikan", warna: Colors.red);
      return false;
    }
    if (_hubunganform2.text.trim().isEmpty) {
      CustomSnackbar.show(
        "Mohon isi hubungan dengan terlapor",
        warna: Colors.red,
      );
      return false;
    }
    if (_telpform2.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi nomor telepon", warna: Colors.red);
      return false;
    }
    if (_selectedOptionAnak == null) {
      CustomSnackbar.show("Mohon pilih apakah punya anak", warna: Colors.red);
      return false;
    }
    if (_selectedOptionAnak == 'Ya' && _selectedDropdownValue == null) {
      CustomSnackbar.show("Mohon pilih jumlah anak", warna: Colors.red);
      return false;
    }
    if (_selectedOptionAnak == 'Ya') {
      for (var controller in listAnakControllers) {
        if (controller.namaController.text.trim().isEmpty ||
            controller.tanggalLahirController.text.trim().isEmpty ||
            controller.jenis_kelaminController.text.trim().isEmpty ||
            controller.umurController.text.trim().isEmpty ||
            controller.pendidikanController.text.trim().isEmpty ||
            controller.agamaController.text.trim().isEmpty ||
            controller.statusController.text.trim().isEmpty) {
          CustomSnackbar.show(
            "Mohon isi semua data anak dengan lengkap",
            warna: Colors.red,
          );
          return false;
        }
      }
    }
    if (_selectedOptionPelaku == null) {
      CustomSnackbar.show(
        "Mohon pilih apakah menyertakan identitas terlapor",
        warna: Colors.red,
      );
      return false;
    }
    return true;
  }

  bool _validateForm3() {
    if (_selectedOptionPelaku == 'Ya') {
      if (_nikform3.text.trim().isEmpty) {
        CustomSnackbar.show("Mohon isi NIK terlapor", warna: Colors.red);
        return false;
      }
      if (_namaform3.text.trim().isEmpty) {
        CustomSnackbar.show(
          "Mohon isi nama lengkap terlapor",
          warna: Colors.red,
        );
        return false;
      }
      if (_umurform3.text.trim().isEmpty) {
        CustomSnackbar.show("Mohon isi umur terlapor", warna: Colors.red);
        return false;
      }
      if (_alamatform3.text.trim().isEmpty) {
        CustomSnackbar.show("Mohon isi alamat terlapor", warna: Colors.red);
        return false;
      }
      if (_jeniskelaminform3.text.trim().isEmpty) {
        CustomSnackbar.show(
          "Mohon pilih jenis kelamin terlapor",
          warna: Colors.red,
        );
        return false;
      }
      if (_hubunganform3.text.trim().isEmpty) {
        CustomSnackbar.show(
          "Mohon isi hubungan dengan korban",
          warna: Colors.red,
        );
        return false;
      }
    }
    return true;
  }

  // Validator untuk Form 4
  bool _validateForm4() {
    if (_kronologiform4.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi kronologi kejadian", warna: Colors.red);
      return false;
    }
    return true;
  }

  bool _validateForm5() {
    if (_tanggalController.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon pilih tanggal kejadian", warna: Colors.red);
      return false;
    }
    if (_tempatkejadianform3.text.trim().isEmpty) {
      CustomSnackbar.show("Mohon isi tempat kejadian", warna: Colors.red);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                                      _currentStep < 5
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
                                        _currentStep < 5 ? "Lanjut" : "Submit",
                                        style: TextStyle(
                                          fontFamily: "Mulish",
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        _currentStep < 5
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
        return [Colors.red[50]!, Colors.white];
      case 3:
        return [Colors.orange[50]!, Colors.white];
      case 4:
        return [Colors.deepOrange[50]!, Colors.white];
      case 5:
        return [Colors.teal[50]!, Colors.white];
      default:
        return [Colors.green[50]!, Colors.white];
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
      case 4:
        return _buildFormulir4();
      case 5:
        return _buildFormulir5();
      default:
        return _buildFormulir1();
    }
  }

  void _showPreviewDialog() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idAkun = userProvider.idAkun;

    if (_selectedOptionAnak == 'Ya') {
      informasiAnak =
          listAnakControllers.map((anak) {
            return {
              'nama': anak.namaController.text.trim(),
              'tanggal_lahir': anak.tanggalLahirController.text.trim(),
              'umur': anak.umurController.text.trim(),
              'jenis_kelamin': anak.jenis_kelaminController.text.trim(),
              'pendidikan': anak.pendidikanController.text.trim(),
              'agama': anak.agamaController.text.trim(),
              'status': anak.statusController.text.trim(),
            };
          }).toList();
    }

    Map<String, dynamic> laporanData = {
      'id_akun': idAkun,
      'kategori': 'unset',
      'status': 'dikirim',
      'detail_pelapor': {
        'nik': _nikform1.text.trim(),
        'nama': _namaform1.text.trim(),
        'alamat': _alamatform1.text.trim(),
        'hubungan_dengan_korban': _hubunganform1.text.trim(),
        'no_telp': _telpform1.text.trim(),
      },
      'detail_terlapor': {
        'nik': _nikform3.text.trim(),
        'nama': _namaform3.text.trim(),
        'umur': _umurform3.text.trim(),
        'alamat': _alamatform3.text.trim(),
        'jenis_kelamin': _jeniskelaminform3.text.trim(),
        'hubungan_dengan_korban': _hubunganform3.text.trim(),
        'informasi_tambahan': _informasitambahanform3.text.trim(),
      },
      'detail_penerima_manfaat': {
        'nik': _nikform2.text.trim(),
        'nama': _namaform2.text.trim(),
        'Tempat_lahir': _templform2.text.trim(),
        'tanggal_lahir': _tanglform2.text.trim(),
        'umur': _umurform2.text.trim(),
        'jenis_kelamin': _jeniskelaminform3.text.trim(),
        'pekerjaan': _pekerjaanform2.text.trim(),
        'agama': _agamaform2.text.trim(),
        'alamat': _alamatform2.text.trim(),
        'pendidikan': _pendidikanform2.text.trim(),
        'hubungan_dengan_terlapor': _hubunganform3.text.trim(),
        'notelp': _telpform2.text.trim(),
        'informasi_tambahan': _informasitambahanform3.text.trim(),
      },
      'detail_kasus': {
        'tanggal': _tanggalController.text.trim(),
        'tempat_kejadian': _tempatkejadianform3.text.trim(),
        'kronologi': _kronologiform4.text.trim(),
      },
      'informasi_anak': informasiAnak,
    };

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
                          "Detail Pelapor",
                          laporanData['detail_pelapor'],
                          Icons.person_outline,
                          Colors.blue,
                        ),
                        SizedBox(height: 16),

                        _buildEnhancedPreviewSection(
                          "Detail Terlapor",
                          laporanData['detail_terlapor'],
                          Icons.report_problem_outlined,
                          Colors.orange,
                        ),
                        SizedBox(height: 16),

                        _buildEnhancedPreviewSection(
                          "Detail Penerima Manfaat",
                          laporanData['detail_penerima_manfaat'],
                          Icons.favorite_outline,
                          Colors.red,
                        ),
                        SizedBox(height: 16),

                        _buildEnhancedPreviewSection(
                          "Detail Kasus",
                          laporanData['detail_kasus'],
                          Icons.gavel_outlined,
                          Colors.teal,
                        ),
                        SizedBox(height: 16),

                        if (laporanData['informasi_anak'].isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade50,
                                  Colors.purple.shade100,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.purple,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.child_care,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Informasi Anak",
                                      style: TextStyle(
                                        fontFamily: "Mulish",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.purple.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                ...List.generate(
                                  laporanData['informasi_anak'].length,
                                  (index) => Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: _buildChildInfoCard(
                                      "Anak ${index + 1}",
                                      laporanData['informasi_anak'][index],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (context) => Center(
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 16),
                                        Text(
                                          "Mengirim laporan...",
                                          style: TextStyle(
                                            fontFamily: "Mulish",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          );

                          try {
                            await laporanController.createReport(laporanData);

                            if (!context.mounted) return;

                            Navigator.of(context).pop();

                            CustomSnackbar.show("Laporan berhasil dikirim");

                            _resetForm();
                            Navigator.of(context).pop();
                          } catch (e) {
                            if (!context.mounted) return;

                            Navigator.of(context).pop();

                            CustomSnackbar.show("Gagal mengirim laporan");
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
    // Clear semua lists
    listAnakControllers.clear();
    informasiAnak.clear();

    // Clear Form 1 controllers
    _nikform1.clear();
    _namaform1.clear();
    _umurform1.clear();
    _alamatform1.clear();
    _hubunganform1.clear();
    _telpform1.clear();

    // Clear Form 2 controllers
    _nikform2.clear();
    _namaform2.clear();
    _templform2.clear();
    _tanglform2.clear();
    _umurform2.clear();
    _jeniskelaminform2.clear();
    _alamatform2.clear();
    _pekerjaanform2.clear();
    _agamaform2.clear();
    _pendidikanform2.clear();
    _hubunganform2.clear();
    _telpform2.clear();
    _infromasitambahanform2.clear();

    // Clear Form 3 controllers
    _nikform3.clear();
    _namaform3.clear();
    _umurform3.clear();
    _alamatform3.clear();
    _jeniskelaminform3.clear();
    _hubunganform3.clear();
    _informasitambahanform3.clear();

    // Clear Form 4 controller
    _kronologiform4.clear();

    // Clear Form 5 controllers
    _tanggalController.clear();
    _tempatkejadianform3.clear();
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
                    Text(
                      "Identitas Pelapor",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // NIK Field
              _buildEnhancedTextField(
                label: 'NIK',
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

              // Alamat Field
              AddressAutocompleteEnhanced(label: "Alamat Lengkap", themeColor: Colors.blue[600]!, controller: _alamatform1),

              // Hubungan Field
              _buildEnhancedTextField(
                label: 'Hubungan dengan Korban',
                controller: _hubunganform1,
                icon: Icons.family_restroom,
                themeColor: Colors.blue[600]!,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  LengthLimitingTextInputFormatter(30),
                ],
              ),

              // Telepon Field
              _buildEnhancedTextField(
                label: 'No. Telepon',
                controller: _telpform1,
                keyboardType: TextInputType.phone,
                icon: Icons.phone_outlined,
                themeColor: Colors.blue[600]!,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
              ),

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

  void initFormulirAnak(int jumlahAnak) {
    listAnakControllers = List.generate(
      jumlahAnak,
      (_) => AnakFormController(),
    );
  }

  Widget _buildFormulir2() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.red[50]!, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[600]!, Colors.red[400]!],
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
                        Icons.person_4,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Identitas Penerima Manfaat",
                        style: TextStyle(
                          fontFamily: "Mulish",
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              _buildSectionTitle("Data Pribadi", Icons.badge, Colors.red[600]!),

              _buildEnhancedTextField(
                label: 'NIK',
                controller: _nikform2,
                keyboardType: TextInputType.number,
                icon: Icons.credit_card,
                themeColor: Colors.red[600]!,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),

              _buildEnhancedTextField(
                label: 'Nama Lengkap',
                controller: _namaform2,
                icon: Icons.person_outline,
                themeColor: Colors.red[600]!,
                textCapitalization: TextCapitalization.words,
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedTextField(
                      label: 'Tempat Lahir',
                      controller: _templform2,
                      icon: Icons.location_city,
                      themeColor: Colors.red[600]!,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(themeColor: Colors.red[600]!),
                  ),
                ],
              ),

              _buildEnhancedTextField(
                label: 'Umur',
                controller: _umurform2,
                keyboardType: TextInputType.number,
                icon: Icons.cake,
                themeColor: Colors.red[600]!,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),

               AddressAutocompleteEnhanced(
                label: "Alamat Lengkap",
                themeColor: Colors.red[600]!,
                controller: _alamatform2,
              ),


              // Personal Details Section
              _buildSectionTitle(
                "Detail Pribadi",
                Icons.info,
                Colors.red[600]!,
              ),

              _buildEnhancedDropdown(
                label: 'Jenis Kelamin',
                value:
                    _jeniskelaminform2.text.isNotEmpty
                        ? _jeniskelaminform2.text
                        : null,
                items: ['Laki-laki', 'Perempuan'],
                icon: Icons.wc,
                themeColor: Colors.red[600]!,
                onChanged: (String? newValue) {
                  setState(() {
                    _jeniskelaminform2.text = newValue!;
                  });
                },
              ),

              _buildEnhancedTextField(
                label: 'Pekerjaan',
                controller: _pekerjaanform2,
                icon: Icons.work,
                themeColor: Colors.red[600]!,
                textCapitalization: TextCapitalization.words,
              ),

              _buildEnhancedDropdown(
                label: 'Agama',
                value: _agamaform2.text.isNotEmpty ? _agamaform2.text : null,
                items: ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha'],
                icon: Icons.church,
                themeColor: Colors.red[600]!,
                onChanged: (String? newValue) {
                  setState(() {
                    _agamaform2.text = newValue!;
                  });
                },
              ),

              _buildEnhancedDropdown(
                label: 'Pendidikan',
                value:
                    _pendidikanform2.text.isNotEmpty
                        ? _pendidikanform2.text
                        : null,
                items: [
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
                icon: Icons.school,
                themeColor: Colors.red[600]!,
                onChanged: (String? newValue) {
                  setState(() {
                    _pendidikanform2.text = newValue!;
                  });
                },
              ),

              _buildSectionTitle(
                "Kontak & Hubungan",
                Icons.contact_phone,
                Colors.red[600]!,
              ),

              _buildEnhancedTextField(
                label: 'Hubungan dengan Terlapor',
                controller: _hubunganform2,
                icon: Icons.family_restroom,
                themeColor: Colors.red[600]!,
                textCapitalization: TextCapitalization.words,
              ),

              _buildEnhancedTextField(
                label: 'No. Telepon',
                controller: _telpform2,
                keyboardType: TextInputType.phone,
                icon: Icons.phone,
                themeColor: Colors.red[600]!,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
              ),

              _buildEnhancedTextField(
                label: 'Informasi Tambahan',
                controller: _infromasitambahanform2,
                icon: Icons.note,
                themeColor: Colors.red[600]!,
                maxLines: 3,
              ),

              // Family Section
              _buildSectionTitle(
                "Informasi Keluarga",
                Icons.family_restroom,
                Colors.red[600]!,
              ),
              _buildChildrenSection(themeColor: Colors.red[600]!),

              SizedBox(height: 20),

              _buildSectionTitle(
                "Informasi Terlapor",
                Icons.report_problem,
                Colors.red[600]!,
              ),
              _buildPerpetratorSection(themeColor: Colors.red[600]!),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color themeColor) {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: themeColor, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: themeColor, size: 20),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Mulish",
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({required Color themeColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tanggal Lahir',
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
              controller: _tanglform2,
              readOnly: true,
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 16,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
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
                    Icons.calendar_today,
                    color: themeColor,
                    size: 20,
                  ),
                ),
                suffixIcon: Icon(Icons.arrow_drop_down, color: themeColor),
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
                  vertical: 16,
                  horizontal: 8,
                ),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
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
                  String formattedDate =
                      "${pickedDate.year}-"
                      "${pickedDate.month.toString().padLeft(2, '0')}-"
                      "${pickedDate.day.toString().padLeft(2, '0')}";
                  _tanglform2.text = formattedDate;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
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
            child: DropdownButtonFormField<String>(
              value: value,
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Row(
                        children: [
                          if (label == 'Jenis Kelamin') ...[
                            Icon(
                              item == 'Laki-laki' ? Icons.male : Icons.female,
                              color:
                                  item == 'Laki-laki'
                                      ? Colors.blue[600]
                                      : Colors.pink[400],
                              size: 16,
                            ),
                            SizedBox(width: 8),
                          ],
                          Text(
                            item,
                            style: TextStyle(
                              fontFamily: "Mulish",
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Container(
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: themeColor, size: 20),
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
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSection({required Color themeColor}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.child_care, color: themeColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Punya Anak?',
                style: TextStyle(
                  fontFamily: "Mulish",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildRadioOption(
                'Ya',
                _selectedOptionAnak,
                _handleRadioAnak,
                themeColor,
              ),
              SizedBox(width: 20),
              _buildRadioOption(
                'Tidak',
                _selectedOptionAnak,
                _handleRadioAnak,
                themeColor,
              ),
            ],
          ),
          if (_selectedOptionAnak == 'Ya') ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButton<String>(
                hint: Text(
                  "Jumlah Anak",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: "Mulish",
                  ),
                ),
                value: _selectedDropdownValue,
                isExpanded: true,
                underline: SizedBox(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDropdownValue = newValue;
                    initFormulirAnak(int.parse(_selectedDropdownValue!));
                  });
                },
                items:
                    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"].map((
                      String option,
                    ) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
              ),
            ),
            if (_selectedDropdownValue != null) ...[
              SizedBox(height: 16),
              ...List.generate(
                int.parse(_selectedDropdownValue!),
                (index) => _buildFormulirAnak(
                  (index).toString(),
                  themeColor: themeColor,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPerpetratorSection({required Color themeColor}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: themeColor, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ingin menyertakan Identitas Terlapor (Pelaku)?',
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildRadioOption(
                'Ya',
                _selectedOptionPelaku,
                _handleRadioPelaku,
                themeColor,
              ),
              SizedBox(width: 20),
              _buildRadioOption(
                'Tidak',
                _selectedOptionPelaku,
                _handleRadioPelaku,
                themeColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(
    String value,
    String? groupValue,
    Function(String?) onChanged,
    Color activeColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            groupValue == value ? activeColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: groupValue == value ? activeColor : Colors.grey[300]!,
          width: groupValue == value ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            activeColor: activeColor,
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: "Mulish",
              fontWeight: FontWeight.w500,
              color: groupValue == value ? activeColor : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulir3() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.orange[50]!, Colors.white],
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
                    colors: [Colors.orange[600]!, Colors.orange[400]!],
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
                        Icons.person_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Identitas Terlapor (Pelaku)",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // NIK Field
              _buildEnhancedTextField(
                label: 'NIK',
                controller: _nikform3,
                keyboardType: TextInputType.number,
                icon: Icons.credit_card,
                themeColor: Colors.orange[600]!,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),

              // Nama Field
              _buildEnhancedTextField(
                label: 'Nama Lengkap',
                controller: _namaform3,
                keyboardType: TextInputType.name,
                icon: Icons.person_outline,
                themeColor: Colors.orange[600]!,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  LengthLimitingTextInputFormatter(50),
                ],
              ),

              // Umur Field
              _buildEnhancedTextField(
                label: 'Umur',
                controller: _umurform3,
                keyboardType: TextInputType.number,
                icon: Icons.cake_outlined,
                themeColor: Colors.orange[600]!,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),

              // Alamat Field
              AddressAutocompleteEnhanced(
                label: "Alamat Lengkap",
                themeColor: Colors.orange[600]!,
                controller: _alamatform3,
              ),


              // Jenis Kelamin Dropdown
              _buildGenderDropdown(themeColor: Colors.orange[600]!),

              // Hubungan Field
              _buildEnhancedTextField(
                label: 'Hubungan dengan Korban',
                controller: _hubunganform3,
                icon: Icons.people_outline,
                themeColor: Colors.orange[600]!,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  LengthLimitingTextInputFormatter(30),
                ],
              ),

              // Informasi Tambahan Field
              _buildEnhancedTextField(
                label: 'Informasi Tambahan',
                controller: _informasitambahanform3,
                icon: Icons.info_outline,
                themeColor: Colors.orange[600]!,
                maxLines: 3,
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown({required Color themeColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jenis Kelamin',
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
            child: DropdownButtonFormField<String>(
              value:
                  _jeniskelaminform3.text.isNotEmpty
                      ? _jeniskelaminform3.text
                      : null,
              icon: Icon(Icons.keyboard_arrow_down, color: themeColor),
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 16,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Container(
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.wc_outlined, color: themeColor, size: 20),
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
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'Laki-laki',
                  child: Row(
                    children: [
                      Icon(Icons.male, color: Colors.blue[600], size: 16),
                      SizedBox(width: 8),
                      Text('Laki-laki', style: TextStyle(fontFamily: "Mulish")),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Perempuan',
                  child: Row(
                    children: [
                      Icon(Icons.female, color: Colors.pink[400], size: 16),
                      SizedBox(width: 8),
                      Text('Perempuan', style: TextStyle(fontFamily: "Mulish")),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                _jeniskelaminform3.text = value!;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulir4() {
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
                    Text(
                      "Kronologi Kejadian",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
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

  Widget _buildFormulir5() {
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
                        Icons.assignment_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Identifikasi Kasus",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Date Picker Field
              _buildDatePickerField(themeColor: Colors.teal[600]!),

              // Tempat Kejadian Field
              _buildEnhancedTextField(
                label: 'Tempat Kejadian',
                controller: _tempatkejadianform3,
                keyboardType: TextInputType.streetAddress,
                icon: Icons.location_on_outlined,
                themeColor: Colors.teal[600]!,
                maxLines: 2,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
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
                  String formattedDate =
                      "${pickedDate.year}-"
                      "${pickedDate.month.toString().padLeft(2, '0')}-"
                      "${pickedDate.day.toString().padLeft(2, '0')}";
                  setState(() {
                    _tanggalController.text = formattedDate;
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, color: themeColor, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Tanggal dipilih: ${_formatDateToReadable(_tanggalController.text)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: themeColor,
                      fontWeight: FontWeight.w500,
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

  Widget _buildFormulirAnak(String index, {required Color themeColor}) {
    final controller = listAnakControllers[int.parse(index)];

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Identitas Anak ${int.parse(index) + 1}",
            style: TextStyle(
              fontFamily: "Mulish",
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),

          // Nama Anak
          _buildEnhancedTextField(
            label: 'Nama Anak',
            controller: controller.namaController,
            icon: Icons.person_outline,
            themeColor: themeColor,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              LengthLimitingTextInputFormatter(50),
            ],
          ),

          // Tanggal Lahir
          _buildEnhancedAnakDateField(
            label: 'Tanggal Lahir',
            controller: controller.tanggalLahirController,
            icon: Icons.calendar_today,
            themeColor: themeColor,
          ),

          // Jenis Kelamin
          _buildEnhancedDropdown(
            label: 'Jenis Kelamin',
            value:
                controller.jenis_kelaminController.text.isNotEmpty
                    ? controller.jenis_kelaminController.text
                    : null,
            items: ['Laki-laki', 'Perempuan'],
            icon: Icons.wc,
            themeColor: themeColor,
            onChanged: (String? newValue) {
              setState(() {
                controller.jenis_kelaminController.text = newValue!;
              });
            },
          ),

          // Umur
          _buildEnhancedTextField(
            label: 'Umur',
            controller: controller.umurController,
            keyboardType: TextInputType.number,
            icon: Icons.cake,
            themeColor: themeColor,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
          ),

          // Pendidikan
          _buildEnhancedDropdown(
            label: 'Pendidikan',
            value:
                controller.pendidikanController.text.isNotEmpty
                    ? controller.pendidikanController.text
                    : null,
            items: [
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
            icon: Icons.school,
            themeColor: themeColor,
            onChanged: (String? newValue) {
              setState(() {
                controller.pendidikanController.text = newValue!;
              });
            },
          ),

          // Agama
          _buildEnhancedDropdown(
            label: 'Agama',
            value:
                controller.agamaController.text.isNotEmpty
                    ? controller.agamaController.text
                    : null,
            items: ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha'],
            icon: Icons.church,
            themeColor: themeColor,
            onChanged: (String? newValue) {
              setState(() {
                controller.agamaController.text = newValue!;
              });
            },
          ),

          // Status
          _buildEnhancedDropdown(
            label: 'Status',
            value:
                controller.statusController.text.isNotEmpty
                    ? controller.statusController.text
                    : null,
            items: ['Anak Kandung', 'Anak Angkat'],
            icon: Icons.family_restroom,
            themeColor: themeColor,
            onChanged: (String? newValue) {
              setState(() {
                controller.statusController.text = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAnakDateField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
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
              readOnly: true,
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 16,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Container(
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: themeColor, size: 20),
                ),
                suffixIcon: Icon(Icons.arrow_drop_down, color: themeColor),
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
                  vertical: 16,
                  horizontal: 8,
                ),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
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
                  String formattedDate =
                      "${pickedDate.year}-"
                      "${pickedDate.month.toString().padLeft(2, '0')}-"
                      "${pickedDate.day.toString().padLeft(2, '0')}";
                  setState(() {
                    controller.text = formattedDate;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
