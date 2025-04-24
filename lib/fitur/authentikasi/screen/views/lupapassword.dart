import 'package:SENTRA/utils/color.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Masukkan Nomor Telepon anda",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Masukkan Nomor Anda",
                hintStyle: TextStyle(fontFamily: 'Mulish'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _showOldPhoneDialog(context);
              },
              child: Text(
                "Pemulihan dengan pertanyaan darurat?",
                style: TextStyle(fontFamily: "Mulish", color: Colors.blue),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtpVerificationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Warna.backgroundIjo,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              child: Text("Next", style: TextStyle(fontFamily:"Mulish",fontWeight: FontWeight.bold,color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  void _showOldPhoneDialog(BuildContext context) {
    TextEditingController oldPhoneController = TextEditingController();
    TextEditingController securityAnswerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text("Masukkan Nomor Lama",style: TextStyle(fontFamily: "Mulish"),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Masukkan nomor lama (terdaftar)",
                  hintStyle: TextStyle(fontFamily: 'Mulish'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: securityAnswerController,
                decoration: InputDecoration(
                  hintText: "Apa warna favorit Anda?",
                  hintStyle: TextStyle(fontFamily: 'Mulish'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal",selectionColor: Warna.btngetstart,style:TextStyle(fontFamily: "Mulish")),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showNewPhoneDialog(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Warna.backgroundIjo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              child: Text("Submit", style: TextStyle(fontFamily: "Mulish", color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showNewPhoneDialog(BuildContext context) {
    TextEditingController newPhoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text("Masukkan Nomor Baru",style: TextStyle(fontFamily: "Mulish"),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Masukkan nomor telepon baru Anda",
                  hintStyle: TextStyle(fontFamily: 'Mulish'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal",style: TextStyle(fontFamily: "Mulish"),),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Warna.backgroundIjo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              child: Text("Submit", style: TextStyle(fontFamily: "Mulish", color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class OtpVerificationScreen extends StatelessWidget {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "6 digit-code",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Masukkan kode yang telah dikirim ke nomor anda",style: TextStyle(fontFamily: "Mulish"),),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 40,
                  child: TextField(
                    controller: otpControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(counterText: ""),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text("Code is expired in 4:57s",style: TextStyle(fontFamily: "Mulish"),),
            TextButton(onPressed: () {}, child: Text("Resend",style: TextStyle(fontFamily: "Mulish"),)),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Warna.backgroundIjo,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              child: Text("Submit", style: TextStyle(
                  fontFamily: "Mulish",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Masukkan password baru anda",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password baru",
                hintStyle: TextStyle(fontFamily: 'Mulish'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: Icon(Icons.visibility),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Konfirmasi password baru",
                hintStyle: TextStyle(fontFamily: 'Mulish'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: Icon(Icons.visibility),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Warna.backgroundIjo,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              child: Text("Submit", style: TextStyle(
                  fontFamily: "Mulish",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
