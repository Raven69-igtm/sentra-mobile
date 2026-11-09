import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/pjsrk_report_location_controller.dart';
import '../models/pjsrk_report_event_model.dart';
import 'pjsrk_report_send_screen.dart';
import 'widgets/pjrsk_font_scope.dart';
import 'widgets/pjsrk_colors.dart';
import 'widgets/pjsrk_form_label.dart';
import 'widgets/pjsrk_gradient_button.dart';
import 'widgets/pjsrk_map_preview.dart';
import 'widgets/pjsrk_notice_box.dart';
import 'widgets/pjsrk_photo_picker.dart';
import 'widgets/pjsrk_report_app_bar.dart';
import 'widgets/pjsrk_stepper.dart';
import 'widgets/pjsrk_text_box.dart';

/// VIEW langkah 2 (Lokasi) pengaduan bencana PJSRK.
class PjsrkReportLocationScreen extends StatefulWidget {
  /// Titipan data dari langkah 1 (Kejadian).
  final PjsrkReportEventModel event;

  const PjsrkReportLocationScreen({super.key, required this.event});

  @override
  State<PjsrkReportLocationScreen> createState() =>
      _PjsrkReportLocationScreenState();
}

class _PjsrkReportLocationScreenState extends State<PjsrkReportLocationScreen> {
  final _c = PjsrkReportLocationController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _snack(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(pesan, style: const TextStyle(fontFamily: 'Mulish')),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _lanjut() {
    final error = _c.validasi();
    if (error != null) {
      _snack(error);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PjsrkReportSendScreen(
              event: widget.event,
              location: _c.buildModel(),
            ),
      ),
    );
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
            builder:
                (context, _) => Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const PjsrkStepper(current: 2),
                            const SizedBox(height: 14),

                            const PjsrkLabel('Titik lokasi bencana'),
                            PjsrkMapPreview(
                              addressController: _c.alamatCtrl,
                              kelurahanController: _c.kelurahanCtrl,
                              kecamatanController: _c.kecamatanCtrl,
                              onLocationChanged: (lat, lng) {
                                _c.latitude = lat;
                                _c.longitude = lng;
                              },
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: PjsrkField(
                                    label: 'Kelurahan',
                                    child: PjsrkTextBox(
                                      controller: _c.kelurahanCtrl,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PjsrkField(
                                    label: 'Kecamatan',
                                    child: PjsrkTextBox(
                                      controller: _c.kecamatanCtrl,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            const PjsrkLabel('Patokan lokasi'),
                            PjsrkTextBox(
                              controller: _c.patokanCtrl,
                              hint: 'Dekat jembatan sungai, sebelah masjid',
                            ),
                            const SizedBox(height: 16),

                            const PjsrkLabel('Foto / video kejadian (maks 4)'),
                            PjsrkPhotoPicker(
                              items: _c.foto,
                              max: PjsrkReportLocationController.maksFoto,
                              onAdd: _c.tambahFoto,
                              onRemove: _c.hapusFoto,
                            ),
                            const SizedBox(height: 16),

                            const PjsrkLabel('Kontak yang bisa dihubungi'),
                            PjsrkTextBox(
                              controller: _c.kontakCtrl,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9 +\-]'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            const PjsrkNoticeBox(
                              icon: Icons.notifications_none_outlined,
                              text:
                                  'Laporan bencana diteruskan ke petugas jaga dan BPBD terkait.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                      child: PjsrkGradientButton(
                        text: 'Tinjau & Kirim',
                        onTap: _lanjut,
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
