import 'package:flutter/material.dart';
import 'package:sentra/fitur/notifikasi/data/controllers/notifcontroller.dart';
import 'package:sentra/utils/color.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationController _controller = NotificationController();
  final ScrollController _scrollController = ScrollController();

  Color _getTitleColor(String title) {
    switch (title) {
      case 'Laporan terkirim':
        return Colors.orange[600]!;
      case 'Laporan diterima':
        return Colors.blue[600]!;
      case 'Laporan dalam proses':
        return Colors.purple[600]!;
      case 'Laporan selesai':
        return Colors.green[600]!;
      default:
        return Colors.black;
    }
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

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
              colors: [Warna.backgroundIjo, Warna.backgroundBiru],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset('assets/logo/Image.png', height: 30, width: 30),
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
              "Notifikasi",
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _controller.notificationStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text('Gagal memuat notifikasi'),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isUnread = notif['is_read'] == false;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif['title'] ?? 'Notifikasi',
                              style: TextStyle(
                                fontWeight:
                                    isUnread
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color: _getTitleColor(notif['title']),
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        _formatDate(notif['date'] ?? ''),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        notif['message'] ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
