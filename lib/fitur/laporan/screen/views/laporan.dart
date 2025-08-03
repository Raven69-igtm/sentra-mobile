import 'package:sentra/fitur/authentikasi/data/models/usermodel.dart';
import 'package:sentra/fitur/authentikasi/data/provider/userprovider.dart';
import 'package:sentra/fitur/laporan/data/controllers/laporancontroller.dart';
import 'package:sentra/utils/color.dart';
import 'package:sentra/fitur/laporan/screen/widget/stepper.dart';
import 'package:sentra/utils/customsnackbar.dart';
import 'package:sentra/utils/customspinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LaporanPage extends StatefulWidget {
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
  int _jumlah = 1;
  String? _selectedOptionAnak;
  String? _selectedOptionPelaku;
  String? _selectedDropdownValue;
  final LaporanController laporanController = LaporanController();
  List<AnakFormController> listAnakControllers = [];
  List<Map<String, String>> informasiAnak = [];

  // Form 1
  TextEditingController _nikform1 = TextEditingController();
  TextEditingController _namaform1 = TextEditingController();
  TextEditingController _umurform1 = TextEditingController();
  TextEditingController _alamatform1 = TextEditingController();
  TextEditingController _hubunganform1 = TextEditingController();
  TextEditingController _telpform1 = TextEditingController();
  // Form 2
  TextEditingController _nikform2 = TextEditingController();
  TextEditingController _namaform2 = TextEditingController();
  TextEditingController _templform2 = TextEditingController();
  TextEditingController _tanglform2 = TextEditingController();
  TextEditingController _umurform2 = TextEditingController();
  TextEditingController _jeniskelaminform2 = TextEditingController();
  TextEditingController _alamatform2 = TextEditingController();
  TextEditingController _pekerjaanform2 = TextEditingController();
  TextEditingController _agamaform2 = TextEditingController();
  TextEditingController _pendidikanform2 = TextEditingController();
  TextEditingController _hubunganform2 = TextEditingController();
  TextEditingController _telpform2 = TextEditingController();
  TextEditingController _infromasitambahanform2 = TextEditingController();
  // Form 3
  TextEditingController _nikform3 = TextEditingController();
  TextEditingController _namaform3 = TextEditingController();
  TextEditingController _umurform3 = TextEditingController();
  TextEditingController _alamatform3 = TextEditingController();
  TextEditingController _jeniskelaminform3 = TextEditingController();
  TextEditingController _hubunganform3 = TextEditingController();
  TextEditingController _informasitambahanform3 = TextEditingController();
  // Form 4
  TextEditingController _kronologiform4 = TextEditingController();
  // Form 5
  TextEditingController _tanggalController = TextEditingController();
  TextEditingController _tempatkejadianform3 = TextEditingController();

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
    setState(() {
      if (_currentStep < 5) _currentStep++;
      if (_selectedOptionPelaku == 'Tidak' &&
          _currentStep > 2 &&
          _currentStep < 5) {
        _currentStep++;
      }
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromRGBO(82, 174, 119, 1),
                Warna.backgroundBiru,
              ],
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
                fontFamily: 'Mulish',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Spacer(),
            const Text(
              "Laporan",
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "FORMULIR PENGADUAN",
              style: TextStyle(
                fontFamily: "Mulish",
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            MiniStepper(currentStep: _currentStep - 1),
            SizedBox(height: 20),
            Expanded(child: _buildCurrentForm()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 1)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Warna.backgroundBiru,
                          Warna().darken(Warna.backgroundBiru, 0.20),
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
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _prevStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        minimumSize: Size(120, 50),
                      ),
                      child: Text(
                        "Previous",
                        style: TextStyle(
                          fontFamily: "Mulish",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Warna.backgroundIjo,
                        Warna().darken(Warna.backgroundIjo, 0.20),
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
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed:
                        _currentStep < 5 ? _nextStep : _showPreviewDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      minimumSize: Size(120, 50),
                    ),
                    child: Text(
                      _currentStep < 5 ? "Next" : "Submit",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
        return AlertDialog(
          title: Text(
            "Pratinjau Laporan",
            style: TextStyle(
              fontFamily: "Mulish",
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreviewSection(
                  "Detail Pelapor",
                  laporanData['detail_pelapor'],
                ),
                SizedBox(height: 10),
                _buildPreviewSection(
                  "Detail Terlapor",
                  laporanData['detail_terlapor'],
                ),
                SizedBox(height: 10),
                _buildPreviewSection(
                  "Detail Penerima Manfaat",
                  laporanData['detail_penerima_manfaat'],
                ),
                SizedBox(height: 10),
                _buildPreviewSection(
                  "Detail Kasus",
                  laporanData['detail_kasus'],
                ),
                SizedBox(height: 10),
                if (laporanData['informasi_anak'].isNotEmpty) ...[
                  Text(
                    "Informasi Anak",
                    style: TextStyle(
                      fontFamily: "Mulish",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  ...List.generate(
                    laporanData['informasi_anak'].length,
                    (index) => _buildPreviewSection(
                      "Anak ${index + 1}",
                      laporanData['informasi_anak'][index],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(fontFamily: "Mulish", color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await laporanController.createReport(laporanData);
                  CustomSnackbar.show("Laporan telah dikirim");
                  _resetForm();
                } catch (e) {
                    CustomSnackbar.show("Gagal mengirim laporan: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Warna().darken(Warna.backgroundIjo,0.1)
              ),
              child: Text(
                "Send",
                style: TextStyle(fontFamily: "Mulish", color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
        }).toList(),
        SizedBox(height: 10),
      ],
    );
  }

  void _submitForm() {
    _showPreviewDialog();
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFormulir1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Identitas Pelapor",
              style: TextStyle(
                fontFamily: "Mulish",
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            keyboardType: TextInputType.number,
            cursorColor: Colors.black,
            controller: _nikform1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(20),
            ],
            decoration: _inputDecoration('NIK'),
          ),
          SizedBox(height: 15),
          TextField(
            keyboardType: TextInputType.name,
            controller: _namaform1,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              LengthLimitingTextInputFormatter(50),
            ],
            decoration: _inputDecoration('Nama'),
          ),
          SizedBox(height: 15),
          TextField(
            keyboardType: TextInputType.streetAddress,
            controller: _alamatform1,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
            decoration: _inputDecoration('Alamat'),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _hubunganform1,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              LengthLimitingTextInputFormatter(30),
            ],
            decoration: _inputDecoration('Hubungan dengan korban'),
          ),
          SizedBox(height: 15),
          TextField(
            keyboardType: TextInputType.phone,
            controller: _telpform1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            decoration: _inputDecoration('No. Telp'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      labelStyle: TextStyle(
        fontFamily: 'Mulish',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
    );
  }

  void initFormulirAnak(int jumlahAnak) {
    listAnakControllers = List.generate(
      jumlahAnak,
      (_) => AnakFormController(),
    );
  }

  Widget _buildFormulir2() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Identitas Penerima Manfaat",
              style: TextStyle(
                fontFamily: "Mulish",
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(controller: _nikform2, decoration: _inputDecoration('NIK')),
          SizedBox(height: 15),
          TextField(
            controller: _namaform2,
            decoration: _inputDecoration('Nama'),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _templform2,
            decoration: _inputDecoration('Tempat Lahir'),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _tanglform2,
            readOnly: true,
            decoration: _inputDecoration('Tanggal Lahir'),
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
                        primary: Warna.backgroundIjo,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Warna.backgroundIjo,
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
          SizedBox(height: 15),
          TextField(
            controller: _umurform2,
            decoration: _inputDecoration('Umur'),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _alamatform2,
            decoration: _inputDecoration('Alamat'),
          ),
          SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value:
                _jeniskelaminform2.text.isNotEmpty
                    ? _jeniskelaminform2.text
                    : null,
            items:
                ['Laki-laki', 'Perempuan'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _jeniskelaminform2.text = newValue!;
              });
            },
            decoration: InputDecoration(
              labelText: 'Jenis Kelamin',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelStyle: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _pekerjaanform2,
            decoration: _inputDecoration('Pekerjaan'),
          ),
          SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: _agamaform2.text.isNotEmpty ? _agamaform2.text : null,
            items:
                ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _agamaform2.text = newValue!;
              });
            },
            decoration: _inputDecoration('Agama'),
          ),
          SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value:
                _pendidikanform2.text.isNotEmpty ? _pendidikanform2.text : null,
            items:
                [
                  'Tidak Sekolah',
                  'SD',
                  'SMP',
                  'SMA',
                  'Diploma',
                  'S1',
                  'S2',
                  'S3',
                  'Lainnya',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _pendidikanform2.text = newValue!;
              });
            },
            decoration: _inputDecoration('Pendidikan'),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _hubunganform2,
            decoration: _inputDecoration("Hubungan dengan Terlapor"),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _telpform2,
            decoration: _inputDecoration("No.Telp"),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _infromasitambahanform2,
            decoration: _inputDecoration('Informasi Tambahan'),
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Punya Anak ?', textAlign: TextAlign.start),
              Row(
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        activeColor: Warna.backgroundIjo,
                        value: "Ya",
                        groupValue: _selectedOptionAnak,
                        onChanged: _handleRadioAnak,
                      ),
                      Text('Ya'),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Radio<String>(
                        activeColor: Warna.backgroundIjo,
                        value: "Tidak",
                        groupValue: _selectedOptionAnak,
                        onChanged: _handleRadioAnak,
                      ),
                      Text('Tidak'),
                    ],
                  ),
                ],
              ),
              if (_selectedOptionAnak == 'Ya') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: DropdownButton<String>(
                    hint: Text("Jumlah Anak"),
                    value: _selectedDropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDropdownValue = newValue;
                        initFormulirAnak(int.parse(_selectedDropdownValue!));
                      });
                    },
                    items:
                        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"].map(
                          (String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          },
                        ).toList(),
                  ),
                ),
                if (_selectedDropdownValue != null)
                  ...List.generate(
                    int.parse(_selectedDropdownValue!),
                    (index) => _buildFormulirAnak((index).toString()),
                  ),
              ],
            ],
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Ingin menyertakan Identitas Terlapor (Pelaku)?',
                textAlign: TextAlign.start,
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        activeColor: Warna.backgroundIjo,
                        value: "Ya",
                        groupValue: _selectedOptionPelaku,
                        onChanged: _handleRadioPelaku,
                      ),
                      Text('Ya'),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Radio<String>(
                        activeColor: Warna.backgroundIjo,
                        value: "Tidak",
                        groupValue: _selectedOptionPelaku,
                        onChanged: _handleRadioPelaku,
                      ),
                      Text('Tidak'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormulir3() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Identitas Terlapor (Pelaku)",
              style: TextStyle(
                fontFamily: "Mulish",
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(controller: _nikform3, decoration: _inputDecoration('NIK')),
          SizedBox(height: 15),
          TextField(
            controller: _namaform3,
            decoration: _inputDecoration('Nama'),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _umurform3,
            decoration: _inputDecoration('Umur'),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _alamatform3,
            decoration: _inputDecoration('Alamat'),
          ),
          SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value:
                _jeniskelaminform3.text.isNotEmpty
                    ? _jeniskelaminform3.text
                    : null,
            decoration: InputDecoration(
              labelText: 'Jenis Kelamin',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelStyle: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            items:
                ['Laki-laki', 'Perempuan']
                    .map(
                      (jenisKelamin) => DropdownMenuItem(
                        value: jenisKelamin,
                        child: Text(jenisKelamin),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              _jeniskelaminform3.text = value!;
            },
          ),
          SizedBox(height: 15),
          TextField(
            controller: _hubunganform3,
            decoration: _inputDecoration("Hubungan dengan Korban"),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _informasitambahanform3,
            decoration: _inputDecoration('Informasi Tambahan'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulir4() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Kronologi Kejadian",
              style: TextStyle(
                fontFamily: "Mulish",
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _kronologiform4,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelStyle: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              hintText: 'Tuliskan Kronologi Kejadian secara lengkap',
              hintStyle: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            maxLines: 19,
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildFormulir5() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Identifikasi Kasus",
              style: TextStyle(
                fontFamily: "Mulish",
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _tanggalController,
            readOnly: true,
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
                        primary: Warna.backgroundIjo,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Warna.backgroundIjo,
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
              labelText: 'Tanggal Kejadian',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelStyle: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _tempatkejadianform3,
            decoration: _inputDecoration('Tempat Kejadian'),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildFormulirAnak(String index) {
    final controller = listAnakControllers[int.parse(index)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Identitas Anak ${int.parse(index) + 1}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller.namaController,
          decoration: _inputDecoration('Nama Anak'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller.tanggalLahirController,
          readOnly: true,
          decoration: _inputDecoration('Tanggal Lahir'),
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
                      primary: Warna.backgroundIjo,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Warna.backgroundIjo,
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

              controller.tanggalLahirController.text = formattedDate;
            }
          },
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value:
              controller.jenis_kelaminController.text.isEmpty
                  ? null
                  : controller.jenis_kelaminController.text,
          decoration: InputDecoration(
            labelText: 'Jenis Kelamin',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            labelStyle: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
          ),
          items:
              ['Laki-laki', 'Perempuan']
                  .map(
                    (jenisKelamin) => DropdownMenuItem(
                      value: jenisKelamin,
                      child: Text(jenisKelamin),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            controller.jenis_kelaminController.text = value!;
          },
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller.umurController,
          decoration: _inputDecoration('Umur'),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value:
              controller.pendidikanController.text.isEmpty
                  ? null
                  : controller.pendidikanController.text,
          decoration: _inputDecoration('Pendidikan'),
          items:
              [
                'Tidak Sekolah',
                'SD',
                'SMP',
                'SMA',
                'Diploma',
                'S1',
                'S2',
                'S3',
                'Lainnya',
              ].map((pendidikan) {
                return DropdownMenuItem<String>(
                  value: pendidikan,
                  child: Text(pendidikan),
                );
              }).toList(),
          onChanged: (value) {
            controller.pendidikanController.text = value!;
          },
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value:
              controller.agamaController.text.isEmpty
                  ? null
                  : controller.agamaController.text,
          decoration: InputDecoration(
            labelText: 'Agama',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            labelStyle: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
          ),
          items:
              ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha']
                  .map(
                    (agama) =>
                        DropdownMenuItem(value: agama, child: Text(agama)),
                  )
                  .toList(),
          onChanged: (value) {
            controller.agamaController.text = value!;
          },
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller.statusController,
          decoration: _inputDecoration('Status (Anak Kandung/ Anak Angkat)'),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
