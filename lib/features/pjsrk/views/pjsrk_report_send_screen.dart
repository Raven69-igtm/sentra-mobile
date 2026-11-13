import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import '../../../core/network/api_exception.dart';
import '../controllers/pjsrk_report_send_controller.dart';
import '../models/pjsrk_report_event_model.dart';
import '../models/pjsrk_report_location_model.dart';
import 'widgets/pjrsk_font_scope.dart';
import 'widgets/pjsrk_check_row.dart';
import 'widgets/pjsrk_colors.dart';
import 'widgets/pjsrk_form_label.dart';
import 'widgets/pjsrk_gradient_button.dart';
import 'widgets/pjsrk_notice_box.dart';
import 'widgets/pjsrk_report_app_bar.dart';
import 'widgets/pjsrk_stepper.dart';
import 'widgets/pjsrk_summary_card.dart';

/// VIEW langkah 3 (Kirim) pengaduan bencana PJSRK.
class PjsrkReportSendScreen extends StatefulWidget {
  final PjsrkReportEventModel event; // titipan kamar 1
  final PjsrkReportLocationModel location; // titipan kamar 2

  const PjsrkReportSendScreen({
    super.key,
    required this.event,
    required this.location,
  });

  @override
  State<PjsrkReportSendScreen> createState() => _PjsrkReportSendScreenState();
}

class _PjsrkReportSendScreenState extends State<PjsrkReportSendScreen> {
  late final PjsrkReportSendController _c = PjsrkReportSendController(
    event: widget.event,
    location: widget.location,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    if (_c.isLoading) return;

    final error = _c.validasi();
    if (error != null) {
      _snack(error);
      return;
    }

    // Kirim atas nama akun yang sedang login (kolom id_akun di API).
    final idAkun = Provider.of<UserProvider>(context, listen: false).idAkun;
    if (idAkun == null || idAkun <= 0) {
      _snack('Silakan login terlebih dahulu untuk mengirim laporan');
      return;
    }

    try {
      final nomor = await _c.kirim(idAkun: idAkun);
      if (!mounted) return;
      await _tampilSukses(nomor);
    } on ApiException catch (e) {
      if (!mounted) return;
      _snack(e.message, error: true);
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal mengirim laporan: $e', error: true);
    }
  }

  /// Snackbar ringkas untuk info maupun pesan gagal.
  void _snack(String pesan, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(pesan, style: const TextStyle(fontFamily: 'Mulish')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? Colors.red.shade700 : null,
        ),
      );
  }

  Future<void> _tampilSukses(String nomor) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PjsrkFontScope(
        child: Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: PjsrkColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    size: 36, color: PjsrkColors.primary),
              ),
              const SizedBox(height: 16),
              const Text('Laporan terkirim',
                  style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                'Petugas jaga dan BPBD terkait akan menindaklanjuti laporanmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    height: 1.4,
                    color: PjsrkColors.muted),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: PjsrkColors.graySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  const Text('Nomor laporan',
                      style: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 12,
                          color: PjsrkColors.muted)),
                  const SizedBox(height: 2),
                  Text(nomor,
                      style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
              const SizedBox(height: 20),
              PjsrkGradientButton(
                  text: 'Selesai', onTap: () => Navigator.pop(ctx)),
            ]),
          ),
        ),
      ),
    );

    if (!mounted) return;
    // Tutup 3 layar form (Kirim, Lokasi, Kejadian) -> kembali ke layar asal.
    int dipop = 0;
    Navigator.of(context).popUntil((_) => dipop++ >= 3);
  }

  @override
  Widget build(BuildContext context) {
    return PjsrkFontScope(
      child: Scaffold(
        backgroundColor: PjsrkColors.bg,
        appBar: const PjsrkReportAppBar(),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _c,
          builder: (context, _) => Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PjsrkStepper(current: 3),
                      const SizedBox(height: 14),

                      const PjsrkLabel('Periksa kembali laporan'),
                      PjsrkSummaryCard(
                        title: 'Kejadian',
                        rows: _c.ringkasanKejadian,
                        // Kembali 2 layar -> ke form Kejadian.
                        onEdit: () => Navigator.of(context)
                          ..pop()
                          ..pop(),
                      ),
                      const SizedBox(height: 12),
                      PjsrkSummaryCard(
                        title: 'Lokasi',
                        rows: _c.ringkasanLokasi,
                        // Kembali 1 layar -> ke form Lokasi.
                        onEdit: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 16),

                      const PjsrkNoticeBox(
                        icon: Icons.info_outline,
                        text:
                            'Laporan yang sudah dikirim tidak bisa diubah. Pastikan semua data sudah benar.',
                      ),
                      const SizedBox(height: 16),

                      PjsrkCheckRow(
                        value: _c.setuju,
                        onChanged: _c.toggleSetuju,
                        text:
                            'Saya menyatakan data di atas benar dan siap diteruskan ke petugas.',
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                child: PjsrkGradientButton(
                  text: 'Kirim laporan',
                  loading: _c.isLoading,
                  onTap: _kirim,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}