import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/report/views/report_screen.dart';
// Key messenger dipakai CustomSnackbar (sama dengan main.dart produksi).
import 'package:sentra/main.dart' as app show scaffoldMessengerKey;

Widget _harness(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ],
    child: MaterialApp(
      scaffoldMessengerKey: app.scaffoldMessengerKey,
      home: child,
    ),
  );
}

void main() {
  testWidgets(
      'LaporanPage default (tab Laporan) mempertahankan perilaku: '
      'tanpa tombol back AppBar', (tester) async {
    await tester.pumpWidget(_harness(const LaporanPage()));
    await tester.pumpAndSettle();

    expect(find.text('FORMULIR PENGADUAN'), findsOneWidget);
    // Tanpa tombol back karena automaticallyImplyLeading false + bukan dari PPPA.
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets(
      'LaporanPage(openedFromPpa: true) menampilkan tombol Back di AppBar',
      (tester) async {
    await tester.pumpWidget(_harness(const LaporanPage(openedFromPpa: true)));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets(
      'Tahap 1 menampilkan dropdown kategori, hubungan, dan section data korban',
      (tester) async {
    await tester.pumpWidget(_harness(const LaporanPage()));
    await tester.pumpAndSettle();

    expect(find.text('Kategori Pengaduan'), findsOneWidget);
    expect(find.text('Hubungan Anda dengan Korban'), findsOneWidget);
    expect(find.text('Data Korban'), findsOneWidget);
    expect(find.text('Nama Korban'), findsOneWidget);
    expect(find.text('Jenis Kelamin Korban'), findsOneWidget);
    expect(find.text('Agama Korban'), findsOneWidget);
    expect(find.text('Pendidikan Terakhir Korban'), findsOneWidget);
  });

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
  });

  testWidgets(
      'Dropdown hubungan "Pelapor / Korban" mengisi data korban otomatis '
      'dari data diri pelapor yang diisi pengguna', (tester) async {
    await tester.pumpWidget(_harness(const LaporanPage()));
    await tester.pumpAndSettle();

    // Urutan TextField tahap 1: 0 NIK pelapor, 1 Nama, 2 Telepon.
    await tester.enterText(find.byType(TextField).at(0), '3501234567891122');
    await tester.enterText(find.byType(TextField).at(1), 'Uji Nama Pelapor');
    await tester.enterText(find.byType(TextField).at(2), '081234567890');
    await tester.pumpAndSettle();

    // Urutan Dropdown tahap 1: 0 Kategori, 1 Hubungan dengan Korban,
    // 2 Jenis Kelamin, 3 Agama, 4 Pendidikan.
    final Finder dropdownHubungan =
        find.byType(DropdownButtonFormField<String>).at(1);
    await tester.ensureVisible(dropdownHubungan);
    await tester.pumpAndSettle();
    await tester.tap(dropdownHubungan);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pelapor / Korban').last);
    await tester.pumpAndSettle();

    // Verifikasi via isi controller seluruh TextField di layar.
    final List<String> isiSemuaField = find
        .byType(TextField)
        .evaluate()
        .map((element) {
          final TextField field = element.widget as TextField;
          return field.controller?.text ?? '';
        })
        .toList();

    // Nilai pelapor muncul 2x: sekali di field pelapor, sekali di field korban.
    expect(
      isiSemuaField.where((t) => t == '3501234567891122').length,
      2,
    );
    expect(
      isiSemuaField.where((t) => t == 'Uji Nama Pelapor').length,
      2,
    );
    expect(
      isiSemuaField.where((t) => t == '081234567890').length,
      2,
    );
  });
}
