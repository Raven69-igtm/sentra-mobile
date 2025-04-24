import 'package:flutter/material.dart';
import 'package:SENTRA/utils/color.dart';
import 'package:SENTRA/fitur/authentikasi/screen/views/loginscreen.dart';
import 'package:SENTRA/utils/customroundedbutton.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Warna.backgroundIjo, Warna.backgroundBiru],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            //logo
            Image.asset('assets/logo/Image.png', width: 139, height: 137),

            SizedBox(height: 8),

            //nama Aplikasi
            Text(
              "SENTRA",
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),

            //deskripsi
            Text(
              "(Sistem Entitas Pelaporan dan Tanggap Respons Aksi)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Mulish',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),

            //text DPPPA
            Text(
              "By. DPPPA Nganjuk",
              style: TextStyle(fontSize: 14,fontFamily: "Mulish", color: Colors.white),
            ),
            Spacer(),
            //tombol "Quick Access Laporan"
            CustomRoundedButton(
              text: "Quick Access Laporan",
              icon: Icons.flash_on,
              backgroundColor: Color(0xFFFDF6E3),
              textColor: Color(0xFF8B6220),
              onPressed: () {
                print("Quick Access Laporan Clicked");
              },
            ),
            SizedBox(height: 8),
            CustomRoundedButton(
              text: "Get Started",
              backgroundColor: Warna.btngetstart,
              textColor: Warna.backgroundIjo,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
