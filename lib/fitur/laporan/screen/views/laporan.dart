import 'package:SENTRA/utils/color.dart';
import 'package:SENTRA/fitur/laporan/screen/widget/stepper.dart';
import 'package:flutter/material.dart';

class LaporanPage extends StatefulWidget {
  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  int _currentStep = 1;
  String? _selectedOptionAnak;
   String? _selectedDropdownValue;

  void _handleRadioAnak(String? value) {
    setState(() {
      _selectedOptionAnak = value;
    });
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < 5) _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
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
            MiniStepper(currentStep: _currentStep-1),
            SizedBox(height: 20),
            Expanded(child: _buildCurrentForm()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 1)
                  ElevatedButton(
                    onPressed: _prevStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Warna.backgroundBiru,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    child: Text(
                      "Previous",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        color: Colors.white,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _currentStep < 5 ? _nextStep : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Warna.backgroundIjo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  child: Text(
                    _currentStep < 5 ? "Next" : "Submit",
                    style: TextStyle(fontFamily: "Mulish", color: Colors.white),
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

  void _submitForm() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Form Submitted")));
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
            cursorColor: Colors.black,
            decoration: InputDecoration(
              labelText: 'NIK',
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
            decoration: InputDecoration(
              labelText: 'Nama',
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
            decoration: InputDecoration(
              labelText: 'Umur',
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
            decoration: InputDecoration(
              labelText: 'Alamat',
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
            decoration: InputDecoration(
              labelText: 'Hubungan dengan korban',
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
            decoration: InputDecoration(
              labelText: 'No. Telp',
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
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFormulir2() {
    // String? pilihan;
    // int jumlahAnak = 1;
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
          TextField(
            decoration: InputDecoration(
              labelText: 'NIK',
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
            decoration: InputDecoration(
              labelText: 'Nama',
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
            decoration: InputDecoration(
              labelText: 'Tempat, Tgl Lahir',
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
            decoration: InputDecoration(
              labelText: 'Umur',
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
            decoration: InputDecoration(
              labelText: 'Pekerjaan',
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
            decoration: InputDecoration(
              labelText: 'Agama',
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
            decoration: InputDecoration(
              labelText: 'Pendidikan',
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
            decoration: InputDecoration(
              labelText: 'Hubungan dengan Terlapor',
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
            decoration: InputDecoration(
              labelText: 'No.telp',
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
            decoration: InputDecoration(
              labelText: 'Informasi Tambahan',
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
          Column(
            children: <Widget>[
              Text('Punya Anak ?', textAlign: TextAlign.start),
              ListTile(
                title: Text("Ya"),
                leading: Radio<String>(
                  value: "Ya",
                  groupValue: _selectedOptionAnak,
                  onChanged: _handleRadioAnak,
                ),
              ),
              ListTile(
                title: Text("Tidak"),
                leading: Radio<String>(
                  value: "Tidak",
                  groupValue: _selectedOptionAnak,
                  onChanged: _handleRadioAnak,
                ),
              ),
              if (_selectedOptionAnak == 'Ya') 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: DropdownButton<String>(
                    hint: Text("Jumlah Anak"),
                    value: _selectedDropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDropdownValue = newValue;
                      });
                    },
                    items:
                        ["1", "2", "3","4","5","6","7","8","9","10"].map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                  ),
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
              "Identitas Terlapor",
              style: TextStyle(
                fontFamily: "Mulish",
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: 'Jumlah Anak',
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
            decoration: InputDecoration(
              labelText: 'Nama Pertama',
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
            decoration: InputDecoration(
              labelText: 'Tanggal Lahir',
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
        ],
      ),
    );
  }

  Widget _buildFormulir4() {
    return Column(
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
          decoration: InputDecoration(
            labelText: 'Kronologi Kejadian',
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
          maxLines: 5,
        ),
        SizedBox(height: 15),
      ],
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
            decoration: InputDecoration(
              labelText: 'Tanggal dan Tempat Kejadian',
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
            decoration: InputDecoration(
              labelText: 'Jenis Kasus',
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
          SizedBox(height: 10),
          ElevatedButton(onPressed: () {}, child: Text('Upload Bukti')),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
