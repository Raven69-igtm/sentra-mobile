import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/theme/app_theme.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/report/views/report_screen.dart';
// Key messenger dipakai CustomSnackbar (sama dengan main.dart produksi).
import 'package:sentra/main.dart' as app show scaffoldMessengerKey;

/// Menggeser scroll terluar agar [target] berada di tengah viewport.
/// ensureVisible tidak cukup karena form memakai dua scroll bersarang.
Future<void> _scrollIntoView(WidgetTester tester, Finder target) async {
  final outerScrollable = find.byType(Scrollable).first;
  final position = tester.state<ScrollableState>(outerScrollable).position;
  final outerBox = tester.renderObject<RenderBox>(outerScrollable);
  final targetBox = tester.renderObject<RenderBox>(target);
  final dy = outerBox.globalToLocal(targetBox.localToGlobal(Offset.zero)).dy;
  final desired = position.pixels + dy - outerBox.size.height / 2;
  position.jumpTo(
    desired
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble(),
  );
  // pump (bukan pumpAndSettle) agar tidak menunggu animasi latar tanpa henti.
  await tester.pump();
}

Widget _harness(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ],
    child: MaterialApp(
      theme: buildSentraTheme(),
      scaffoldMessengerKey: app.scaffoldMessengerKey,
      home: child,
    ),
  );
}

