import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_typography.dart';
import 'package:sentra/core/widgets/sentra_curved_header.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';

/// Curved Header PJSRK "Pengaduan Bencana" (Opsi B — melengkung ke bawah).
class PjsrkReportAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PjsrkReportAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(92);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SentraCurvedHeader(
      gradient: AppColors.pjsrkHeaderGradient,
      backgroundAsset: 'assets/image/beranda/pjsrk.png',
      curveHeight: 24,
      padding: EdgeInsets.fromLTRB(8, top + 6, 8, 30),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
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
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          Text(
            'Pengaduan Bencana',
            style: AppTypography.title.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
