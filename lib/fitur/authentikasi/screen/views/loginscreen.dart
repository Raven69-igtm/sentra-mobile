// import 'package:SENTRA/views/dashboard.dart';
import 'package:SENTRA/fitur/authentikasi/data/controllers/logincontroller.dart';
import 'package:SENTRA/fitur/authentikasi/data/controllers/registercontroller.dart';
import 'package:SENTRA/fitur/authentikasi/data/repositories/loginrepository.dart';
import 'package:SENTRA/fitur/authentikasi/data/repositories/registerrepository.dart';
import 'package:SENTRA/fitur/dashboard/screen/views/homescreen.dart';
import 'package:SENTRA/fitur/authentikasi/screen/views/lupapassword.dart';
// import 'package:SENTRA/views/welcomescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:SENTRA/utils/color.dart';
import 'package:SENTRA/utils/customroundedbutton.dart';
import 'package:SENTRA/utils/customtextfield.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  RegisterController repository = RegisterController();
  int selectedIndex = 0;
  bool isChecked = false;
  String? selectedValue;
  TextEditingController nomorController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController regisnomor = TextEditingController();
  TextEditingController regispassword = TextEditingController();
  TextEditingController regispasswordkonfirm = TextEditingController();
  TextEditingController regisnama = TextEditingController();
  TextEditingController regisquestion = TextEditingController();
  TextEditingController regisanswer = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.07,
            vertical: screenHeight * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: Image.asset(
                  "assets/logo/icon_ijo.png",
                  width: screenWidth * 0.3,
                  height: screenHeight * 0.12,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTab(0, "Sign in", textScale),
                  SizedBox(width: screenWidth * 0.25),
                  _buildTab(1, "Sign up", textScale),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),

              if (selectedIndex == 0)
                _buildSignInForm(screenWidth, screenHeight, textScale),
              if (selectedIndex == 1)
                _buildSignUpForm(screenWidth, screenHeight, textScale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String text, double textScale) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: 20 * textScale,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.green : Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: isSelected ? 60 : 0,
            height: 3,
            color: isSelected ? Colors.green : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm(
    double screenWidth,
    double screenHeight,
    double textScale,
  ) {
    return Column(
      children: [
        CustomTextField(
          label: "Nomor Telepon",
          hintText: "Masukan nomor anda",
          controller: nomorController,
          icon: Icons.phone,
        ),
        SizedBox(height: screenHeight * 0.04),
        CustomTextField(
          label: "Password",
          hintText: "*************",
          obscureText: true,
          controller: passwordController,
          icon: Icons.visibility,
        ),
        SizedBox(height: screenHeight * 0.01),
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                },
                checkColor: Colors.white,
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Warna.backgroundIjo;
                  }
                  return const Color.fromARGB(255, 254, 253, 253);
                }),
              ),
            ),
            Text("Remember me", style: TextStyle(fontFamily: "Mulish")),
          ],
        ),

        SizedBox(height: screenHeight * 0.02),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: ElevatedButton(
                // onPressed: () async {
                //   print("Nomor: ${nomorController.text}");
                //   print("Password: ${passwordController.text}");
                //   // Mendapatkan instance LoginController melalui Provider
                //   LoginController loginController =
                //       Provider.of<LoginController>(context, listen: false);

                //   // Panggil method login
                //   await loginController.login(
                //     nomorController.text,
                //     passwordController.text,
                //   );

                //   // Navigasi jika login sukses
                //   if (loginController.user != null) {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => HomeScreen(initialIndex: 2),
                //       ),
                //     );
                //   } else if (loginController.errorMessage != null) {
                //     // Tampilkan error message
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(
                //         content: Text(loginController.errorMessage!),
                //         backgroundColor: Colors.red,
                //       ),
                //     );
                //   }
                // },
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(initialIndex: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Warna.backgroundIjo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(0),
                    ),
                  ),
                ),
                child: Text(
                  "Sign in",
                  style: TextStyle(fontFamily: "Mulish", color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 3),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () async {
                  final bool canAuthenticateWithBiometrics =
                      await auth.canCheckBiometrics;
                  final bool canAuthenticate =
                      canAuthenticateWithBiometrics ||
                      await auth.isDeviceSupported();
                  print({"Cek Biometrik :": canAuthenticateWithBiometrics});
                  final List<BiometricType> availableBiometrics =
                      await auth.getAvailableBiometrics();
                  print({"Cek available :": availableBiometrics});
                  if (canAuthenticate) {
                    try {
                      final bool didAuthenticate = await auth.authenticate(
                        options: AuthenticationOptions(biometricOnly: true),
                        localizedReason: 'Please authenticate to Sign in',
                      );

                      print('cek apakah fingerprint benar : $didAuthenticate');
                      if (didAuthenticate == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(initialIndex: 2),
                          ),
                        );
                      }
                    } on PlatformException {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Perangkat tidak support!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: "Mulish"),
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Warna.backgroundIjo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
                child: Icon(Icons.fingerprint, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),

        SizedBox(height: screenHeight * 0.01),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
            );
          },
          child: Text(
            "Lupa password?",
            style: TextStyle(
              fontFamily: "Mulish",
              color: Colors.green,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          "OR",
          style: TextStyle(
            fontFamily: "Mulish",
            fontWeight: FontWeight.bold,
            fontSize: 14 * textScale,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomRoundedButton(
          icon: Icons.g_mobiledata,
          text: "Sign in dengan Google",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          iconSize: 20,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSignUpForm(
    double screenWidth,
    double screenHeight,
    double textScale,
  ) {
    return Column(
      children: [
        CustomTextField(
          label: "Nama Lengkap",
          controller: regisnama,
          hintText: "Masukan nama lengkap anda",
          icon: Icons.person,
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomTextField(
          label: "Password",
          controller: regispassword,
          hintText: "*************",
          obscureText: true,
          icon: Icons.visibility,
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomTextField(
          label: "Confirm Password",
          controller: regispasswordkonfirm,
          hintText: "*************",
          obscureText: true,
          icon: Icons.visibility,
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomTextField(
          label: "Nomor Telepon",
          hintText: "Masukan nomor anda",
          controller: regisnomor,
          icon: Icons.phone,
        ),
        SizedBox(height: screenHeight * 0.03),
        DropdownButtonFormField<String>(
          focusColor: Colors.black87,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            fillColor: Colors.white,
            labelText: "Pilih Pertanyaan",
            labelStyle: TextStyle(
              fontSize: 20,
              fontFamily: "Mulish",
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: "Pilih Pertanyaan Darurat",
            hintStyle: TextStyle(
              fontFamily: 'Mulish',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          value: selectedValue,
          items:
              [
                'Apa Warna Favorit anda ?',
                'Apa Hewan Favorit anda ?',
                'Dimana anda Lahir ?',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: "Mulish",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue!;
            });
          },
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomTextField(
          label: "Masukan Jawaban Pertanyaan Keamanan",
          hintText: "Masukan Jawaban anda",
          controller: regisanswer,
          icon: Icons.admin_panel_settings_rounded,
        ),
        SizedBox(height: screenHeight * 0.08),
        CustomRoundedButton(
          text: "Sign up",
          backgroundColor: Warna.backgroundIjo,
          textColor: Colors.white,
          onPressed: () async {
            // Validasi konfirmasi password
            if (regispassword.text != regispasswordkonfirm.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Password tidak cocok"),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Kirim data ke API untuk pendaftaran
            final registerController = RegisterController();

            try {
              // Panggil metode register dengan instance registerController
              var response = await registerController.register(
                regisnomor.text,
                regisnama.text,
                regispassword.text,
                selectedValue!,
                regisanswer.text,
              );

              // Cek apakah register berhasil dan navigasi ke halaman login
              if (response != null && response.success) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } else {
                // Tampilkan error jika registrasi gagal
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Registrasi gagal!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              // Tangani error, jika terjadi masalah selama proses registrasi
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Terjadi kesalahan: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        SizedBox(height: screenHeight * 0.08),
      ],
    );
  }
}
