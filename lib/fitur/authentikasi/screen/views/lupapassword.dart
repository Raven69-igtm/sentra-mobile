import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/fitur/authentikasi/data/controllers/lupapasswordcontroller.dart';
import 'package:sentra/utils/color.dart';
import 'package:sentra/utils/customsnackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra/utils/customtextfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController oldPhoneController = TextEditingController();
  final TextEditingController securityAnswerController =
      TextEditingController();
  final TextEditingController newPhoneController = TextEditingController();
  String? _verificationId;
  String? otpSentGlobal;

  Future<void> _kirimOTP() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty || !RegExp(r'^0[0-9]{9,12}$').hasMatch(phone)) {
      CustomSnackbar.show(
        'Masukkan nomor telepon yang valid',
        warna: Colors.redAccent,
      );
      return;
    }

    final formattedPhone = '62${phone.substring(1)}';

    final otpCode = (Random().nextInt(900000) + 100000).toString();

    final dio = Dio();

    try {
      print(formattedPhone);
      final response = await dio.post(
        'http://13.250.111.64:3123/send-otp',
        data: {'phoneNumber': formattedPhone, 'otpCode': otpCode},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print('Response: ${response.data}');
      print(response.statusCode);
      if (response.statusCode == 200) {
        CustomSnackbar.show(
          'OTP berhasil dikirim',
          tinggi: 100,
          warna: Warna.backgroundIjo,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OtpVerificationScreen(
                  phoneNumber: phone,
                  verificationId: otpCode,
                ),
          ),
        );
      } else {
        CustomSnackbar.show('Gagal mengirim OTP: ${response.statusMessage}');
      }
    } catch (e) {
      CustomSnackbar.show('Terjadi kesalahan: $e');
    }
  }

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
      body: Consumer<LupaPasswordController>(
        builder: (context, controller, child) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Masukkan Nomor Telepon Anda",
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Nomor Telepon sudah tidak aktif ? ',
                        style: TextStyle(
                          fontFamily: "Mulish",
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showOldPhoneDialog(context),
                      child: Flexible(
                        child: Text(
                          "Perbarui Nomor",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            color: Warna.backgroundIjo,
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Warna.backgroundIjo,
                        Warna().darken(Warna.backgroundIjo, 0.1),
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
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _kirimOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
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
                    child: Text(
                      "Next",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOldPhoneDialog(BuildContext context) {
    String? _emergencyQuestion;
    Timer? _debounceTimer;
    final int _debounceTime = 500; // Naikkan debounce untuk performa
    CancelToken? _cancelToken;
    bool _isLoadingQuestion = false;
    bool _isAnswerVerified = false;

    Future<void> _fetchEmergencyQuestion(
      String phoneNumber,
      StateSetter setStateDialog,
    ) async {
      if (_cancelToken != null && !_cancelToken!.isCancelled) {
        _cancelToken!.cancel();
      }
      _cancelToken = CancelToken();

      // Validasi nomor telepon
      if (!RegExp(r'^0[0-9]{9,12}$').hasMatch(phoneNumber)) {
        setStateDialog(() {
          _emergencyQuestion = null;
          _isLoadingQuestion = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Masukkan nomor telepon yang valid')),
        );
        return;
      }

      // Format nomor telepon
      final formattedPhone = '0${phoneNumber.substring(1)}';
      print('Sending phone number: $formattedPhone'); // Log untuk debug

      setStateDialog(() {
        _isLoadingQuestion = true;
        _emergencyQuestion = "Memuat pertanyaan...";
      });

      try {
        final response = await Dio().post(
          'https://${ApiClient.baseUrl}/api/auth/get-emergency-question',
          data: {'notelp': formattedPhone},
          options: Options(
            headers: {'Content-Type': 'application/json'},
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
          ),
          cancelToken: _cancelToken,
        );

        print('API Response: ${response.data}'); // Log untuk debug

        final data = response.data;

        if (response.statusCode == 200 && data['success']) {
          setStateDialog(() {
            _emergencyQuestion = data['emerquest'];
            _isLoadingQuestion = false;
          });
        } else {
          setStateDialog(() {
            _emergencyQuestion = null;
            _isLoadingQuestion = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Gagal mengambil pertanyaan'),
              ),
            );
          }
        }
      } on DioException catch (e) {
        setStateDialog(() {
          _emergencyQuestion = null;
          _isLoadingQuestion = false;
        });
        if (e.type != DioExceptionType.cancel && mounted) {
          String errorMessage = 'Koneksi error. Coba lagi nanti.';
          if (e.response != null) {
            try {
              if (e.response!.data is Map) {
                errorMessage =
                    e.response!.data['message']?.toString() ?? errorMessage;
              } else if (e.response!.data is String) {
                try {
                  final parsed = jsonDecode(e.response!.data);
                  if (parsed is Map) {
                    errorMessage =
                        parsed['message']?.toString() ?? errorMessage;
                  }
                } catch (_) {
                  errorMessage = e.response!.data.toString();
                }
              }
            } catch (_) {
              errorMessage = 'Terjadi kesalahan pada server';
            }
          } else if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Waktu tunggu habis. Periksa koneksi internet Anda.';
          }

          if (mounted) {
            print('Error: $errorMessage'); // Log untuk debug
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
          }
        }
      }
    }

    Future<bool> _verifySecurityAnswer(
      String phoneNumber,
      String answer,
    ) async {
      try {
        final response = await Dio().post(
          'https://${ApiClient.baseUrl}/api/auth/emergency-check',
          data: {'notelp': phoneNumber, 'answer': answer},
          options: Options(
            headers: {'Content-Type': 'application/json'},
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
          ),
        );

        final data = response.data;
        if (response.statusCode == 200) {
          _isAnswerVerified = true;
          return true;
        } else {
          CustomSnackbar.show(data['message'] ?? 'Jawaban salah',warna: Colors.red,tinggi: 100,icon: Icons.error_outline_rounded);
          return false;
        }
      } on DioException catch (e) {
        print(e);
        return false;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                "Masukkan Nomor Lama",
                style: TextStyle(fontFamily: "Mulish"),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: oldPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Masukkan nomor lama (terdaftar)",
                        hintStyle: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        if (_debounceTimer?.isActive ?? false) {
                          _debounceTimer?.cancel();
                        }
                        _debounceTimer = Timer(
                          Duration(milliseconds: _debounceTime),
                          () {
                            if (value.length >= 10) {
                              _fetchEmergencyQuestion(
                                value,
                                setStateDialog,
                              ); // Pass setStateDialog
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: securityAnswerController,
                      enabled:
                          _emergencyQuestion != null && !_isLoadingQuestion,
                      decoration: InputDecoration(
                        hintText:
                            _emergencyQuestion ??
                            (_isLoadingQuestion
                                ? "Memuat pertanyaan..."
                                : "Pertanyaan keamanan akan muncul di sini"),
                        hintStyle: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 14,
                          color:
                              _emergencyQuestion != null && !_isLoadingQuestion
                                  ? Colors.black
                                  : Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Batal",
                    style: TextStyle(
                      fontFamily: "Mulish",
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Warna.backgroundIjo,
                        Warna().darken(Warna.backgroundIjo, 0.1),
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
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed:
                        _emergencyQuestion == null || _isLoadingQuestion
                            ? null
                            : () async {
                              if (securityAnswerController.text.isEmpty) {
                                CustomSnackbar.show("Masukkan Jawaban Keamanan Anda",warna: Colors.red,tinggi: 100,icon: Icons.error_outline_rounded);
                                return;
                              }
                              _isAnswerVerified = await _verifySecurityAnswer(
                                oldPhoneController.text,
                                securityAnswerController.text,
                              );
                              if (_isAnswerVerified==true) {
                                Navigator.pop(context);
                                _showNewPhoneDialog(context);
                              }else{
                                CustomSnackbar.show("Jawaban Salah",warna: Colors.red,tinggi: 100,icon: Icons.error_outline_rounded);
                              }

                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
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
                      "Submit",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    @override
    void dispose() {
      _cancelToken?.cancel();
      _debounceTimer?.cancel();
      oldPhoneController.dispose();
      securityAnswerController.dispose();
      super.dispose();
    }
  }

  void _showNewPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Masukkan Nomor Baru",
            style: TextStyle(fontFamily: "Mulish"),
          ),
          content: TextField(
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: TextStyle(
                  fontFamily: "Mulish",
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Warna.backgroundIjo,
                    Warna().darken(Warna.backgroundIjo, 0.01),
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
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  final controller = Provider.of<LupaPasswordController>(
                    context,
                    listen: false,
                  );
                  await controller.gantiNomor(
                    oldPhoneController.text,
                    newPhoneController.text,
                    securityAnswerController.text,
                  );
                  if (controller.successMessage != null) {
                    oldPhoneController.clear();
                    securityAnswerController.clear();
                    newPhoneController.clear();
                    CustomSnackbar.show(
                      'Nomor berhasil diupdate',
                      tinggi: 100,
                      warna: Warna.backgroundIjo,
                    );
                    Navigator.pop(context);
                  } else if (controller.errorMessage != null) {
                    CustomSnackbar.show(controller.errorMessage);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
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
                  "Submit",
                  style: TextStyle(fontFamily: "Mulish", color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  late final String verificationId;

  OtpVerificationScreen({
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  int _secondsRemaining = 300;
  bool _canResend = false;
  get phoneNumber => null;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
        _startTimer();
      } else {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  Future<void> _resendOTP() async {
    final phone = widget.phoneNumber.trim();

    if (phone.isEmpty || !RegExp(r'^0[0-9]{9,12}$').hasMatch(phone)) {
      CustomSnackbar.show(
        'Masukkan nomor telepon yang valid',
        warna: Colors.redAccent,
      );
      return;
    }

    final formattedPhone = '62${phone.substring(1)}';

    final otpCode = (Random().nextInt(900000) + 100000).toString();

    final dio = Dio();

    try {
      print(formattedPhone);
      final response = await dio.post(
        'http://13.250.111.64:3123/send-otp',
        data: {'phoneNumber': formattedPhone, 'otpCode': otpCode},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        CustomSnackbar.show('OTP berhasil dikirim');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OtpVerificationScreen(
                  phoneNumber: phone,
                  verificationId: otpCode,
                ),
          ),
        );
      } else {
        CustomSnackbar.show('Gagal mengirim OTP: ${response.statusMessage}');
      }
    } catch (e) {
      CustomSnackbar.show('Terjadi kesalahan: $e');
    }
  }

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
              "6 Digit Code",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Masukkan kode yang telah dikirim ke nomor anda",
              style: TextStyle(fontFamily: "Mulish"),
            ),
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
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Code expires in ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}",
              style: TextStyle(fontFamily: "Mulish"),
            ),
            TextButton(
              onPressed: _canResend ? _resendOTP : null,
              child: Text("Resend", style: TextStyle(fontFamily: "Mulish")),
            ),
            Spacer(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Warna.backgroundIjo,
                    Warna().darken(Warna.backgroundIjo, 0.01),
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
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  final enteredOTP =
                      otpControllers
                          .map((controller) => controller.text)
                          .join();

                  // Bandingkan dengan _otpSent
                  if (enteredOTP == widget.verificationId) {
                    CustomSnackbar.show('OTP berhasil diverifikasi');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ResetPasswordScreen(
                              phoneNumber: widget.phoneNumber,
                            ),
                      ),
                    );
                  } else {
                    CustomSnackbar.show('OTP tidak cocok', warna: Colors.red);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
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
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
  final String phoneNumber;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  ResetPasswordScreen({required this.phoneNumber});

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
              "Masukkan Password Baru Anda",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            CustomTextField(
              label: "Password baru",
              controller: passwordController,
              hintText: "*************",
              keyboardType: null,
              obscureText: true,
              icon: Icons.visibility,
            ),
            SizedBox(height: 10),
            CustomTextField(
              label: "Confirm Password Baru",
              controller: confirmPasswordController,
              hintText: "*************",
              obscureText: true,
              keyboardType: null,
              icon: Icons.visibility,
            ),
            Spacer(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Warna.backgroundIjo,
                    Warna().darken(Warna.backgroundIjo, 0.01),
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
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    CustomSnackbar.show('Password tidak cocok');
                    return;
                  }
                  if (passwordController.text.length < 6) {
                    CustomSnackbar.show('Password minimal 6 karakter');
                    return;
                  }
                  final controller = Provider.of<LupaPasswordController>(
                    context,
                    listen: false,
                  );
                  await controller.updatePassword(
                    phoneNumber,
                    passwordController.text,
                    confirmPasswordController.text,
                  );
                  if (controller.successMessage != null) {
                    CustomSnackbar.show("Password Berhasil diganti");
                    Navigator.popUntil(context, (route) => route.isFirst);
                  } else if (controller.errorMessage != null) {
                    CustomSnackbar.show(controller.errorMessage);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
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
                  "Submit",
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
