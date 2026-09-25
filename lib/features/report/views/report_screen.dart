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


class _LaporanPageState extends State<LaporanPage> {
  int _currentStep = 1;
  final LaporanController laporanController = LaporanController();

  // Form 1 - Data Diri Pelapor
  final TextEditingController _nikform1 = TextEditingController();
  final TextEditingController _namaform1 = TextEditingController();
  final TextEditingController _telpform1 = TextEditingController();
  final TextEditingController _alamatform1 = TextEditingController();
  final TextEditingController _hubunganform1 = TextEditingController();

  // Form 2 - Kronologi Kejadian
  final TextEditingController _kronologiform4 = TextEditingController();

  // Form 3 - Tanggal & Lokasi Kejadian
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _tempatkejadianform3 = TextEditingController();

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
      setState(() {
        if (_currentStep < 3) _currentStep++;
      });
    }
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 1) _currentStep--;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user != null) {
        if (user.nama != null && user.nama!.isNotEmpty && _namaform1.text.isEmpty) {
          _namaform1.text = user.nama!;
        }
        if (user.notelp != null && user.notelp!.isNotEmpty && _telpform1.text.isEmpty) {
          _telpform1.text = user.notelp!;
        }
        if (user.alamat != null && user.alamat!.isNotEmpty && _alamatform1.text.isEmpty) {
          _alamatform1.text = user.alamat!;
        }
      }
    });

    final namaControllers = [
      _namaform1,
      _alamatform1,
      _tempatkejadianform3,
    ];

    for (var controller in namaControllers) {
      _addAutoCapitalizeListener(controller);
    }
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
      CustomSnackbar.show("Mohon isi lokasi / tempat kejadian", warna: Colors.red);
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

  void _showPreviewDialog() async {
    if (!_validateForm3()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idAkun = userProvider.idAkun;

    Map<String, dynamic> laporanData = {
      'id_akun': idAkun,
      'kategori': 'unset',
      'status': 'diterima',
      'detail_pelapor': {
        'nik': _nikform1.text.trim(),
        'nama': _namaform1.text.trim(),
        'alamat': _alamatform1.text.trim(),
        'hubungan_dengan_korban': 'Pelapor / Korban',
        'no_telp': _telpform1.text.trim(),
      },
      'detail_terlapor': {
        'nik': '-',
        'nama': 'Dalam Penyelidikan',
        'umur': '0',
        'alamat': '-',
        'jenis_kelamin': 'Laki-laki',
        'hubungan_dengan_korban': '-',
        'informasi_tambahan': '-',
      },
      'detail_penerima_manfaat': {
        'nik': _nikform1.text.trim(),
        'nama': _namaform1.text.trim(),
        'Tempat_lahir': '-',
        'tanggal_lahir': '2000-01-01',
        'umur': '0',
        'jenis_kelamin': 'Laki-laki',
        'pekerjaan': '-',
        'agama': 'Islam',
        'alamat': _alamatform1.text.trim(),
        'pendidikan': 'Tidak Sekolah',
        'hubungan_dengan_terlapor': '-',
        'notelp': _telpform1.text.trim(),
        'informasi_tambahan': '-',
      },
      'detail_kasus': {
        'tanggal': _tanggalController.text.trim(),
        'tempat_kejadian': _tempatkejadianform3.text.trim(),
        'kronologi': _kronologiform4.text.trim(),
      },
      'informasi_anak': [],
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
                        SizedBox(height: 16),

                        _buildEnhancedPreviewSection(
                          "Kronologi Kejadian",
                          {
                            'kronologi': _kronologiform4.text.trim(),
                          },
                          Icons.history_edu_outlined,
                          Colors.deepOrange,
                        ),
                        SizedBox(height: 16),

                        _buildEnhancedPreviewSection(
                          "Waktu & Lokasi Kejadian",
                          {
                            'tanggal_kejadian': _tanggalController.text.trim(),
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
    _nikform1.clear();
    _namaform1.clear();
    _alamatform1.clear();
    _telpform1.clear();
    _hubunganform1.clear();
    _kronologiform4.clear();
    _tanggalController.clear();
    _tempatkejadianform3.clear();
    setState(() {
      _currentStep = 1;
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
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
