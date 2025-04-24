import 'package:SENTRA/fitur/authentikasi/data/controllers/logincontroller.dart';
import 'package:SENTRA/fitur/authentikasi/data/models/usermodel.dart';
import 'package:SENTRA/utils/color.dart';
import 'package:SENTRA/fitur/authentikasi/screen/views/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  UserModel? user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (user == null) {
      user = Provider.of<LoginController>(context, listen: false).user;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [_buildHeader(), _buildProfileForm()]),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Warna.backgroundIjo, Warna.backgroundBiru],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 18),
          Row(
            children: [
              Row(children: [
              Image.asset("assets/logo/Image.png", width: 35, height: 35),
              SizedBox(width: 10),
              Text(
                'SENTRA',
                style: TextStyle(
                  fontFamily: "Mulish",
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),],),
              Spacer(),
              Row(children: [
              Text(
                "Logout",
                style: TextStyle(
                  fontFamily: "Mulish",
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),],),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 70),
          Text(
            'Hi, ${user?.nama ?? "Pengguna"}',
            style: TextStyle(
              fontFamily: "Mulish",
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Welcome to SENTRA.\nDisini anda dapat mengupdate data Profile anda',
            style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: "Mulish"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTextField('Nama Lengkap',"${user?.nama ?? "Nama belum diisi"}", false),
          _buildTextField('Jenis Kelamin',"${user?.jeniskelamin ?? "Jenis Kelamin belum diisi"}", false),
          _buildTextField('Nomor Telepon',"${user?.notelp ?? "Nomor belum diisi"}", false),
          _buildTextField('Email', "${user?.email ?? "Email belum diisi"}", false),
          _buildTextField('Alamat',"${user?.alamat ?? "Alamat belum diisi"}", true),
          SizedBox(height: 20),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label,String hint,bool isMultiline) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          labelStyle: TextStyle(
            fontFamily: 'Mulish',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          hintText: hint,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        maxLines: isMultiline ? 3 : 1,
        readOnly: !isEditing,
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isEditing = !isEditing;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isEditing
                ? Warna.birunom
                : Warna.backgroundIjo,
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
        isEditing
            ? "Confirm"
            : "Edit Profile",
        style: TextStyle(fontFamily: "Mulish",color: Colors.white),
      ),
    );
  }
}
