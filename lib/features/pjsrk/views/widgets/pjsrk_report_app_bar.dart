import 'package:flutter/material.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'pjsrk_colors.dart';

/// Bar oranye "Pengaduan Bencana" dengan tombol kembali.
class PjsrkReportAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PjsrkReportAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: PjsrkColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    title: const Text(
      'Pengaduan Bencana',
      style: TextStyle(
        fontFamily: 'Mulish',
        fontWeight: FontWeight.w800,
        fontSize: 20,
      ),
    ),
    leading: IconButton(
      tooltip: 'Kembali',
      onPressed: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      icon: const Icon(Icons.arrow_back, color: Colors.white),
    ),
  );
}
