import 'package:flutter/material.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';

class PjsrkHistoryScreen extends StatelessWidget {
  const PjsrkHistoryScreen({super.key});

  void _handleBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFD8782E);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBack(context),
        ),
        title: const Text(
          'Riwayat PJSRK',
          style: TextStyle(
            fontFamily: 'Mulish',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_rounded,
                size: 52,
                color: primaryOrange.withAlpha(150),
              ),
              const SizedBox(height: 16),
              const Text(
                'Riwayat laporan PJSRK akan ditampilkan di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF252525),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data riwayat belum tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 14,
                  color: Color(0xFF8D9299),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
