import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/dashboard/views/beranda_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_report_event_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_screen.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_bottom_nav.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_feature_card.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_info_card.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_report_card.dart';

Widget createTestWidget(Widget child) {
  final userProvider = UserProvider();
  userProvider.setUser(UserModel(
    id: 1,
    nama: 'Rafi',
    notelp: '081234567890',
    email: 'rafi@test.com',
    role: 'masyarakat',
    alamat: 'Nganjuk',
    jeniskelamin: 'Laki-laki',
  ));

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>.value(value: userProvider),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('PJSRK Screen & Components Test', () {
    testWidgets('PjsrkScreen renders all key components properly',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(const PjsrkScreen()));
      await tester.pumpAndSettle();

      // 1. Header & Back button
      expect(find.text('PJSRK'), findsNWidgets(2)); // in Header and in Info Card
      expect(find.byIcon(Icons.chevron_left_rounded), findsWidgets);

      // 2. Info Card
      expect(find.byType(PjsrkInfoCard), findsOneWidget);
      expect(
        find.text(
          'Pilih jenis laporan yang ingin Anda sampaikan. Petugas akan menindaklanjuti dalam 2 hari kerja.',
        ),
        findsOneWidget,
      );

      // 3. Section Title
      expect(find.text('Fitur PJSRK'), findsOneWidget);

      // 4. Feature Cards
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
        find.text('Form pengaduan permasalahan sosial di lingkungan masyarakat'),
        findsOneWidget,
      );

      // 5. Report Card
      expect(find.byType(PjsrkReportCard), findsOneWidget);
      expect(find.text('Lihat laporan saya'), findsOneWidget);
      expect(find.text('Pantau status semua pengaduan Anda'), findsOneWidget);

      // 6. Bottom Navigation
      expect(find.byType(PjsrkBottomNav), findsOneWidget);
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Laporan'), findsOneWidget);
      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('Tapping Pengaduan Bencana navigates to PjsrkReportEventScreen',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(const PjsrkScreen()));
      await tester.pumpAndSettle();

      // Tap Rehabilitasi Sosial shows development notice
      await tester.tap(find.text('Rehabilitasi Sosial'));
      await tester.pumpAndSettle();
      expect(
        find.text('Layanan Rehabilitasi Sosial sedang dalam pengembangan'),
        findsOneWidget,
      );

      // Tap Pengaduan Bencana navigates to PjsrkReportEventScreen
      await tester.tap(find.text('Pengaduan Bencana'));
      await tester.pumpAndSettle();
      expect(find.byType(PjsrkReportEventScreen), findsOneWidget);

      // Header title
      expect(find.text('Pengaduan Bencana'), findsOneWidget);

      // Stepper
      expect(find.text('Kejadian'), findsOneWidget);
      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Kirim'), findsOneWidget);

      // Labels and Chips
      expect(find.text('Jenis bencana'), findsOneWidget);
      expect(find.text('Banjir'), findsOneWidget);
      expect(find.text('Tanah longsor'), findsOneWidget);
      expect(find.text('Kebakaran'), findsOneWidget);
      expect(find.text('Angin kencang'), findsOneWidget);
      expect(find.text('Gempa bumi'), findsOneWidget);
      expect(find.text('Lainnya'), findsOneWidget);

      // Date and Time
      expect(find.text('Tanggal kejadian'), findsOneWidget);
      expect(find.text('Jam'), findsOneWidget);

      // Impact level
      expect(find.text('Tingkat dampak'), findsOneWidget);
      expect(find.text('Ringan'), findsOneWidget);
      expect(find.text('Sedang'), findsOneWidget);
      expect(find.text('Berat'), findsOneWidget);

      // Number boxes
      expect(find.text('Jiwa terdampak'), findsOneWidget);
      expect(find.text('Rumah rusak'), findsOneWidget);

      // Keterangan
      expect(find.text('Keterangan bencana'), findsOneWidget);

      // Kebutuhan mendesak
      expect(find.text('Kebutuhan mendesak'), findsOneWidget);
      expect(find.text('Evakuasi'), findsOneWidget);
      expect(find.text('Makanan'), findsOneWidget);
      expect(find.text('Air bersih'), findsOneWidget);

      // Button
      expect(find.text('Lanjut'), findsOneWidget);

      // Tap back button returns to PjsrkScreen
      final backButton = find.byIcon(Icons.chevron_left_rounded).first;
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.byType(PjsrkScreen), findsOneWidget);
      expect(find.byType(PjsrkReportEventScreen), findsNothing);
    });

    testWidgets('Navigation from BerandaScreen to PjsrkScreen works',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(const BerandaScreen()));
      await tester.pumpAndSettle();

      // Ensure PJSRK card exists in Beranda
      final pjsrkCard = find.text('PJSRK');
      expect(pjsrkCard, findsOneWidget);

      // Tap on the PJSRK card
      await tester.tap(pjsrkCard);
      await tester.pumpAndSettle();

      // Check that PjsrkScreen is now visible
      expect(find.byType(PjsrkScreen), findsOneWidget);
      expect(find.text('Fitur PJSRK'), findsOneWidget);

      // Tap back button
      final backButton = find.byIcon(Icons.chevron_left_rounded).first;
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Returned to BerandaScreen
      expect(find.byType(BerandaScreen), findsOneWidget);
      expect(find.byType(PjsrkScreen), findsNothing);
    });
  });
}
