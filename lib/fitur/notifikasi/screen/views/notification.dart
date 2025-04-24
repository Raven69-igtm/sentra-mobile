import 'package:SENTRA/utils/color.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "title": "Laporan terkirim",
      "date": "18/05/2019",
      "message":
          "Laporan dengan ID RKN568274926251B7 telah berhasil dikirim. Kami akan segera meninjau dan memberikan tindak lanjut. Terima kasih atas partisipasi Anda!",
    },
    {
      "title": "Laporan diterima",
      "date": "18/05/2019",
      "message":
          "Laporan dengan ID RKN568274926251B7 telah diterima dan sedang dalam tahap verifikasi. Kami akan segera menghubungi Anda jika diperlukan.",
    },
    {
      "title": "Laporan terkirim",
      "date": "18/05/2019",
      "message":
          "Laporan dengan ID RKN568274926251B7 sedang dalam proses penanganan oleh pihak terkait. Kami akan menginformasikan perkembangan selanjutnya.",
    },
    {
      "title": "Laporan selesai",
      "date": "18/05/2019",
      "message":
          "Laporan dengan ID RKN568274926251B7 telah berhasil ditangani. Terima kasih atas partisipasi Anda dalam menciptakan lingkungan yang lebih baik!",
    },
    {
      "title": "Selamat datang di SENTRA",
      "date": "18/05/2019",
      "message":
          "Terima kasih telah bergabung dengan SENTRA! Kami siap membantu Anda dalam melaporkan dan menangani setiap permasalahan dengan cepat dan tepat.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromRGBO(82, 174, 119, 1),
                Warna.backgroundBiru,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo/Image.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              "SENTRA",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Spacer(),
            const Text(
              "Notification",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notifications[index]["title"]!,
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: index == 4 ? Colors.black : Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notifications[index]["date"]!,
                      style: const TextStyle(fontFamily: "Mulish",fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notifications[index]["message"]!,
                      style: const TextStyle(
                        fontFamily: "Mulish",
                        fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
