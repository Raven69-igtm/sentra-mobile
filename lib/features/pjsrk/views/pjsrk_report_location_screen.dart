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

  void _pilihMedia() {
    if (_c.foto.length >= PjsrkReportLocationController.maksFoto) {
      _snack('Maksimal ${PjsrkReportLocationController.maksFoto} foto');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Unggah Foto Kejadian',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF252525),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pilih sumber foto bencana (maksimal 4 foto)',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12,
                    color: Color(0xFF8D9299),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFFD8782E),
                    ),
                  ),
                  title: const Text(
                    'Ambil Foto',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: const Text(
                    'Gunakan kamera untuk mengambil foto bencana',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 11,
                      color: Color(0xFF8D9299),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _c.ambilFoto();
                  },
                ),
                const SizedBox(height: 6),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF379AE6),
                    ),
                  ),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: const Text(
                    'Pilih foto dari galeri ponsel',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 11,
                      color: Color(0xFF8D9299),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _c.pilihDariGaleri();
                  },
                ),
              ],
            ),
          ),
        );
      },
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
                              onAdd: _pilihMedia,
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
