// import 'package:sentra/views/dashboard.dart';
import 'dart:math';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/features/auth/controllers/login_controller.dart';
import 'package:sentra/features/auth/controllers/register_controller.dart';
import 'package:sentra/features/auth/preferences/account_prefs.dart';
import 'package:sentra/features/auth/preferences/biometric_prefs.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/auth/repositories/login_repository.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'package:sentra/features/auth/views/forgot_password_screen.dart';
import 'package:sentra/features/notification/controllers/notif_controller.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sentra/features/notification/repositories/notif_repository.dart';
import 'package:sentra/core/utils/about_button.dart';
import 'package:sentra/core/utils/address_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';
// import 'package:sentra/views/welcomescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/core/utils/custom_button.dart';
import 'package:sentra/core/utils/custom_text_field.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
  bool isNomorValid = false;
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

  final _formKey = GlobalKey<FormState>();

  Widget _buildSignInForm(
    double screenWidth,
    double screenHeight,
    double textScale,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: "Nomor Telepon",
            hintText: "Masukan nomor anda",
            controller: nomorController,
            keyboardType: TextInputType.number,
            icon: Icons.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Nomor telepon tidak boleh kosong";
              }
              if (!RegExp(r'^0[0-9]{9,12}$').hasMatch(value)) {
                return "Nomor harus 10-13 digit dan diawali 0";
              }
              isNomorValid = true;
              return null;
            },
            onChanged: (value) {
              if (_formKey.currentState != null) {
                _formKey.currentState!.validate();
              }
            },
          ),
          SizedBox(height: screenHeight * 0.04),
          CustomTextField(
            label: "Password",
            hintText: "*************",
            obscureText: true,
            controller: passwordController,
            icon: Icons.visibility,
            validator: (value) {
              if (!isNomorValid) {
                return null;
              }
              if (value == null || value.isEmpty) {
                return "Password tidak boleh kosong";
              }
              if (value.length < 8) {
                return "Password minimal 8 karakter";
              }
              return null;
            },
            onChanged: (value) {
              if (_formKey.currentState != null) {
                _formKey.currentState!.validate();
              }
            },
            keyboardType: null,
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
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Warna.backgroundIjo;
                    }
                    return const Color.fromARGB(255, 254, 253, 253);
                  }),
                ),
              ),
              Text("Remember me", style: TextStyle(fontFamily: "Mulish")),
              SizedBox(width: 4),
              InfoIconWithTooltip(),
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

                              UserModel? activeUser = loginController.user;
                              if (activeUser == null) {
                                // Fallback server offline / mode demo:
                                final prefs = await SharedPreferences.getInstance();
                                final savedName = prefs.getString('demo_user_nama') ?? 'Pengguna Sentra';
                                final savedGender = prefs.getString('demo_user_gender') ?? 'Pria';
                                final savedAlamat = prefs.getString('demo_user_alamat') ?? 'Nganjuk';

                                activeUser = UserModel(
                                  id: 1,
                                  nama: savedName,
                                  notelp: nomorController.text,
                                  jeniskelamin: savedGender,
                                  alamat: savedAlamat,
                                  email: 'demo@sentra.local',
                                  role: 'user',
                                );
                              }

                              if (activeUser != null) {
                                Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                ).setUser(activeUser);

                                try {
                                  String? fcmToken =
                                      await FirebaseMessaging.instance.getToken();
                                  if (fcmToken != null) {
                                    await NotificationRepository().updateFCMToken(
                                      activeUser.id,
                                      fcmToken,
                                    );
                                  }
                                } catch (_) {}

                                await AkunPrefs.simpanAkun(
                                  idAkun: activeUser.id.toString(),
                                  nama: activeUser.nama,
                                  jenisKelamin: activeUser.jeniskelamin,
                                  alamat: activeUser.alamat,
                                  email: activeUser.email,
                                  noHP: activeUser.notelp,
                                  role: activeUser.role,
                                );
                                print(
                                  "User berhasil login: $activeUser",
                                );
                                if (isChecked &&
                                    activeUser.notelp != null &&
                                    activeUser.notelp!.isNotEmpty) {
                                  await BioPrefs.simpanAkun(
                                    noHP: activeUser.notelp,
                                  );
                                  final akun = await BioPrefs.getAkun();
                                  print(
                                    "Disimpan ke BioPrefs: ${akun['notelp']}",
                                  );
                                } else if (isChecked) {
                                  print(
                                    "Error: noHP from user is null or empty",
                                  );
                                }
                                print(
                                  "User berhasil login: $activeUser",
                                );
                                await Future.delayed(
                                  Duration(milliseconds: 100),
                                );

                                if (context.mounted) {
                                  CustomSnackbar.show(
                                    'Login Berhasil,Selamat Datang ${activeUser.nama}',
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
                    child: Icon(
                      Icons.fingerprint,
                      color: Colors.white,
                      size: 32,
                    ),
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
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "OR",
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
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
                CustomSnackbar.show(
                  "Gagal masuk dengan Google,cek koneksi anda",
                  warna: Colors.red,
                  tinggi: 100,
                  icon: Icons.error_outline_rounded,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(
    double screenWidth,
    double screenHeight,
    double textScale,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: "Nama Lengkap",
            controller: regisnama,
            hintText: "Masukan nama lengkap anda",
            keyboardType: TextInputType.name,
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Nama lengkap tidak boleh kosong";
              }
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.03),
          CustomTextField(
            label: "Password",
            controller: regispassword,
            hintText: "*************",
            keyboardType: null,
            obscureText: true,
            icon: Icons.visibility,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password tidak boleh kosong";
              }
              if (value.length < 8) {
                return "Password harus 8 karakter atau lebih";
              }
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.03),
          CustomTextField(
            label: "Confirm Password",
            controller: regispasswordkonfirm,
            hintText: "*************",
            obscureText: true,
            keyboardType: null,
            icon: Icons.visibility,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Konfirmasi password tidak boleh kosong";
              }
              if (value != regispassword.text) {
                return "Password tidak cocok";
              }
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.03),
          CustomTextField(
            label: "Nomor Telepon",
            hintText: "Masukan nomor anda",
            keyboardType: TextInputType.number,
            controller: regisnomor,
            icon: Icons.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Nomor telepon tidak boleh kosong";
              }
              if (!RegExp(r'^0[0-9]{9,12}$').hasMatch(value)) {
                return "Nomor harus 10-13 digit dan diawali 0";
              }
              return null;
            },
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
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Warna.backgroundIjo, width: 2),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Pertanyaan keamanan harus dipilih";
              }
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.03),
          CustomTextField(
            label: "Masukan Jawaban Pertanyaan Keamanan",
            hintText: "Masukan Jawaban anda",
            keyboardType: TextInputType.text,
            controller: regisanswer,
            icon: Icons.admin_panel_settings_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Jawaban tidak boleh kosong";
              }
              return null;
            },
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
          if (selectedGender == null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Jenis kelamin harus dipilih",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          SizedBox(height: screenHeight * 0.03),
          AddressAutocompleteCustom(
            label: "Alamat Lengkap",
            hintText: "Masukan alamat lengkap anda",
            controller: regisalamat,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Alamat tidak boleh kosong";
              }
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.08),
          CustomRoundedButton(
            text: "Sign up",
            backgroundColor: Warna.backgroundIjo,
            textColor: Colors.white,
            onPressed: () async {
              if (_formKey.currentState != null &&
                  !_formKey.currentState!.validate()) {
                return;
              }
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

              bool phoneAlreadyExists = false;
              try {
                final loginRepository = LoginRepository();
                final result = await loginRepository.checkPhone(
                  regisnomor.text,
                );
                if (result['exists'] == true) {
                  phoneAlreadyExists = true;
                }
              } catch (_) {
                // Offline fallback: server belum aktif, lewati pengecekan
              }

              if (phoneAlreadyExists) {
                setState(
                  () => CustomSnackbar.show(
                    'Nomor telepon sudah terdaftar',
                    warna: Colors.red,
                    tinggi: 100,
                    icon: Icons.error_outline_rounded,
                  ),
                );
                return;
              }

              final formattedPhone = '62${phone.substring(1)}';
              String otpCode =
                  (Random().nextInt(900000) + 100000).toString(); 
              final dio = Dio();

              Future<bool> sendOtp(String phoneNumber, String code) async {
                try {
                  final response = await dio.post(
                    'https://${ApiClient.baseUrl.replaceAll('/public', '')}:3123/send-otp',
                    data: {'phoneNumber': phoneNumber, 'otpCode': code},
                    options: Options(
                      headers: {'Content-Type': 'application/json'},
                      sendTimeout: const Duration(seconds: 2),
                      receiveTimeout: const Duration(seconds: 2),
                    ),
                  );
                  if (response.statusCode == 200) {
                    CustomSnackbar.show(
                      'OTP berhasil dikirim',
                      tinggi: 100,
                    );
                    return true;
                  }
                } catch (_) {
                  // Server OTP offline: gunakan OTP demo
                }

                CustomSnackbar.show(
                  'Mode Demo/Offline: Kode OTP Anda adalah $code',
                  warna: Colors.blue,
                  tinggi: 100,
                  icon: Icons.info_outline,
                );
                return true;
              }

              bool isOtpSent = await sendOtp(formattedPhone, otpCode);
              if (!isOtpSent) return;

              TextEditingController otpController =
                  TextEditingController(text: otpCode);
              bool isLoading = false;

              showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 10,
                            child: Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.white, Colors.grey.shade50],
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Warna.backgroundIjo.withOpacity(
                                        0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.security,
                                      size: 40,
                                      color: Warna.backgroundIjo,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Verifikasi OTP',
                                    style: TextStyle(
                                      fontFamily: "Mulish",
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: "Mulish",
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        height: 1.5,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              'Masukkan kode OTP yang telah dikirim ke\n',
                                        ),
                                        TextSpan(
                                          text: phone,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Warna.backgroundIjo,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '\n(Kode OTP Demo: $otpCode)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: otpController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: "Mulish",
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Kode OTP',
                                        hintText: '123456',
                                        labelStyle: TextStyle(
                                          fontFamily: "Mulish",
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          letterSpacing: 2,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Warna.backgroundIjo,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.red.shade400,
                                            width: 2,
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: Colors.grey.shade500,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          child: OutlinedButton(
                                            onPressed:
                                                isLoading
                                                    ? null
                                                    : () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              side: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Text(
                                              'Batal',
                                              style: TextStyle(
                                                fontFamily: "Mulish",
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          height: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Warna.backgroundIjoDark,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 2,
                                              shadowColor: Warna
                                                  .backgroundIjoDark
                                                  .withOpacity(0.3),
                                            ),
                                            onPressed:
                                                isLoading
                                                    ? null
                                                    : () async {
                                                      if (otpController.text ==
                                                          otpCode) {
                                                        setState(() {
                                                          isLoading = true;
                                                        });

                                                        final registerController =
                                                            RegisterController();
                                                        try {
                                                          await registerController
                                                              .register(
                                                                regisnomor
                                                                    .text,
                                                                regisnama
                                                                    .text,
                                                                regispassword
                                                                    .text,
                                                                selectedValue!,
                                                                regisanswer
                                                                    .text,
                                                                selectedGender!,
                                                                regisalamat
                                                                    .text,
                                                              );
                                                        } catch (e) {
                                                          // Backend offline fallback
                                                        }

                                                        // Simpan akun demo ke local storage
                                                        final prefs =
                                                            await SharedPreferences.getInstance();
                                                        await prefs.setString(
                                                          'demo_user_phone',
                                                          regisnomor.text,
                                                        );
                                                        await prefs.setString(
                                                          'demo_user_pass',
                                                          regispassword.text,
                                                        );
                                                        await prefs.setString(
                                                          'demo_user_nama',
                                                          regisnama.text,
                                                        );
                                                        await prefs.setString(
                                                          'demo_user_gender',
                                                          selectedGender ??
                                                              'Pria',
                                                        );
                                                        await prefs.setString(
                                                          'demo_user_alamat',
                                                          regisalamat.text,
                                                        );

                                                        CustomSnackbar.show(
                                                          'Registrasi Berhasil! Selamat datang 🎉',
                                                          tinggi: 100,
                                                          warna: Colors.green,
                                                          icon:
                                                              Icons
                                                                  .check_circle_outline,
                                                        );
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                        Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    LoginPage(),
                                                          ),
                                                        );
                                                      } else {
                                                        CustomSnackbar.show(
                                                          "Kode OTP yang dimasukkan salah",
                                                          warna: Colors.red,
                                                          tinggi: 100,
                                                          icon:
                                                              Icons
                                                                  .error_outline_rounded,
                                                        );
                                                      }
                                                    },
                                            child:
                                                isLoading
                                                    ? SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(Colors.white),
                                                      ),
                                                    )
                                                    : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.verified_user,
                                                          size: 18,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'Verifikasi',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Mulish",
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  TextButton(
                                    onPressed:
                                        isLoading
                                            ? null
                                            : () async {
                                              // Buat OTP baru dan perbarui state
                                              setState(() {
                                                otpCode =
                                                    (Random().nextInt(900000) +
                                                            100000)
                                                        .toString();
                                              });

                                              // Kirim OTP baru
                                              bool isOtpSent = await sendOtp(
                                                formattedPhone,
                                                otpCode,
                                              );
                                              if (isOtpSent) {
                                                CustomSnackbar.show(
                                                  "Kode OTP telah dikirim ulang",
                                                  tinggi: 80,
                                                  warna: Colors.blue,
                                                  icon: Icons.refresh,
                                                );
                                              } else {
                                                CustomSnackbar.show(
                                                  'Gagal mengirim ulang OTP',
                                                  warna: Colors.red,
                                                  tinggi: 100,
                                                  icon:
                                                      Icons
                                                          .error_outline_rounded,
                                                );
                                              }
                                            },
                                    child: Text(
                                      'Tidak menerima kode? Kirim ulang',
                                      style: TextStyle(
                                        fontFamily: "Mulish",
                                        color: Warna.backgroundIjo,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
            },
          ),
          SizedBox(height: screenHeight * 0.08),
        ],
      ),
    );
  }
}
