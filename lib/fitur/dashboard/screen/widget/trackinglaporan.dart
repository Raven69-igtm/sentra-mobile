import 'package:SENTRA/utils/color.dart';
import 'package:SENTRA/fitur/dashboard/screen/widget/steppertracking.dart';
import 'package:flutter/material.dart';
import '../../../laporan/screen/widget/badge.dart';

class TrackingLaporan extends StatefulWidget {
  @override
  _TrackingLaporanState createState() => _TrackingLaporanState();
}

class _TrackingLaporanState extends State<TrackingLaporan> {
  String statusLaporan = "Diproses"; 

  void ubahStatus() {
    setState(() {
      if (statusLaporan == "Dikirim") {
        statusLaporan = "Diterima";
      } else if (statusLaporan == "Diterima") {
        statusLaporan = "Diproses";
      } else if (statusLaporan == "Diproses") {
        statusLaporan = "Selesai";
      } else {
        statusLaporan = "Dikirim"; 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                " Masukan ID unik Laporan",
                style: TextStyle(
                  fontFamily: 'Mulish',
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 250,
                height: 35, 
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search...",
                          hintStyle: TextStyle(fontFamily: 'Mulish',fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            borderSide:
                                BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    Container(
                      height: 35, 
                      width: 40, 
                      decoration: BoxDecoration(
                        color: Warna.backgroundIjo,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.white, size: 18),
                        onPressed: () {},
                        padding: EdgeInsets.zero,  
                        constraints:
                            BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),
              MiniStepperTracking(),
              SizedBox(height: 10),
            ],
          ),
        ),

      
        Positioned(
          right: 10, 
          top: 0,
          child: TrackingBadge(
            status: statusLaporan,
          ), 
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String label, Color color, bool isActive) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: color, 
              child:
                  isActive
                      ? CircleAvatar(
                        radius: 6,
                        backgroundColor:
                            Colors.green[50],
                      )
                      : null,
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontFamily: "Mulish",fontSize: 12)),
      ],
    );
  }
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
