import 'package:dio/dio.dart';

Future<void> kirimOtpFonnte({
  required String nomorTujuan, 
  required String otp,
}) async {
  final dio = Dio();

  const apiKey = 'FONNTE_API_KEY_REMOVED'; 

  final data = {
    'target': nomorTujuan,
    'message': 'Kode OTP kamu adalah $otp',
    'countryCode': '62',
  };

  try {
    final response = await dio.post(
      'https://api.fonnte.com/send',
      data: FormData.fromMap(data),
      options: Options(
        headers: {
          'Authorization': apiKey,
        },
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    print('Response: ${response.data}');
  } catch (e) {
    print('Gagal kirim OTP: $e');
  }
}

