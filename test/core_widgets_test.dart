import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_theme.dart';
import 'package:sentra/core/widgets/sentra_bottom_nav.dart';
import 'package:sentra/core/widgets/sentra_button.dart';
import 'package:sentra/core/widgets/sentra_card.dart';
import 'package:sentra/core/widgets/sentra_empty_state.dart';
import 'package:sentra/core/widgets/sentra_status_badge.dart';
import 'package:sentra/core/widgets/sentra_text_field.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildSentraTheme(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('SentraButton', () {
    testWidgets('merender label dan memanggil onPressed saat aktif', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          SentraButton.primary(
            label: 'Kirim Laporan',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Kirim Laporan'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('menonaktifkan ketukan dan menampilkan spinner saat isLoading', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          SentraButton.primary(
            label: 'Mengirim...',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isFalse);
    });

    testWidgets('menonaktifkan tombol saat onPressed null', (tester) async {
      await tester.pumpWidget(
        _wrap(const SentraButton.outlined(label: 'Nonaktif', onPressed: null)),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);
    });
  });

  group('SentraBottomNav', () {
    testWidgets('merender 2 item default (Floating) dan memicu onTap', (
      tester,
    ) async {
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildSentraTheme(),
          home: Scaffold(
            extendBody: true,
            bottomNavigationBar: SentraBottomNav(
              currentIndex: selected,
              onTap: (i) => selected = i,
              floating: true,
            ),
          ),
        ),
      );

      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      expect(selected, 1);
    });
  });

  group('SentraStatusBadge', () {
    testWidgets('memetakan semua status utama dengan ikon dan teks', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: [
              SentraStatusBadge(status: 'Terkirim'),
              SentraStatusBadge(status: 'Diterima'),
              SentraStatusBadge(status: 'Diproses'),
              SentraStatusBadge(status: 'Selesai'),
              SentraStatusBadge(status: 'Ditolak'),
            ],
          ),
        ),
      );

      expect(find.text('Terkirim'), findsOneWidget);
      expect(find.text('Diterima'), findsOneWidget);
      expect(find.text('Diproses'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Ditolak'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });

  group('SentraTextField, SentraCard & SentraEmptyState', () {
    testWidgets('SentraTextField menampilkan label, hint, dan toggle obscure', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Padding(
            padding: EdgeInsets.all(16),
            child: SentraTextField(
              label: 'Kata Sandi',
              hintText: 'Masukkan kata sandi',
              obscureText: true,
            ),
          ),
        ),
      );

      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('SentraCard mendukung onTap dan SentraEmptyState merender aksi', (
      tester,
    ) async {
      var cardTapped = false;
      var retryTapped = false;
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              SentraCard(
                onTap: () => cardTapped = true,
                child: const Text('Isi Kartu'),
              ),
              SentraEmptyState.error(onAction: () => retryTapped = true),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Isi Kartu'));
      expect(cardTapped, isTrue);

      await tester.tap(find.text('Coba Lagi'));
      expect(retryTapped, isTrue);
      expect(AppColors.primary, const Color(0xFF1F5C42));
    });
  });
}
