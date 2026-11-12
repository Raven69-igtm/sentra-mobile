import 'package:flutter/material.dart';
import '../controllers/pjsrk_report_event_controller.dart';
import '../models/pjsrk_report_event_model.dart';
import 'pjsrk_report_location_screen.dart';
import 'widgets/pjrsk_font_scope.dart';
import 'widgets/pjsrk_chip_grid.dart';
import 'widgets/pjsrk_colors.dart';
import 'widgets/pjsrk_form_label.dart';
import 'widgets/pjsrk_gradient_button.dart';
import 'widgets/pjsrk_info_box.dart';
import 'widgets/pjsrk_number_box.dart';
import 'widgets/pjsrk_report_app_bar.dart';
import 'widgets/pjsrk_segmented.dart';
import 'widgets/pjsrk_stepper.dart';

/// VIEW langkah 1 (Kejadian) pengaduan bencana di layanan PJSRK.
/// Hanya menampilkan UI & meneruskan aksi ke controller.
class PjsrkReportEventScreen extends StatefulWidget {
  const PjsrkReportEventScreen({super.key});

  @override
  State<PjsrkReportEventScreen> createState() =>
      _PjsrkReportEventScreenState();
}

class _PjsrkReportEventScreenState extends State<PjsrkReportEventScreen> {
  final _c = PjsrkReportEventController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

    void _lanjut() {
    final error = _c.validasi();
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            error,
            style: const TextStyle(fontFamily: 'Mulish'),
          ),
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }

    // Bawa data kejadian ke halaman Lokasi
    final PjsrkReportEventModel data = _c.buildModel();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PjsrkReportLocationScreen(event: data),
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
        // ListenableBuilder membangun ulang UI setiap controller.notifyListeners()
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
                      const PjsrkStepper(current: 1),
                      const SizedBox(height: 14),

                      const PjsrkLabel('Jenis bencana'),
                      PjsrkChipGrid(
                        options: PjsrkReportEventController.jenisOptions,
                        isSelected: (v) => v == _c.jenisBencana,
                        onTap: _c.pilihJenis,
                      ),
                      const SizedBox(height: 16),

                      Row(children: [
                        Expanded(
                          child: PjsrkField(
                            label: 'Tanggal kejadian',
                            child: PjsrkInfoBox(
                              icon: Icons.calendar_today_outlined,
                              text: _c.tanggalText,
                              active: true,
                              onTap: () => _c.pilihTanggal(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PjsrkField(
                            label: 'Jam',
                            child: PjsrkInfoBox(
                              icon: Icons.access_time,
                              text: _c.jamText,
                              onTap: () => _c.pilihJam(context),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),

                      const PjsrkLabel('Tingkat dampak'),
                      PjsrkSegmented(
                        options: PjsrkReportEventController.dampakOptions,
                        selected: _c.tingkatDampak,
                        onChanged: _c.pilihDampak,
                      ),
                      const SizedBox(height: 16),

                      Row(children: [
                        Expanded(
                          child: PjsrkField(
                            label: 'Jiwa terdampak',
                            child: PjsrkNumberBox(
                              icon: Icons.people_outline,
                              controller: _c.jiwaCtrl,
                              prefix: '±',
                              suffix: 'jiwa',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PjsrkField(
                            label: 'Rumah rusak',
                            child: PjsrkNumberBox(
                              icon: Icons.home_outlined,
                              controller: _c.rumahCtrl,
                              suffix: 'unit',
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),

                      const PjsrkLabel('Keterangan bencana'),
                      TextField(
                        controller: _c.keteranganCtrl,
                        maxLines: 4,
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Kronologi, kondisi terkini, wilayah terdampak…',
                          hintStyle: const TextStyle(
                            fontFamily: 'Mulish',
                            color: PjsrkColors.muted,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                          enabledBorder: pjsrkOutline(PjsrkColors.border, 16),
                          focusedBorder: pjsrkOutline(PjsrkColors.primary, 16),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const PjsrkLabel('Kebutuhan mendesak'),
                      PjsrkChipGrid(
                        options: PjsrkReportEventController.kebutuhanOptions,
                        isSelected: _c.kebutuhan.contains,
                        onTap: _c.toggleKebutuhan, // bisa pilih banyak
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Lanjut menempel di bawah
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                child: PjsrkGradientButton(text: 'Lanjut', onTap: _lanjut),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}