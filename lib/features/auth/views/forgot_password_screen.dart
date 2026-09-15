import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/features/auth/controllers/forgot_password_controller.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/utils/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

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
      FocusScope.of(context).unfocus();
      CustomSnackbar.show(
        'Masukkan nomor telepon yang valid',
        warna: Colors.redAccent,
        tinggi: 100,
      );
      return;
    }

    final formattedPhone = '62${phone.substring(1)}';

    final otpCode = (Random().nextInt(900000) + 100000).toString();

    final dio = Dio();

    try {
      print(formattedPhone);
      final response = await dio.post(
        'http://18.136.209.83:3123/send-otp',
        data: {'phoneNumber': formattedPhone, 'otpCode': otpCode},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print('Response: ${response.data}');
      print(response.statusCode);
      if (response.statusCode == 200) {
        FocusScope.of(context).unfocus();
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
        FocusScope.of(context).unfocus();
        CustomSnackbar.show(
          'Gagal mengirim OTP',
          warna: Colors.redAccent,
          tinggi: 100,
          icon: Icons.error_outline_rounded,
        );
      }
    } catch (e) {
      FocusScope.of(context).unfocus();
      CustomSnackbar.show(
        'Terjadi kesalahan,silahkan cek koneksi internet anda',
        warna: Colors.redAccent,
        tinggi: 100,
        icon: Icons.error_outline_rounded,
      );
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
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/logo/icon_ijo.png', height: 30),
        centerTitle: true,
      ),
      body: Consumer<LupaPasswordController>(
        builder: (context, controller, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Warna.backgroundIjo.withOpacity(0.12),
                          Warna.backgroundBiru.withOpacity(0.10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Lupa Password",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Kami akan mengirimkan OTP ke nomor telepon kamu.",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            color: Colors.black54,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.withOpacity(0.10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Nomor Telepon",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          cursorColor: Colors.black,
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: const Icon(Icons.phone_rounded),
                            hintText: "Masukkan nomor anda",
                            hintStyle: const TextStyle(fontFamily: 'Mulish'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Warna.backgroundIjo,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Nomor telepon sudah tidak aktif?',
                                style: TextStyle(
                                  fontFamily: "Mulish",
                                  color: Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            InkWell(
                              onTap: () => _showOldPhoneDialog(context),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 6,
                                ),
                                child: Text(
                                  "Perbarui Nomor",
                                  style: TextStyle(
                                    fontFamily: "Mulish",
                                    color: Warna.backgroundIjo,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
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
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _kirimOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 52),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        "Kirim OTP",
                        style: TextStyle(
                          fontFamily: "Mulish",
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOldPhoneDialog(BuildContext context) {
    String? emergencyQuestion;
    Timer? debounceTimer;
    final int debounceTime = 500;
    CancelToken? cancelToken;
    bool isLoadingQuestion = false;
    bool isAnswerVerified = false;
    bool isVerifying = false;

    Future<void> fetchEmergencyQuestion(
      String phoneNumber,
      StateSetter setStateDialog,
    ) async {
      if (cancelToken != null && !cancelToken!.isCancelled) {
        cancelToken!.cancel();
      }
      cancelToken = CancelToken();

      if (!RegExp(r'^0[0-9]{9,12}$').hasMatch(phoneNumber)) {
        setStateDialog(() {
          emergencyQuestion = null;
          isLoadingQuestion = false;
        });
        CustomSnackbar.show(
          'Format nomor telepon tidak valid (gunakan 08xxxxxxxxxx)',
          warna: Colors.orange,
          tinggi: 100,
          icon: Icons.warning_amber_rounded,
        );
        return;
      }

      final formattedPhone = '0${phoneNumber.substring(1)}';
      print('Sending phone number: $formattedPhone');
      setStateDialog(() {
        isLoadingQuestion = true;
        emergencyQuestion = null;
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
          cancelToken: cancelToken,
        );

        print('API Response: ${response.data}');
        final data = response.data;

        if (response.statusCode == 200 && data['success']) {
          setStateDialog(() {
            emergencyQuestion = data['emerquest'];
            isLoadingQuestion = false;
          });
        } else {
          setStateDialog(() {
            emergencyQuestion = null;
            isLoadingQuestion = false;
          });
          if (mounted) {
            CustomSnackbar.show(
              data['message'] ??
                  'Nomor telepon tidak terdaftar atau tidak memiliki pertanyaan keamanan',
              warna: Colors.red,
              tinggi: 100,
              icon: Icons.error_outline,
            );
          }
        }
      } on DioException catch (e) {
        setStateDialog(() {
          emergencyQuestion = null;
          isLoadingQuestion = false;
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
            print('Error: $errorMessage');
            CustomSnackbar.show(
              errorMessage,
              warna: Colors.red,
              tinggi: 100,
              icon: Icons.wifi_off_rounded,
            );
          }
        }
      }
    }

    Future<bool> verifySecurityAnswer(String phoneNumber, String answer) async {
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
          isAnswerVerified = true;
          return true;
        } else {
          FocusScope.of(context).unfocus();
          CustomSnackbar.show(
            data['message'] ?? 'Jawaban keamanan tidak sesuai',
            warna: Colors.red,
            tinggi: 100,
            icon: Icons.error_outline_rounded,
          );
          return false;
        }
      } on DioException catch (e) {
        print(e);
        CustomSnackbar.show(
          'Gagal memverifikasi jawaban. Periksa koneksi internet Anda.',
          warna: Colors.red,
          tinggi: 100,
          icon: Icons.wifi_off_rounded,
        );
        return false;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 12,
              child: Container(
                constraints: BoxConstraints(maxWidth: 420),
                padding: EdgeInsets.all(28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Warna.backgroundIjo.withOpacity(0.02),
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header dengan icon
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Warna.backgroundIjo.withOpacity(0.1),
                              Warna.backgroundIjo.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone_android_rounded,
                          size: 48,
                          color: Warna.backgroundIjo,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Title dan subtitle
                      Text(
                        'Verifikasi Nomor Lama',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Mulish",
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),

                      Text(
                        'Masukkan nomor telepon lama yang terdaftar untuk mendapatkan pertanyaan keamanan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Mulish",
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 28),

                      // Input nomor telepon lama
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
                          cursorColor: Warna.backgroundIjo,
                          controller: oldPhoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Nomor Telepon Lama',
                            hintText: '08xxxxxxxxxx',
                            labelStyle: TextStyle(
                              fontFamily: "Mulish",
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                            hintStyle: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
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
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                              color: Colors.grey.shade500,
                            ),
                            suffixIcon:
                                oldPhoneController.text.isNotEmpty
                                    ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.grey.shade400,
                                      ),
                                      onPressed: () {
                                        oldPhoneController.clear();
                                        setStateDialog(() {
                                          emergencyQuestion = null;
                                        });
                                      },
                                    )
                                    : null,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (value) {
                            setStateDialog(() {});
                            if (debounceTimer?.isActive ?? false) {
                              debounceTimer?.cancel();
                            }
                            debounceTimer = Timer(
                              Duration(milliseconds: debounceTime),
                              () {
                                if (value.length >= 10) {
                                  fetchEmergencyQuestion(value, setStateDialog);
                                } else {
                                  setStateDialog(() {
                                    emergencyQuestion = null;
                                    isLoadingQuestion = false;
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),

                      // Loading atau pertanyaan keamanan
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isLoadingQuestion)
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Warna.backgroundIjo.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Warna.backgroundIjo.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Warna.backgroundIjo,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Mengambil pertanyaan keamanan...',
                                        style: TextStyle(
                                          fontFamily: "Mulish",
                                          color: Warna.backgroundIjo,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (!isLoadingQuestion &&
                                emergencyQuestion != null) ...[
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.help_outline_rounded,
                                          color: Colors.green.shade600,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Pertanyaan Keamanan:',
                                          style: TextStyle(
                                            fontFamily: "Mulish",
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      emergencyQuestion!,
                                      style: TextStyle(
                                        fontFamily: "Mulish",
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),

                              // Input jawaban keamanan
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
                                  cursorColor: Warna.backgroundIjo,
                                  controller: securityAnswerController,
                                  enabled: !isVerifying,
                                  style: TextStyle(
                                    fontFamily: "Mulish",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Jawaban Keamanan',
                                    hintText: 'Masukkan jawaban Anda...',
                                    labelStyle: TextStyle(
                                      fontFamily: "Mulish",
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                    hintStyle: TextStyle(
                                      fontFamily: 'Mulish',
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
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
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.key_outlined,
                                      color: Colors.grey.shade500,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setStateDialog(() {});
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 32),

                      // Tombol aksi
                      Row(
                        children: [
                          // Tombol Batal
                          Expanded(
                            child: Container(
                              height: 50,
                              child: OutlinedButton(
                                onPressed:
                                    isVerifying
                                        ? null
                                        : () {
                                          cancelToken?.cancel();
                                          debounceTimer?.cancel();
                                          Navigator.pop(context);
                                        },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey.shade400,
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

                          // Tombol Submit
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient:
                                    (emergencyQuestion != null &&
                                            securityAnswerController
                                                .text
                                                .isNotEmpty &&
                                            !isLoadingQuestion)
                                        ? LinearGradient(
                                          colors: [
                                            Warna.backgroundIjo,
                                            Warna().darken(
                                              Warna.backgroundIjo,
                                              0.1,
                                            ),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                        : null,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow:
                                    (emergencyQuestion != null &&
                                            securityAnswerController
                                                .text
                                                .isNotEmpty &&
                                            !isLoadingQuestion)
                                        ? [
                                          BoxShadow(
                                            color: Warna.backgroundIjo
                                                .withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                        : null,
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    (emergencyQuestion == null ||
                                            isLoadingQuestion ||
                                            securityAnswerController
                                                .text
                                                .isEmpty ||
                                            isVerifying)
                                        ? null
                                        : () async {
                                          setStateDialog(() {
                                            isVerifying = true;
                                          });

                                          FocusScope.of(context).unfocus();

                                          if (securityAnswerController
                                              .text
                                              .isEmpty) {
                                            CustomSnackbar.show(
                                              "Masukkan jawaban keamanan Anda",
                                              warna: Colors.orange,
                                              tinggi: 100,
                                              icon: Icons.warning_amber_rounded,
                                            );
                                            setStateDialog(() {
                                              isVerifying = false;
                                            });
                                            return;
                                          }

                                          bool verified =
                                              await verifySecurityAnswer(
                                                oldPhoneController.text,
                                                securityAnswerController.text,
                                              );

                                          setStateDialog(() {
                                            isVerifying = false;
                                          });

                                          if (verified) {
                                            CustomSnackbar.show(
                                              "Verifikasi berhasil! 🎉",
                                              warna: Colors.green,
                                              tinggi: 80,
                                              icon: Icons.check_circle_outline,
                                            );
                                            Navigator.pop(context);
                                            _showNewPhoneDialog(context);
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    isVerifying
                                        ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.verified_user_outlined,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Verifikasi",
                                              style: TextStyle(
                                                fontFamily: "Mulish",
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    @override
    void dispose() {
      cancelToken?.cancel();
      debounceTimer?.cancel();
      oldPhoneController.dispose();
      securityAnswerController.dispose();
      super.dispose();
    }
  }

  void _showNewPhoneDialog(BuildContext context) {
    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 12,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ), // Batasi tinggi dialog
                padding: EdgeInsets.all(16), // Kurangi padding sedikit
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Warna.backgroundIjo.withOpacity(0.02),
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ), // Tambahkan padding untuk keyboard
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header dengan icon
                        Container(
                          padding: EdgeInsets.all(16), // Kurangi padding
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400.withOpacity(0.15),
                                Colors.blue.shade300.withOpacity(0.08),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.phone_iphone_rounded,
                            size: 40, // Kurangi ukuran ikon
                            color: Colors.blue.shade600,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Title dan subtitle
                        Text(
                          'Nomor Telepon Baru',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontSize: 22, // Kurangi ukuran font
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Masukkan nomor telepon baru yang akan digunakan untuk akun Anda',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 16),

                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.green.shade600,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nomor Lama:',
                                      style: TextStyle(
                                        fontFamily: "Mulish",
                                        fontSize: 11,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      oldPhoneController.text.isNotEmpty
                                          ? oldPhoneController.text
                                          : 'Tidak tersedia',
                                      style: TextStyle(
                                        fontFamily: "Mulish",
                                        fontSize: 13,
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

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
                            cursorColor: Warna.backgroundIjo,
                            controller: newPhoneController,
                            keyboardType: TextInputType.phone,
                            enabled: !isUpdating,
                            style: TextStyle(
                              fontFamily: "Mulish",
                              fontSize: 15, // Kurangi ukuran font
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Nomor Telepon Baru',
                              hintText: '08xxxxxxxxxx',
                              labelStyle: TextStyle(
                                fontFamily: "Mulish",
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                              hintStyle: TextStyle(
                                fontFamily: 'Mulish',
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Warna.backgroundIjo,
                                  width: 2,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.phone_android_outlined,
                                color: Colors.grey.shade500,
                              ),
                              suffixIcon:
                                  newPhoneController.text.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey.shade400,
                                        ),
                                        onPressed:
                                            isUpdating
                                                ? null
                                                : () {
                                                  newPhoneController.clear();
                                                  setStateDialog(() {});
                                                },
                                      )
                                      : null,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (value) {
                              setStateDialog(() {});
                            },
                          ),
                        ),
                        SizedBox(height: 16),

                        if (newPhoneController.text.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  _isValidPhoneNumber(newPhoneController.text)
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    _isValidPhoneNumber(newPhoneController.text)
                                        ? Colors.green.shade200
                                        : Colors.orange.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isValidPhoneNumber(newPhoneController.text)
                                      ? Icons.check_circle_outline
                                      : Icons.warning_amber_rounded,
                                  color:
                                      _isValidPhoneNumber(
                                            newPhoneController.text,
                                          )
                                          ? Colors.green.shade600
                                          : Colors.orange.shade600,
                                  size: 14,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isValidPhoneNumber(newPhoneController.text)
                                        ? 'Format nomor telepon valid'
                                        : 'Gunakan format: 08xxxxxxxxxx (10-13 digit)',
                                    style: TextStyle(
                                      fontFamily: "Mulish",
                                      fontSize: 11,
                                      color:
                                          _isValidPhoneNumber(
                                                newPhoneController.text,
                                              )
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 16),

                        // Warning message
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.amber.shade700,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Pastikan nomor telepon baru dapat menerima SMS untuk verifikasi di masa mendatang.',
                                  style: TextStyle(
                                    fontFamily: "Mulish",
                                    fontSize: 12,
                                    color: Colors.amber.shade800,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Tombol aksi
                        Row(
                          children: [
                            // Tombol Batal
                            Expanded(
                              child: Container(
                                height: 45, // Kurangi tinggi tombol
                                child: OutlinedButton(
                                  onPressed:
                                      isUpdating
                                          ? null
                                          : () {
                                            Navigator.pop(context);
                                          },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    'Batal',
                                    style: TextStyle(
                                      fontFamily: "Mulish",
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            // Tombol Update
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  gradient:
                                      (_isValidPhoneNumber(
                                                newPhoneController.text,
                                              ) &&
                                              newPhoneController
                                                  .text
                                                  .isNotEmpty &&
                                              !isUpdating)
                                          ? LinearGradient(
                                            colors: [
                                              Warna.backgroundIjo,
                                              Warna().darken(
                                                Warna.backgroundIjo,
                                                0.1,
                                              ),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                          : null,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow:
                                      (_isValidPhoneNumber(
                                                newPhoneController.text,
                                              ) &&
                                              newPhoneController
                                                  .text
                                                  .isNotEmpty &&
                                              !isUpdating)
                                          ? [
                                            BoxShadow(
                                              color: Warna.backgroundIjo
                                                  .withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ]
                                          : null,
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      (_isValidPhoneNumber(
                                                newPhoneController.text,
                                              ) &&
                                              newPhoneController
                                                  .text
                                                  .isNotEmpty &&
                                              !isUpdating)
                                          ? () async {
                                            setStateDialog(() {
                                              isUpdating = true;
                                            });

                                            FocusScope.of(context).unfocus();

                                            try {
                                              final controller = Provider.of<
                                                LupaPasswordController
                                              >(context, listen: false);

                                              await controller.gantiNomor(
                                                oldPhoneController.text,
                                                newPhoneController.text,
                                                securityAnswerController.text,
                                              );

                                              // Clear controllers
                                              oldPhoneController.clear();
                                              securityAnswerController.clear();
                                              newPhoneController.clear();

                                              CustomSnackbar.show(
                                                'Nomor telepon berhasil diperbarui! 🎉',
                                                tinggi: 100,
                                                warna: Warna.backgroundIjo,
                                                icon:
                                                    Icons.check_circle_outline,
                                              );

                                              Navigator.pop(context);
                                            } catch (e) {
                                              setStateDialog(() {
                                                isUpdating = false;
                                              });

                                              CustomSnackbar.show(
                                                'Gagal memperbarui nomor telepon. Coba lagi.',
                                                tinggi: 100,
                                                warna: Colors.red,
                                                icon: Icons.error_outline,
                                              );
                                            }
                                          }
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child:
                                      isUpdating
                                          ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.update_rounded,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                "Perbarui Nomor",
                                                style: TextStyle(
                                                  fontFamily: "Mulish",
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
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
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^0[0-9]{9,12}$').hasMatch(phone);
  }
}

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
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
      FocusScope.of(context).unfocus();
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
        'http://18.136.209.83:3123/send-otp',
        data: {'phoneNumber': formattedPhone, 'otpCode': otpCode},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        FocusScope.of(context).unfocus();
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
        FocusScope.of(context).unfocus();
        CustomSnackbar.show('Gagal mengirim OTP: ${response.statusMessage}');
      }
    } catch (e) {
      FocusScope.of(context).unfocus();
      CustomSnackbar.show('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_secondsRemaining.clamp(0, 300)) / 300.0;
    final String mm = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final String ss = (_secondsRemaining % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/logo/icon_ijo.png', height: 30),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Verifikasi OTP",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Masukkan 6 digit kode yang kami kirim ke nomor kamu.",
              style: TextStyle(fontFamily: "Mulish", color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.10)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 46,
                        child: TextField(
                          cursorColor: Colors.black,
                          controller: otpControllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: Colors.grey[50],
                            hintText: "•",
                            hintStyle: const TextStyle(
                              fontSize: 18,
                              color: Colors.black26,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Warna.backgroundIjo,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              FocusScope.of(context).nextFocus();
                            }
                            if (value.isEmpty && index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Warna.backgroundIjo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kode kadaluarsa dalam $mm:$ss",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: "Mulish",
                      color: Colors.black54,
                    ),
                  ),
                  TextButton(
                    onPressed: _canResend ? _resendOTP : null,
                    child: const Text(
                      "Kirim ulang kode",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        color: Warna.backgroundIjo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  final enteredOTP = otpControllers.map((c) => c.text).join();
                  if (enteredOTP == widget.verificationId) {
                    FocusScope.of(context).unfocus();
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
                    FocusScope.of(context).unfocus();
                    CustomSnackbar.show('OTP tidak cocok', warna: Colors.red);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 52),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontWeight: FontWeight.w800,
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

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;

  const ResetPasswordScreen({super.key, required this.phoneNumber});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool showPassword = false;
  bool showConfirm = false;
  bool isSubmitting = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => passwordController.text.length >= 6;
  bool get _hasUpper => RegExp(r'[A-Z]').hasMatch(passwordController.text);
  bool get _hasLower => RegExp(r'[a-z]').hasMatch(passwordController.text);
  bool get _hasDigit => RegExp(r'\d').hasMatch(passwordController.text);
  bool get _hasSymbol => RegExp(
    r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/\?~`\-]',
  ).hasMatch(passwordController.text);

  double get _strength {
    double s = 0;
    if (_hasMinLength) s += 0.25;
    if (_hasUpper && _hasLower) s += 0.25;
    if (_hasDigit) s += 0.25;
    if (_hasSymbol) s += 0.25;
    return s.clamp(0, 1);
  }

  Color get _strengthColor {
    if (_strength < 0.4) return Colors.redAccent;
    if (_strength < 0.6) return Colors.orange;
    if (_strength < 0.8) return Colors.lightGreen;
    return Colors.green;
  }

  String get _strengthLabel {
    if (_strength < 0.4) return 'Lemah';
    if (_strength < 0.6) return 'Sedang';
    if (_strength < 0.8) return 'Kuat';
    return 'Sangat kuat';
  }

  bool get _passwordsMatch =>
      confirmPasswordController.text.isNotEmpty &&
      confirmPasswordController.text == passwordController.text;

  bool get _canSubmit =>
      !_isEmpty(passwordController.text) &&
      !_isEmpty(confirmPasswordController.text) &&
      _passwordsMatch;

  bool _isEmpty(String s) => s.trim().isEmpty;

  Future<void> _submit(BuildContext context) async {
    if (!_canSubmit || isSubmitting) return;
    setState(() => isSubmitting = true);
    try {
      final controller = Provider.of<LupaPasswordController>(
        context,
        listen: false,
      );
      await controller.updatePassword(
        widget.phoneNumber,
        passwordController.text,
        confirmPasswordController.text,
      );
      FocusScope.of(context).unfocus();
      CustomSnackbar.show("Password Berhasil diganti");
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    } catch (_) {
      FocusScope.of(context).unfocus();
      CustomSnackbar.show('Gagal mengganti password', warna: Colors.red);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Widget _checkItem(bool ok, String text) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: ok ? Warna.backgroundIjo : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: 13.5,
              color: ok ? Colors.black87 : Colors.black45,
              fontWeight: ok ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[50],
      labelStyle: const TextStyle(
        fontFamily: "Mulish",
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black87, width: 1.6),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mm = _strengthLabel;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/logo/icon_ijo.png', height: 30),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Buat Password Baru",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Pastikan password kuat dan mudah diingat.",
              style: TextStyle(fontFamily: "Mulish", color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    onChanged: (_) => setState(() {}),
                    decoration: _decoration(
                      label: "Password baru",
                      hint: "*************",
                      icon: Icons.lock_rounded,
                      suffix: IconButton(
                        onPressed:
                            () => setState(() => showPassword = !showPassword),
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: _strength,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Kekuatan: $mm",
                    style: const TextStyle(
                      fontFamily: "Mulish",
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _checkItem(_hasMinLength, "Minimal 6 karakter"),
                  _checkItem(_hasUpper && _hasLower, "Ada huruf besar & kecil"),
                  _checkItem(_hasDigit, "Ada angka"),
                  _checkItem(_hasSymbol, "Ada simbol"),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !showConfirm,
                    onChanged: (_) => setState(() {}),
                    decoration: _decoration(
                      label: "Konfirmasi password",
                      hint: "*************",
                      icon: Icons.verified_user_rounded,
                      suffix: IconButton(
                        onPressed:
                            () => setState(() => showConfirm = !showConfirm),
                        icon: Icon(
                          showConfirm
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                  ),
                  if (!_isEmpty(confirmPasswordController.text))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            _passwordsMatch
                                ? Icons.check_circle
                                : Icons.error_outline_rounded,
                            size: 18,
                            color:
                                _passwordsMatch
                                    ? Warna.backgroundIjo
                                    : Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _passwordsMatch
                                ? "Password cocok"
                                : "Password tidak cocok",
                            style: TextStyle(
                              fontFamily: "Mulish",
                              color:
                                  _passwordsMatch
                                      ? Colors.black87
                                      : Colors.redAccent,
                              fontWeight:
                                  _passwordsMatch
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed:
                    _canSubmit && !isSubmitting ? () => _submit(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 52),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  shadowColor: Colors.transparent,
                ),
                child:
                    isSubmitting
                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          "Submit",
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w800,
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
