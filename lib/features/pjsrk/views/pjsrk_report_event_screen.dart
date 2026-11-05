import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/pjsrk_report_event_controller.dart';
import '../models/pjsrk_report_event_model.dart';
import 'widgets/pjsrk_chip_grid.dart';
import 'widgets/pjsrk_colors.dart';
import 'widgets/pjsrk_form_label.dart';
import 'widgets/pjsrk_gradient_button.dart';
import 'widgets/pjsrk_info_box.dart';
import 'widgets/pjsrk_number_box.dart';
import 'widgets/pjsrk_segmented.dart';
import 'widgets/pjsrk_stepper.dart';

/// VIEW langkah 1 (Kejadian) pengaduan bencana di layanan PJSRK.
/// Sesuai dengan desain Figma Pengaduan Bencana.
class PjsrkReportEventScreen extends StatefulWidget {
  const PjsrkReportEventScreen({super.key});

  @override
  State<PjsrkReportEventScreen> createState() => _PjsrkReportEventScreenState();
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
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFF2C3E50),
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ));
      return;
    }

    final PjsrkReportEventModel data = _c.buildModel();
    debugPrint('Data kejadian: ${data.toMap()}');

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Data kejadian pengaduan bencana tersimpan',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF2E7D32),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: PjsrkColors.bg,
        body: Column(
          children: [
            // Header atas warna oranye dengan tombol back
            _buildHeader(context),

            // Konten form scrollable dan responsif
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ListenableBuilder(
                    listenable: _c,
                    builder: (context, _) => Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const PjsrkStepper(current: 1),
                                const SizedBox(height: 18),

                                const PjsrkLabel('Jenis bencana'),
                                PjsrkChipGrid(
                                  options: PjsrkReportEventController.jenisOptions,
                                  isSelected: (v) => v == _c.jenisBencana,
                                  onTap: _c.pilihJenis,
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: PjsrkField(
                                        label: 'Tanggal kejadian',
                                        child: PjsrkInfoBox(
                                          icon: Icons.calendar_today_outlined,
                                          text: _c.tanggalText,
                                          active: _c.activeField == 'tanggal',
                                          onTap: () => _c.pilihTanggal(context),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: PjsrkField(
                                        label: 'Jam',
                                        child: PjsrkInfoBox(
                                          icon: Icons.access_time_rounded,
                                          text: _c.jamText,
                                          active: _c.activeField == 'jam',
                                          onTap: () => _c.pilihJam(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                const PjsrkLabel('Tingkat dampak'),
                                PjsrkSegmented(
                                  options: PjsrkReportEventController.dampakOptions,
                                  selected: _c.tingkatDampak,
                                  onChanged: _c.pilihDampak,
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: PjsrkField(
                                        label: 'Jiwa terdampak',
                                        child: PjsrkNumberBox(
                                          icon: Icons.people_outline_rounded,
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
                                  ],
                                ),
                                const SizedBox(height: 16),

                                const PjsrkLabel('Keterangan bencana'),
                                TextField(
                                  controller: _c.keteranganCtrl,
                                  maxLines: 4,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Mulish',
                                    color: Color(0xFF252525),
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Kronologi, kondisi terkini, wilayah terdampak...',
                                    hintStyle: const TextStyle(
                                      color: PjsrkColors.muted,
                                      fontSize: 14,
                                      fontFamily: 'Mulish',
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.all(16),
                                    enabledBorder: pjsrkOutline(PjsrkColors.border, 14),
                                    focusedBorder: pjsrkOutline(PjsrkColors.primary, 14),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                const PjsrkLabel('Kebutuhan mendesak'),
                                PjsrkChipGrid(
                                  options: PjsrkReportEventController.kebutuhanOptions,
                                  isSelected: _c.kebutuhan.contains,
                                  onTap: _c.toggleKebutuhan,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),

                        // Tombol Lanjut di bagian bawah
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                            child: PjsrkGradientButton(
                              text: 'Lanjut',
                              onTap: _lanjut,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header bagian atas dengan warna oranye hangat dan tombol back
  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: statusBarHeight + 8,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: PjsrkColors.primary,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.white.withAlpha(56),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                'Pengaduan Bencana',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
