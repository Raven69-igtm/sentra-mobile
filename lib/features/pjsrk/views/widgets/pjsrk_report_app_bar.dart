import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Bar oranye "Pengaduan Bencana" dengan tombol kembali.
class PjsrkReportAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PjsrkReportAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        backgroundColor: PjsrkColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Pengaduan Bencana',
            style: TextStyle(
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.maybePop(context),
              child: const Icon(Icons.chevron_left_rounded, size: 28),
            ),
          ),
        ),
      );
}