void main() {
  testWidgets('LaporanPage default (tab Laporan) menampilkan judul formulir', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(const LaporanPage()));
    await tester.pumpAndSettle();

    expect(find.text('FORMULIR PENGADUAN'), findsOneWidget);
  });

  testWidgets(
    'Tahap 1 menampilkan kolom Hubungan dengan Korban di bawah Data Diri',
    (tester) async {
      await tester.pumpWidget(_harness(const LaporanPage()));
      await tester.pumpAndSettle();

      final Finder kolomHubungan = find.text('Hubungan dengan Korban');
      await tester.ensureVisible(kolomHubungan);
      await tester.pumpAndSettle();

      expect(kolomHubungan, findsOneWidget);
      expect(find.text('Pilih hubungan dengan korban'), findsOneWidget);
    },
  );

  testWidgets(
    'Validasi tahap 1 menahan lanjut saat NIK kosong dan menampilkan snackbar',
    (tester) async {
      await tester.pumpWidget(_harness(const LaporanPage()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Lanjut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pump(); // animasi snackbar mulai
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Mohon isi NIK'), findsOneWidget);
    },
  );

  testWidgets(
    'Tahap 1 menampilkan Penerima Manfaat dengan ringkasan identitas pelapor',
    (tester) async {
      await tester.pumpWidget(_harness(const LaporanPage()));
      await tester.pumpAndSettle();

      expect(find.text('Penerima Manfaat'), findsOneWidget);
      expect(find.text('Data penerima disalin dari pelapor'), findsOneWidget);
      expect(find.text('NIK Penerima Manfaat'), findsNothing);
    },
  );

  testWidgets('Switch penerima dimatikan menampilkan field penerima lengkap', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(const LaporanPage()));
    await tester.pumpAndSettle();

    final switchPenerima = find.byType(Switch).first;
    await _scrollIntoView(tester, switchPenerima);
    await tester.tap(switchPenerima);
    await tester.pumpAndSettle();

    expect(find.text('NIK Penerima Manfaat (Opsional)'), findsOneWidget);
    expect(find.text('Alamat Penerima Manfaat'), findsOneWidget);
    expect(find.text('Hubungan dengan Terlapor'), findsOneWidget);
    expect(find.text('No. Telepon Penerima'), findsOneWidget);
  });

  testWidgets('Terlapor dan Informasi Anak bersifat opsional dan bisa dibuka', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(const LaporanPage()));
    await tester.pumpAndSettle();

    expect(find.text('Terlapor (opsional)'), findsOneWidget);
    expect(find.text('Informasi Anak (opsional)'), findsOneWidget);

    final switches = find.byType(Switch);
    await tester.ensureVisible(switches.at(1));
    await tester.pumpAndSettle();
    await tester.tap(switches.at(1));
    await tester.pumpAndSettle();

    expect(find.text('Nama Terlapor'), findsOneWidget);
    expect(find.text('Informasi Tambahan'), findsOneWidget);
  });

  testWidgets('Informasi Anak bisa menambah dan menghapus anak', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(const LaporanPage()));
    await tester.pumpAndSettle();

    final switchAnak = find.byType(Switch).at(2);
    await tester.ensureVisible(switchAnak);
    await tester.pumpAndSettle();
    await tester.tap(switchAnak);
    await tester.pumpAndSettle();

    expect(find.text('Tambah Anak'), findsOneWidget);
    expect(find.text('Anak ke-1'), findsNothing);

    await tester.ensureVisible(find.text('Tambah Anak'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Anak'));
    await tester.pumpAndSettle();

    expect(find.text('Anak ke-1'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Hapus data anak'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hapus data anak'));
    await tester.pumpAndSettle();

    expect(find.text('Anak ke-1'), findsNothing);
  });

  testWidgets(
    'Pratinjau menampilkan penerima berbeda, terlapor, dan data anak',
    (tester) async {
      await tester.pumpWidget(_harness(const LaporanPage()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '3518000000000001');
      await tester.enterText(fields.at(1), 'Budi Santoso');
      await tester.enterText(fields.at(2), '081200000001');
      await tester.pumpAndSettle();

      final hubungan = find.byType(DropdownButtonFormField<String>);
      await _scrollIntoView(tester, hubungan);
      await tester.tap(hubungan);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pelapor / Korban').last);
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      await _scrollIntoView(tester, switches.at(0));
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();

      // Penerima manfaat berbeda dari pelapor.
      await tester.enterText(fields.at(4), '3518000000000099');
      await tester.enterText(fields.at(5), 'Siti Aminah');
      await tester.enterText(fields.at(12), '081200000099');
      await tester.pumpAndSettle();

      await _scrollIntoView(tester, switches.at(1));
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(15), 'Andi Wijaya');
      await tester.pumpAndSettle();

      await _scrollIntoView(tester, switches.at(2));
      await tester.tap(switches.at(2));
      await tester.pumpAndSettle();
      await _scrollIntoView(tester, find.text('Tambah Anak'));
      await tester.tap(find.text('Tambah Anak'));
      await tester.pumpAndSettle();
      await tester.enterText(fields.at(20), 'Citra Lestari');

      // Alamat diisi terakhir: pencarian saran alamat memunculkan snackbar
      // kegagalan jaringan pada lingkungan test, jadi tunggu sampai hilang.
      await tester.enterText(fields.at(3), 'Jl. Melati No. 1');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await _scrollIntoView(tester, find.text('Lanjut'));
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      await tester.enterText(fields.first, 'Terjadi kekerasan pada anak.');
      await tester.pumpAndSettle();
      await _scrollIntoView(tester, find.text('Lanjut'));
      await tester.tap(find.text('Lanjut'));
      // Tahap 3 memicu pencarian GPS; animasi loading latar bisa berjalan
      // terus di lingkungan test sehingga tidak memakai pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(fields.at(1), 'Desa Sukorejo, Nganjuk');
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));

      await _scrollIntoView(tester, find.text('Submit'));
      await tester.tap(find.text('Submit'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final dialog = find.byType(Dialog);
      expect(
        find.descendant(of: dialog, matching: find.text('Pratinjau Laporan')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: dialog,
          matching: find.text('Penerima manfaat sama dengan pelapor'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Penerima Manfaat')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Siti Aminah')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Terlapor')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Andi Wijaya')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Anak ke-1')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Citra Lestari')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('-')),
        findsNothing,
      );
    },
  );
}
