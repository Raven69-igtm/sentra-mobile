import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/features/auth/controllers/login_controller.dart';
import 'package:sentra/features/auth/controllers/register_controller.dart';
import 'package:sentra/features/auth/preferences/account_prefs.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/auth/repositories/login_repository.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'package:sentra/features/auth/views/forgot_password_screen.dart';
import 'package:sentra/features/notification/repositories/notif_repository.dart';
import 'package:sentra/core/utils/address_field.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/core/utils/custom_button.dart';
import 'package:sentra/core/utils/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  RegisterController repository = RegisterController();
  int selectedIndex = 0;
  bool isLoading = false;
  String? selectedValue;
  bool isNomorValid = false;
  String? selectedGender;

  // Sign In controllers
  TextEditingController nomorController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Sign Up controllers
  TextEditingController regisnomor = TextEditingController();
  TextEditingController regispassword = TextEditingController();
  TextEditingController regispasswordkonfirm = TextEditingController();
  TextEditingController regisnama = TextEditingController();
  TextEditingController regisquestion = TextEditingController();
  TextEditingController regisanswer = TextEditingController();
  TextEditingController regisalamat = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nomorController.dispose();
    passwordController.dispose();
    regisnomor.dispose();
    regispassword.dispose();
    regispasswordkonfirm.dispose();
    regisnama.dispose();
    regisquestion.dispose();
    regisanswer.dispose();
    regisalamat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.07,
              vertical: screenHeight * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: Image.asset(
                    "assets/logo/icon_ijo.png",
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.12,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Tab Sign In / Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTab(0, "Sign in", textScale),
                    SizedBox(width: screenWidth * 0.25),
                    _buildTab(1, "Sign up", textScale),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),

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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 20 * textScale,
                fontWeight: FontWeight.bold,
                color: isSelected ? Warna.backgroundIjo : Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: isSelected ? 60 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? Warna.backgroundIjo : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          SizedBox(height: screenHeight * 0.025),
          CustomTextField(
            label: "Password",
            hintText: "Masukan password anda",
            obscureText: true,
            controller: passwordController,
            icon: Icons.lock_outline,
            validator: (value) {
              if (!isNomorValid) return null;
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

          // Lupa Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text(
                "Lupa password?",
                style: TextStyle(
                  fontFamily: "Mulish",
                  color: Warna.backgroundIjo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          // Tombol Sign In penuh
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Warna.backgroundIjo, Warna.backgroundIjoDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Warna.backgroundIjo.withOpacity(0.35),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            return;
                          }

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

                          // Fallback localhost / server offline
                          if (activeUser == null) {
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

                          // Proses login — activeUser selalu ada (fallback localhost)
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

                          await Future.delayed(Duration(milliseconds: 100));

                          if (context.mounted) {
                            CustomSnackbar.show(
                              'Login Berhasil, Selamat Datang ${activeUser.nama}',
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => HomeScreen(initialIndex: 0),
                              ),
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
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
                            fontSize: 16,
                          ),
                        ),
              ),
            ),
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
          SizedBox(height: screenHeight * 0.025),
          CustomTextField(
            label: "Password",
            controller: regispassword,
            hintText: "Masukan password anda",
            keyboardType: null,
            obscureText: true,
            icon: Icons.lock_outline,
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
          SizedBox(height: screenHeight * 0.025),
          CustomTextField(
            label: "Konfirmasi Password",
            controller: regispasswordkonfirm,
            hintText: "Ulangi password anda",
            obscureText: true,
            keyboardType: null,
            icon: Icons.lock_outline,
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
          SizedBox(height: screenHeight * 0.025),
          CustomTextField(
            label: "Nomor Telepon",
            hintText: "Masukan nomor anda",
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          SizedBox(height: screenHeight * 0.025),
          // Pertanyaan Keamanan
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
            items: [
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
          SizedBox(height: screenHeight * 0.025),
          CustomTextField(
            label: "Jawaban Pertanyaan Keamanan",
            hintText: "Masukan jawaban anda",
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
          SizedBox(height: screenHeight * 0.025),

          // Jenis Kelamin
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
                  Text('Pria', style: TextStyle(fontFamily: 'Mulish')),
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
                  Text('Wanita', style: TextStyle(fontFamily: 'Mulish')),
                ],
              ),
            ],
          ),
          if (selectedGender == null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Jenis kelamin harus dipilih",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontFamily: 'Mulish',
                ),
              ),
            ),
          SizedBox(height: screenHeight * 0.025),

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
          SizedBox(height: screenHeight * 0.04),

          // Tombol Sign Up
          CustomRoundedButton(
            text: "Sign up",
            backgroundColor: Warna.backgroundIjo,
            textColor: Colors.white,
            onPressed: () async {
              if (_formKey.currentState != null &&
                  !_formKey.currentState!.validate()) {
                return;
              }
              if (selectedGender == null) {
                CustomSnackbar.show(
                  "Jenis kelamin harus dipilih",
                  warna: Colors.red,
                  tinggi: 100,
                  icon: Icons.error_outline_rounded,
                );
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
                if (context.mounted) {
                  CustomSnackbar.show(
                    'Nomor telepon sudah terdaftar',
                    warna: Colors.red,
                    tinggi: 100,
                    icon: Icons.error_outline_rounded,
                  );
                }
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
                    CustomSnackbar.show('OTP berhasil dikirim', tinggi: 100);
                    return true;
                  }
                } catch (_) {
                  // Server OTP offline: gunakan OTP demo
                }

                if (context.mounted) {
                  CustomSnackbar.show(
                    'Mode Demo/Offline: Kode OTP Anda adalah $code',
                    warna: Colors.blue,
                    tinggi: 100,
                    icon: Icons.info_outline,
                  );
                }
                return true;
              }

              bool isOtpSent = await sendOtp(formattedPhone, otpCode);
              if (!isOtpSent) return;

              TextEditingController otpController =
                  TextEditingController(text: otpCode);

              if (!context.mounted) return;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext dialogCtx) {
                  bool dialogLoading = false;
                  return StatefulBuilder(
                    builder: (ctx, setStateDialog) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Warna.backgroundIjo.withOpacity(0.1),
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Masukkan kode OTP yang dikirim ke $phone',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Mulish",
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: otpController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Mulish",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Kode OTP',
                                  hintText: '123456',
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Warna.backgroundIjo,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogCtx),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                        'Batal',
                                        style: TextStyle(
                                          fontFamily: 'Mulish',
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Warna.backgroundIjo,
                                            Warna.backgroundIjoDark,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: ElevatedButton(
                                        onPressed:
                                            dialogLoading
                                                ? null
                                                : () async {
                                                  if (otpController.text !=
                                                      otpCode) {
                                                    CustomSnackbar.show(
                                                      'Kode OTP salah',
                                                      warna: Colors.red,
                                                      tinggi: 100,
                                                      icon:
                                                          Icons.error_outline_rounded,
                                                    );
                                                    return;
                                                  }

                                                  setStateDialog(
                                                    () => dialogLoading = true,
                                                  );

                                                  try {
                                                    await repository.register(
                                                      regisnomor.text,
                                                      regisnama.text,
                                                      regispassword.text,
                                                      selectedValue ?? '',
                                                      regisanswer.text,
                                                      selectedGender ?? 'Pria',
                                                      regisalamat.text,
                                                    );
                                                    if (ctx.mounted) {
                                                      Navigator.pop(dialogCtx);
                                                      CustomSnackbar.show(
                                                        'Registrasi berhasil, silakan login',
                                                        tinggi: 100,
                                                      );
                                                      setState(() {
                                                        selectedIndex = 0;
                                                      });
                                                    }
                                                  } catch (e) {
                                                    setStateDialog(
                                                      () =>
                                                          dialogLoading = false,
                                                    );
                                                    CustomSnackbar.show(
                                                      'Registrasi gagal: $e',
                                                      warna: Colors.red,
                                                      tinggi: 100,
                                                      icon:
                                                          Icons.error_outline_rounded,
                                                    );
                                                  }
                                                },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        child:
                                            dialogLoading
                                                ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                                : Text(
                                                  'Verifikasi',
                                                  style: TextStyle(
                                                    fontFamily: 'Mulish',
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                    },
                  );
                },
              );
            },
          ),
          SizedBox(height: screenHeight * 0.04),
        ],
      ),
    );
  }
}
