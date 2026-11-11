import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentra/features/pjsrk/controllers/pjsrk_report_event_controller.dart';
import 'package:sentra/features/pjsrk/models/pjsrk_report_event_model.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_report_event_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_report_location_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_report_send_screen.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_chip_grid.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_gradient_button.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_info_box.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_number_box.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_segmented.dart';
import 'package:sentra/features/pjsrk/views/widgets/pjsrk_stepper.dart';

void main() {
  group('PjsrkReportEvent Model & Controller Tests', () {
    test('Controller initializes with default values from Figma design', () {
      final controller = PjsrkReportEventController();

      expect(controller.jenisBencana, 'Banjir');
      expect(controller.tingkatDampak, 'Sedang');
      expect(controller.kebutuhan, containsAll(['Evakuasi', 'Makanan']));
      expect(controller.jiwaCtrl.text, '40');
      expect(controller.rumahCtrl.text, '12');
      expect(controller.tanggalText, contains('2026'));
      expect(controller.jamText, '09.30 WIB');
    });

    test('Controller handles options update and validation', () {
      final controller = PjsrkReportEventController();

      // Pilih jenis
      controller.pilihJenis('Tanah longsor');
      expect(controller.jenisBencana, 'Tanah longsor');

      // Pilih dampak
      controller.pilihDampak('Berat');
      expect(controller.tingkatDampak, 'Berat');

      // Toggle kebutuhan
      controller.toggleKebutuhan('Makanan'); // remove
      expect(controller.kebutuhan.contains('Makanan'), isFalse);
      controller.toggleKebutuhan('Air bersih'); // add
      expect(controller.kebutuhan.contains('Air bersih'), isTrue);

      // Validasi gagal bila keterangan kosong
      expect(controller.validasi(), 'Isi keterangan bencana');

      // Isi keterangan
      controller.keteranganCtrl.text = 'Banjir bandang di desa setempat';
      expect(controller.validasi(), isNull);

      // Validasi model
      final PjsrkReportEventModel model = controller.buildModel();
      expect(model.jenisBencana, 'Tanah longsor');
      expect(model.tingkatDampak, 'Berat');
      expect(model.jiwaTerdampak, 40);
      expect(model.rumahRusak, 12);
      expect(model.keterangan, 'Banjir bandang di desa setempat');
      expect(model.kebutuhan, containsAll(['Evakuasi', 'Air bersih']));

      final map = model.toMap();
      expect(map['jenis_bencana'], 'Tanah longsor');
      expect(map['tingkat_dampak'], 'Berat');
      expect(map['jiwa_terdampak'], 40);
      expect(map['rumah_rusak'], 12);
      expect(map['keterangan'], 'Banjir bandang di desa setempat');
    });
  });

  group('PjsrkReportEventScreen UI & Navigation Tests', () {
    testWidgets('Renders all Figma design elements correctly', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(home: PjsrkReportEventScreen()),
      );
      await tester.pumpAndSettle();

      // 1. Header
      expect(find.text('Pengaduan Bencana'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

      // 2. Stepper
      expect(find.byType(PjsrkStepper), findsOneWidget);
      expect(find.text('Kejadian'), findsOneWidget);
      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Kirim'), findsOneWidget);

      // 3. Chip Grid for Jenis Bencana & Kebutuhan Mendesak
      expect(find.byType(PjsrkChipGrid), findsNWidgets(2));
      expect(find.text('Banjir'), findsOneWidget);
      expect(find.text('Tanah longsor'), findsOneWidget);
      expect(find.text('Kebakaran'), findsOneWidget);
      expect(find.text('Angin kencang'), findsOneWidget);
      expect(find.text('Gempa bumi'), findsOneWidget);
      expect(find.text('Lainnya'), findsOneWidget);

      // 4. Date and Time boxes
      expect(find.byType(PjsrkInfoBox), findsNWidgets(2));
      expect(find.text('Tanggal kejadian'), findsOneWidget);
      expect(find.text('Jam'), findsOneWidget);

      // 5. Segmented Control for Tingkat Dampak
      expect(find.byType(PjsrkSegmented), findsOneWidget);
      expect(find.text('Ringan'), findsOneWidget);
      expect(find.text('Sedang'), findsOneWidget);
      expect(find.text('Berat'), findsOneWidget);

      // 6. Number boxes
      expect(find.byType(PjsrkNumberBox), findsNWidgets(2));
      expect(find.text('Jiwa terdampak'), findsOneWidget);
      expect(find.text('Rumah rusak'), findsOneWidget);

      // 7. Keterangan multiline
      expect(find.text('Keterangan bencana'), findsOneWidget);

      // 8. Kebutuhan mendesak
      expect(find.text('Kebutuhan mendesak'), findsOneWidget);
      expect(find.text('Evakuasi'), findsOneWidget);
      expect(find.text('Makanan'), findsOneWidget);
      expect(find.text('Air bersih'), findsOneWidget);
      expect(find.text('Obat-obatan'), findsOneWidget);
      expect(find.text('Selimut'), findsOneWidget);
      expect(find.text('Tenda'), findsOneWidget);

      // 9. Gradient Button
      expect(find.byType(PjsrkGradientButton), findsOneWidget);
      expect(find.text('Lanjut'), findsOneWidget);
    });

    testWidgets('Tapping Lanjut without keterangan shows error snackbar', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(home: PjsrkReportEventScreen()),
      );
      await tester.pumpAndSettle();

      // Tap Lanjut
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('Isi keterangan bencana'), findsOneWidget);
    });

    testWidgets(
      'Full 3-step flow: Kejadian -> Lokasi -> Kirim works seamlessly',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          const MaterialApp(home: PjsrkReportEventScreen()),
        );
        await tester.pumpAndSettle();

        // Step 1: Fill keterangan
        await tester.enterText(
          find.byType(TextField).at(2), // keterangan TextField
          'Banjir bandang menggenangi perumahan warga.',
        );
        await tester.pumpAndSettle();

        // Step 1: Tap Lanjut -> navigates to Step 2 (Lokasi)
        await tester.tap(find.text('Lanjut'));
        await tester.pumpAndSettle();

        // Verify Step 2 is active
        expect(find.byType(PjsrkReportLocationScreen), findsOneWidget);
        expect(find.text('Titik lokasi bencana'), findsOneWidget);
        expect(find.text('Tinjau & Kirim'), findsOneWidget);

        // Step 2: Tap Tinjau & Kirim -> navigates to Step 3 (Review & Kirim)
        await tester.tap(find.text('Tinjau & Kirim'));
        await tester.pumpAndSettle();

        // Verify Step 3 is active
        expect(find.byType(PjsrkReportSendScreen), findsOneWidget);
        expect(find.text('Periksa kembali laporan'), findsOneWidget);
        expect(find.text('Kirim laporan'), findsOneWidget);

        // Tap back button returns to Step 2
        final backBtn = find.byIcon(Icons.chevron_left_rounded).first;
        await tester.tap(backBtn);
        await tester.pumpAndSettle();

        expect(find.byType(PjsrkReportLocationScreen), findsOneWidget);
        expect(find.byType(PjsrkReportSendScreen), findsNothing);
      },
    );
  });
}
