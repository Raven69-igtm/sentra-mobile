import 'package:sentra/fitur/laporan/data/controllers/laporancontroller.dart';
import 'package:sentra/utils/color.dart';
import 'package:sentra/fitur/dashboard/screen/widget/steppertracking.dart';
import 'package:sentra/utils/customsnackbar.dart';
import 'package:flutter/material.dart';
import '../../../laporan/screen/widget/badge.dart';
import 'package:get/get.dart';

class TrackingLaporan extends StatefulWidget {
  @override
  _TrackingLaporanState createState() => _TrackingLaporanState();
}

class _TrackingLaporanState extends State<TrackingLaporan> {
  final LaporanController laporanController = Get.put(LaporanController());
  final TextEditingController trackingCodeController = TextEditingController();
  String statusLaporan = "dikirim";

  Future<void> cariLaporan() async {
    String kode = trackingCodeController.text.trim();
    if (kode.isEmpty) return;

    await laporanController.trackingReport(kode);
    if (laporanController.trackingStatus.value.isNotEmpty) {
      print(laporanController.trackingStatus.value);
      if (laporanController.trackingStatus.value == "dirujuk") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  SizedBox(height: 16),
                  Icon(
                    Icons.forward_to_inbox_rounded, 
                    color: Warna.backgroundBiru,
                    size: 60, 
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Laporan telah dirujuk ke instansi terkait.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16,fontFamily: 'Mulish', fontWeight: FontWeight.bold, color: Colors.black87,),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Warna.backgroundIjoDark,
                  ),
                  child: const Text('OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Mulish',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          statusLaporan = laporanController.trackingStatus.value;
        });
      }
    } else if (laporanController.errorMessage.value.isNotEmpty) {
      CustomSnackbar.show("ID Laporan Tidak Ditemukan");
      if (Get.overlayContext != null) {
        Get.snackbar('Error', laporanController.errorMessage.value);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(laporanController.errorMessage.value)),
        );
      }
    }
    trackingCodeController.clear();
  }

  void ubahStatus() {
    setState(() {
      if (statusLaporan == "dikirim") {
        statusLaporan = "diterima";
      } else if (statusLaporan == "diterima") {
        statusLaporan = "diproses";
      } else if (statusLaporan == "diproses") {
        statusLaporan = "selesai";
      } else {
        statusLaporan = "dikirim";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (trackingCodeController.text.isEmpty) {
      statusLaporan = 'dikirim';
    }

    // Get screen size for responsive calculations
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = screenWidth * 0.03;
        final searchBarHeight = screenHeight * 0.04;
        final iconSize = screenWidth * 0.05;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "Masukan ID unik Laporan",
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          color: Colors.black87,
                          fontWeight: FontWeight.normal,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => TrackingBadge(
                      status: laporanController.trackingStatus.value,
                    ),
                  ),
                ],
              ),
              FractionallySizedBox(
                widthFactor: 0.7,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: trackingCodeController,
                        decoration: InputDecoration(
                          hintText: "Search...",
                          hintStyle: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: screenWidth * 0.05,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.005,
                            horizontal: screenWidth * 0.04,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    Container(
                      height: searchBarHeight,
                      width: searchBarHeight,
                      decoration: BoxDecoration(
                        color: Warna.backgroundIjo,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: iconSize,
                        ),
                        onPressed: cariLaporan,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Obx(
                () => MiniStepperTracking(
                  status: laporanController.trackingStatus.value,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildStatusIndicator(String label, Color color, bool isActive) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.maxWidth * 0.2;
      return Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: size,
                backgroundColor: color,
                child:
                    isActive
                        ? CircleAvatar(
                          radius: size * 0.6,
                          backgroundColor: Colors.green[50],
                        )
                        : null,
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: constraints.maxWidth * 0.15,
            ),
          ),
        ],
      );
    },
  );
}

class CustomBadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.75);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
