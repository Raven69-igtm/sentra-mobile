import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/dashboard/views/beranda_screen.dart';
import 'package:sentra/features/pjsrk/views/permasalahan_sosial_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_report_event_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_riwayat.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_screen.dart';
import 'package:sentra/features/pjsrk/views/rehabilitasi_sosial_screen.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_bottom_nav.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_feature_card.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_info_card.dart';
import 'package:sentra/features/report/controllers/report_controller.dart';

Widget createTestWidget(Widget child) {
  final userProvider = UserProvider();
  userProvider.setUser(
    UserModel(
      id: 1,
      nama: 'Rafi',
      notelp: '081234567890',
      email: 'rafi@test.com',
      role: 'user',
      alamat: 'Nganjuk',
      jeniskelamin: 'Laki-laki',
    ),
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ChangeNotifierProvider<LaporanController>(
        create: (_) => LaporanController(),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('PJSRK Screen & Components Test', () {
    testWidgets('PjsrkScreen renders all key components properly', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(const PjsrkScreen()));
      await tester.pumpAndSettle();

      // 1. Header & Back button
      expect(find.text('PJSRK'), findsWidgets);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // 2. Info Card & Section Title
      expect(find.byType(PjsrkInfoCard), findsOneWidget);
      expect(find.text('Fitur PJSRK'), findsOneWidget);

      // 3. Feature Cards
      expect(find.byType(PjsrkFeatureCard), findsNWidgets(3));
      expect(find.text('Rehabilitasi Sosial'), findsOneWidget);
      expect(
        find.text('Form pengaduan tunawisma & anak terlantar'),
        findsOneWidget,
      );
      expect(find.text('Pengaduan Bencana'), findsOneWidget);
      expect(
        find.text(
          'Form pengaduan bencana lengkap dengan lokasi & keterangan kejadian',
        ),
        findsOneWidget,
      );
      expect(find.text('Permasalahan Sosial'), findsOneWidget);
      expect(
        find.text(
          'Form pengaduan permasalahan sosial di lingkungan masyarakat',
        ),
        findsOneWidget,
      );

      // 4. Bottom Navigation
      expect(find.byType(PjsrkBottomNav), findsOneWidget);
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Laporan'), findsOneWidget);
      expect(find.text('Riwayat'), findsOneWidget);
    });

    testWidgets('PJSRK Riwayat opens LaporanSayaScreen', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(const PjsrkScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Riwayat'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LaporanSayaScreen), findsOneWidget);
      expect(find.text('Riwayat Laporan PJSRK'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded).last);
      await tester.pumpAndSettle();
      expect(find.byType(PjsrkScreen), findsOneWidget);
    });

    testWidgets(
      'Tapping PJSRK feature cards navigates to corresponding forms',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1100));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(createTestWidget(const PjsrkScreen()));
        await tester.pumpAndSettle();

        // 1. Permasalahan Sosial -> PermasalahanSosialScreen
        await tester.ensureVisible(find.text('Permasalahan Sosial'));
        await tester.tap(find.text('Permasalahan Sosial'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.byType(PermasalahanSosialScreen), findsOneWidget);

        await tester.tap(
          find.descendant(
            of: find.byType(PermasalahanSosialScreen),
            matching: find.byTooltip('Kembali'),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.byType(PjsrkScreen), findsOneWidget);

        // 2. Pengaduan Bencana -> PjsrkReportEventScreen
        await tester.ensureVisible(find.text('Pengaduan Bencana'));
        await tester.tap(find.text('Pengaduan Bencana'));
        await tester.pumpAndSettle();
        expect(find.byType(PjsrkReportEventScreen), findsOneWidget);
        expect(find.text('Pengaduan Bencana'), findsOneWidget);
        expect(find.text('Kejadian'), findsOneWidget);
        expect(find.text('Lokasi'), findsOneWidget);
        expect(find.text('Kirim'), findsOneWidget);
        expect(find.text('Lanjut'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back_rounded).last);
        await tester.pumpAndSettle();
        expect(find.byType(PjsrkScreen), findsOneWidget);
        expect(find.byType(PjsrkReportEventScreen), findsNothing);

        // 3. Rehabilitasi Sosial -> RehabilitasiSosialFormScreen
        await tester.ensureVisible(find.text('Rehabilitasi Sosial'));
        await tester.tap(find.text('Rehabilitasi Sosial'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(RehabilitasiSosialFormScreen), findsOneWidget);
      },
    );

    testWidgets('Navigation from BerandaScreen to PjsrkScreen works', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(const BerandaScreen()));
      await tester.pumpAndSettle();

      final pjsrkCard = find.text('PJSRK');
      expect(pjsrkCard, findsOneWidget);

      await tester.tap(pjsrkCard);
      await tester.pumpAndSettle();

      expect(find.byType(PjsrkScreen), findsOneWidget);
      expect(find.text('Fitur PJSRK'), findsOneWidget);

      final backButton = find.byIcon(Icons.arrow_back_rounded).first;
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.byType(BerandaScreen), findsOneWidget);
      expect(find.byType(PjsrkScreen), findsNothing);
    });
  });
}
