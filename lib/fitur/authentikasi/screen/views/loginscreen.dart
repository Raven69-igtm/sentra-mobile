// import 'package:sentra/views/dashboard.dart';
import 'dart:math';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/fitur/authentikasi/data/controllers/logincontroller.dart';
import 'package:sentra/fitur/authentikasi/data/controllers/registercontroller.dart';
import 'package:sentra/fitur/authentikasi/data/localdirectory/akunprefs.dart';
import 'package:sentra/fitur/authentikasi/data/localdirectory/biometricprefs.dart';
import 'package:sentra/fitur/authentikasi/data/provider/userprovider.dart';
import 'package:sentra/fitur/dashboard/screen/views/homescreen.dart';
import 'package:sentra/fitur/authentikasi/screen/views/lupapassword.dart';
import 'package:sentra/fitur/notifikasi/data/controllers/notifcontroller.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sentra/fitur/notifikasi/data/repositories/notifrepositories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentra/utils/customsnackbar.dart';
// import 'package:sentra/views/welcomescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/utils/color.dart';
import 'package:sentra/utils/customroundedbutton.dart';
import 'package:sentra/utils/customtextfield.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
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
  bool isLoading = false;
  String? selectedValue;
  String? selectedGender;
  TextEditingController nomorController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController regisnomor = TextEditingController();
  TextEditingController regispassword = TextEditingController();
  TextEditingController regispasswordkonfirm = TextEditingController();
  TextEditingController regisnama = TextEditingController();
  TextEditingController regisquestion = TextEditingController();
  TextEditingController regisanswer = TextEditingController();
  TextEditingController regisalamat = TextEditingController();

  void verifFinger(String notelp) async {
    setState(() {
      isLoading = true;
    });

    LoginController loginController = Provider.of<LoginController>(
      context,
      listen: false,
    );

    await loginController.Biometric(notelp);

    setState(() {
      isLoading = false;
    });

    if (loginController.user != null) {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).setUser(loginController.user!);

      print("User berhasil login: ${loginController.user}");

      print("Showing SnackBar...");
      await Future.delayed(Duration(milliseconds: 500));

      if (mounted) {
        CustomSnackbar.show(
          "Login Berhasil, Selamat datang ${loginController.user?.nama}",
        );
        print("Navigating to HomeScreen...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(initialIndex: 2)),
        );
      }
    } else {
      if (mounted) {
        CustomSnackbar.show(
          "Login Biometric gagal",
          warna: Colors.red,
          tinggi: 100,
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
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
          keyboardType: TextInputType.number,
          icon: Icons.phone,
        ),
        SizedBox(height: screenHeight * 0.04),
        CustomTextField(
          label: "Password",
          hintText: "*************",
          obscureText: true,
          keyboardType: null,
          controller: passwordController,
          icon: Icons.visibility,
        ),
        SizedBox(height: screenHeight * 0.015),
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value ?? false;
                    print(isChecked);
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Warna.backgroundIjo, Warna.backgroundIjoDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            print("Nomor: ${nomorController.text}");
                            print("Password: ${passwordController.text}");

                            if (nomorController.text.isEmpty ||
                                passwordController.text.isEmpty) {
                              return;
                            }

                            setState(() {
                              isLoading = true;
                            });

                            LoginController loginController =
                                Provider.of<LoginController>(
                                  context,
                                  listen: false,
                                );
                            await loginController.login(
                              nomorController.text,
                              passwordController.text,
                            );

                            setState(() {
                              isLoading = false;
                            });

                            if (loginController.user != null) {
                              Provider.of<UserProvider>(
                                context,
                                listen: false,
                              ).setUser(loginController.user!);

                              String? fcmToken =
                                  await FirebaseMessaging.instance.getToken();
                              print("FCM Token: $fcmToken");
                              if (fcmToken != null) {
                                await NotificationRepository().updateFCMToken(
                                  loginController.user!.id,
                                  fcmToken,
                                );
                              }
                              await AkunPrefs.simpanAkun(
                                idAkun: loginController.user!.id.toString(),
                                nama: loginController.user!.nama,
                                jenisKelamin:
                                    loginController.user!.jeniskelamin,
                                alamat: loginController.user!.alamat,
                                email: loginController.user!.email,
                                noHP: loginController.user!.notelp,
                                role: loginController.user!.role,
                              );
                              print(
                                "User berhasil login: ${loginController.user}",
                              );
                              if (isChecked &&
                                  loginController.user!.notelp != null &&
                                  loginController.user!.notelp!.isNotEmpty) {
                                await BioPrefs.simpanAkun(
                                  noHP: loginController.user!.notelp,
                                );
                                final akun = await BioPrefs.getAkun();
                                print(
                                  "Disimpan ke BioPrefs: ${akun['notelp']}",
                                );
                              } else if (isChecked) {
                                print("Error: noHP from user is null or empty");
                              }
                              print(
                                "User berhasil login: ${loginController.user}",
                              );
                              await Future.delayed(Duration(milliseconds: 100));

                              if (context.mounted) {
                                CustomSnackbar.show(
                                  'Login Berhasil,Selamat Datang ${loginController.user?.nama}',
                                );
                                print("Navigating to HomeScreen...");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            HomeScreen(initialIndex: 2),
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                CustomSnackbar.show(
                                  'Login Gagal, Nomor atau Password Salah',
                                  warna: Colors.red,
                                  tinggi: 100,
                                  icon: Icons.error_outline_rounded,
                                );
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(0),
                      ),
                    ),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            "Sign in",
                            style: TextStyle(
                              fontFamily: "Mulish",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ),
            SizedBox(width: 3),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Warna.backgroundIjo, Warna.backgroundIjoDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final bool canAuthenticateWithBiometrics =
                        await auth.canCheckBiometrics;
                    final bool canAuthenticate =
                        canAuthenticateWithBiometrics ||
                        await auth.isDeviceSupported();
                    print({"Cek Biometrik :": canAuthenticateWithBiometrics});
                    if (canAuthenticateWithBiometrics == false) {
                      CustomSnackbar.show(
                        "Perangkat tidak mendukung biometrik",
                        warna: Colors.red,
                        tinggi: 100,
                        icon: Icons.error_outline_rounded,
                      );
                    }
                    final List<BiometricType> availableBiometrics =
                        await auth.getAvailableBiometrics();
                    print({"Cek available :": availableBiometrics});
                    if (canAuthenticate) {
                      try {
                        final bool didAuthenticate = await auth.authenticate(
                          options: AuthenticationOptions(biometricOnly: true),
                          localizedReason: 'Please authenticate to Sign in',
                        );

                        print(
                          'cek apakah fingerprint benar : $didAuthenticate',
                        );
                        if (didAuthenticate) {
                          final prefs = await BioPrefs.getAkun();
                          final notelp = prefs['notelp'];
                          print("nomormu: $notelp");
                          if (notelp != null && notelp.isNotEmpty) {
                            verifFinger(notelp);
                          } else {
                            print(
                              "Error: Nomor telepon tidak ditemukan di BioPrefs",
                            );
                            if (context.mounted) {
                              CustomSnackbar.show(
                                "Nomor telepon tidak tersimpan",
                                warna: Colors.red,
                                tinggi: 100,
                                icon: Icons.error_outline_rounded,
                              );
                            }
                          }
                        }
                      } on PlatformException {
                        CustomSnackbar.show(
                          'Perangkat tidak support.',
                          warna: Colors.red,
                          tinggi: 100,
                          icon: Icons.error_outline_rounded,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(0),
                      ),
                    ),
                  ),
                  child: Icon(Icons.fingerprint, color: Colors.white, size: 32),
                ),
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
          onPressed: () async {
            try {
              final GoogleSignInAccount? googleUser =
                  await GoogleSignIn().signIn();
              if (googleUser != null) {
                final String email = googleUser.email;
                print(email);
                LoginController loginemailController =
                    Provider.of<LoginController>(context, listen: false);
                await loginemailController.LoginEmail(email);
                if (loginemailController.user != null) {
                  Provider.of<UserProvider>(
                    context,
                    listen: false,
                  ).setUser(loginemailController.user!);
                  await AkunPrefs.simpanAkun(
                    idAkun: loginemailController.user!.id.toString(),
                    nama: loginemailController.user!.nama,
                    jenisKelamin: loginemailController.user!.jeniskelamin,
                    alamat: loginemailController.user!.alamat,
                    email: loginemailController.user!.email,
                    noHP: loginemailController.user!.notelp,
                    role: loginemailController.user!.role,
                  );
                  CustomSnackbar.show(
                    "Berhasil Login,Selamat Datang ${loginemailController.user?.nama}",
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } else {
                  await GoogleSignIn().signOut();
                  CustomSnackbar.show(
                    "Email tidak terdaftar",
                    warna: Colors.red,
                    tinggi: 100,
                    icon: Icons.error_outline_rounded,
                  );
                }
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error signing in with Google: ${e.toString()}',
                  ),
                ),
              );
            }
          },
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
          keyboardType: TextInputType.name,
          icon: Icons.person,
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomTextField(
          label: "Password",
          controller: regispassword,
          hintText: "*************",
          keyboardType: null,
          obscureText: true,
          icon: Icons.visibility,
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomTextField(
          label: "Confirm Password",
          controller: regispasswordkonfirm,
          hintText: "*************",
          obscureText: true,
          keyboardType: null,
          icon: Icons.visibility,
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomTextField(
          label: "Nomor Telepon",
          hintText: "Masukan nomor anda",
          keyboardType: TextInputType.number,
          controller: regisnomor,
          icon: Icons.phone,
        ),
        SizedBox(height: screenHeight * 0.03),
        DropdownButtonFormField<String>(
          focusColor: Colors.white,
          dropdownColor: Colors.white,
          iconEnabledColor: Colors.black,
          elevation: 8,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
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
              color: Colors.grey.shade300,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 0, 0, 0),
                width: 2,
              ),
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
                      color: Colors.black87,
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
          keyboardType: TextInputType.text,
          controller: regisanswer,
          icon: Icons.admin_panel_settings_rounded,
        ),
        SizedBox(height: screenHeight * 0.03),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Jenis Kelamin',
            style: TextStyle(
              fontSize: 16 * textScale,
              fontWeight: FontWeight.bold,
              fontFamily: 'Mulish',
            ),
          ),
        ),
        Row(
          children: [
            Row(
              children: [
                Radio<String>(
                  activeColor: Warna.backgroundIjo,
                  value: 'Pria',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
                Text('Pria'),
              ],
            ),
            SizedBox(width: 20),
            Row(
              children: [
                Radio<String>(
                  value: 'Wanita',
                  activeColor: Warna.backgroundIjo,
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
                Text('Wanita'),
              ],
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.03),
        CustomTextField(
          label: "Alamat",
          hintText: "Masukan alamat anda",
          keyboardType: TextInputType.streetAddress,
          controller: regisalamat,
          icon: Icons.format_list_bulleted_rounded,
        ),
        SizedBox(height: screenHeight * 0.08),
        CustomRoundedButton(
          text: "Sign up",
          backgroundColor: Warna.backgroundIjo,
          textColor: Colors.white,
          onPressed: () async {
            if (regispassword.text != regispasswordkonfirm.text) {
              CustomSnackbar.show(
                "Password tidak cocok",
                warna: Colors.red,
                tinggi: 100,
                icon: Icons.error_outline_rounded,
              );
              return;
            }

            final phone = regisnomor.text.trim();
            if (phone.isEmpty || !RegExp(r'^0[0-9]{9,12}$').hasMatch(phone)) {
              CustomSnackbar.show(
                'Masukkan nomor telepon yang valid',
                warna: Colors.redAccent,
                tinggi: 100,
                icon: Icons.error_outline_rounded,
              );
              return;
            }

            final formattedPhone = '62${phone.substring(1)}';
            final otpCode = (Random().nextInt(900000) + 100000).toString();
            final dio = Dio();

            try {
              final response = await dio.post(
                'http://13.250.111.64:3123/send-otp',
                data: {'phoneNumber': formattedPhone, 'otpCode': otpCode},
                options: Options(headers: {'Content-Type': 'application/json'}),
              );

              if (response.statusCode == 200) {
                CustomSnackbar.show('OTP berhasil dikirim', tinggi: 100);

                TextEditingController otpController = TextEditingController();
                bool isLoading = false;

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text('Verifikasi OTP'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Masukkan kode OTP yang dikirim ke $phone'),
                              SizedBox(height: 16),
                              TextField(
                                controller: otpController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Kode OTP',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () {
                                        Navigator.of(context).pop();
                                      },
                              child: Text('Batal',
                                  style: TextStyle(
                                    fontFamily: "Mulish",
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Warna.backgroundIjoDark,
                              ),
                              onPressed:
                                  isLoading
                                      ? null
                                      : () async {
                                        if (otpController.text == otpCode) {
                                          setState(() {
                                            isLoading = true;
                                          });

                                          
                                          final registerController =
                                              RegisterController();

                                          try {
                                            var response =
                                                await registerController
                                                    .register(
                                                      regisnomor.text,
                                                      regisnama.text,
                                                      regispassword.text,
                                                      selectedValue!,
                                                      regisanswer.text,
                                                      selectedGender!,
                                                      regisalamat.text,
                                                    );

                                            if (response != null) {
                                              CustomSnackbar.show(
                                                'Registrasi Berhasil',
                                                tinggi: 100,
                                              );
                                              Navigator.of(
                                                context,
                                              ).pop(); // Close dialog
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => LoginPage(),
                                                ),
                                              );
                                            } else {
                                              Navigator.of(
                                                context,
                                              ).pop(); // Close dialog
                                              CustomSnackbar.show(
                                                "Register Gagal",
                                                warna: Colors.red,
                                                tinggi: 100,
                                                icon:
                                                    Icons.error_outline_rounded,
                                              );
                                            }
                                          } catch (e) {
                                            Navigator.of(
                                              context,
                                            ).pop(); // Close dialog
                                            CustomSnackbar.show(
                                              "Terjadi Kesalahan",
                                              warna: Colors.red,
                                              tinggi: 100,
                                              icon: Icons.error_outline_rounded,
                                            );
                                          }
                                        } else {
                                          CustomSnackbar.show(
                                            "Kode OTP Salah",
                                            warna: Colors.red,
                                            tinggi: 100,
                                            icon: Icons.error_outline_rounded,
                                          );
                                        }
                                      },
                              child:
                                  isLoading
                                      ? CircularProgressIndicator()
                                      : Text('Verifikasi',
                                          style: TextStyle(
                                            fontFamily: "Mulish",
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),)
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              } else {
                CustomSnackbar.show(
                  'OTP Gagal Dikirim',
                  warna: Colors.red,
                  tinggi: 100,
                  icon: Icons.error_outline_rounded,
                );
              }
            } catch (e) {
              CustomSnackbar.show(
                'Terjadi kesalahan',
                warna: Colors.red,
                tinggi: 100,
                icon: Icons.error_outline_rounded,
              );
            }
          },
        ),
        SizedBox(height: screenHeight * 0.08),
      ],
    );
  }
}
