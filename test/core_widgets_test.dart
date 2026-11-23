import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_theme.dart';
import 'package:sentra/core/widgets/sentra_bottom_nav.dart';
import 'package:sentra/core/widgets/sentra_button.dart';
import 'package:sentra/core/widgets/sentra_card.dart';
import 'package:sentra/core/widgets/sentra_empty_state.dart';
import 'package:sentra/core/widgets/sentra_status_badge.dart';
import 'package:sentra/core/widgets/sentra_text_field.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/dashboard/views/beranda_screen.dart';
import 'package:sentra/features/dashboard/views/widgets/stepper_tracking_widget.dart';
import 'package:sentra/features/notification/controllers/notif_badge_provider.dart';
import 'package:sentra/features/pjsrk/views/laporan_sukses_screen.dart';

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

  group('MiniStepperTracking', () {
    testWidgets('menampilkan tahap Dirujuk sebelum Selesai saat status dirujuk', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Padding(
            padding: EdgeInsets.all(16),
            child: MiniStepperTracking(status: 'dirujuk'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Dikirim'), findsOneWidget);
      expect(find.text('Diterima'), findsOneWidget);
      expect(find.text('Diproses'), findsOneWidget);
      expect(find.text('Dirujuk'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      // 3 langkah awal sudah selesai (check icon), Dirujuk aktif, Selesai belum selesai
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
    });

    testWidgets('menampilkan tahap Selesai saat status selesai', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Padding(
            padding: EdgeInsets.all(16),
            child: MiniStepperTracking(status: 'selesai'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Dirujuk'), findsNothing);
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
    });
  });

  group('LaporanSuksesScreen', () {
    testWidgets('merender tiket, badge layanan PJSRK, dan kedua tombol aksi', (
      tester,
    ) async {
      var lacakTapped = false;
      var berandaTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildSentraTheme(),
          home: LaporanSuksesScreen(
            nomorTiket: 'RKN20261123001',
            tanggalWaktu: DateTime(2026, 11, 23, 17, 30),
            judulLayanan: 'Rehabilitasi Sosial',
            pesanKonfirmasi: 'Petugas Dinsos akan memverifikasi laporan Anda.',
            onLacakLaporan: () => lacakTapped = true,
            onKembaliKeBeranda: () => berandaTapped = true,
          ),
        ),
      );

      expect(find.text('Laporan Terkirim'), findsOneWidget);
      expect(find.text('Rehabilitasi Sosial'), findsOneWidget);
      expect(find.text('RKN20261123001'), findsOneWidget);
      expect(find.text('23 Nov 2026 · 17:30 WIB'), findsOneWidget);
      expect(find.text('Lacak Laporan'), findsOneWidget);
      expect(find.text('Kembali ke Beranda'), findsOneWidget);

      await tester.ensureVisible(find.text('Lacak Laporan'));
      await tester.tap(find.text('Lacak Laporan'));
      expect(lacakTapped, isTrue);

      await tester.ensureVisible(find.text('Kembali ke Beranda'));
      await tester.tap(find.text('Kembali ke Beranda'));
      expect(berandaTapped, isTrue);
    });

    testWidgets('menyembunyikan tombol Lacak Laporan saat showLacakButton false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildSentraTheme(),
          home: const LaporanSuksesScreen(
            nomorTiket: 'RKN20261123002',
            showLacakButton: false,
          ),
        ),
      );

      expect(find.text('Lacak Laporan'), findsNothing);
      expect(find.text('Kembali ke Beranda'), findsOneWidget);
    });
  });

  group('BerandaScreen notification badge', () {
    testWidgets('menampilkan badge angka merah saat unread > 0 dan sembunyi saat 0', (
      tester,
    ) async {
      final badgeProvider = NotificationBadgeProvider();
      addTearDown(badgeProvider.dispose);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider.value(value: badgeProvider),
          ],
          child: MaterialApp(
            theme: buildSentraTheme(),
            home: const BerandaScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key('beranda_notif_badge')), findsNothing);

      badgeProvider.syncUnreadCount(5);
      await tester.pump();
      expect(find.byKey(const Key('beranda_notif_badge')), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      badgeProvider.syncUnreadCount(120);
      await tester.pump();
      expect(find.text('99+'), findsOneWidget);

      badgeProvider.syncUnreadCount(0);
      await tester.pump();
      expect(find.byKey(const Key('beranda_notif_badge')), findsNothing);
    });
  });
}
