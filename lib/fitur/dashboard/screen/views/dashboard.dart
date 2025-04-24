import 'package:SENTRA/fitur/chat/screen/views/chat.dart';
import 'package:SENTRA/fitur/laporan/screen/widget/graph.dart';
import 'package:SENTRA/utils/color.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:SENTRA/widget/maps.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import '../utils/navbar.dart';
import '../widget/trackinglaporan.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 2;
  int myCurrentIndex = 0;
  final myitems = [
    Image.asset('images/image01.png'),
    Image.asset('images/image02.png'),
    Image.asset('images/image03.png'),
    Image.asset('images/image04.png'),
    Image.asset('images/image05.png'),
    Image.asset('images/image06.png'),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/logo/icon_ijo.png",
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    IconButton(
                      icon: Icon(Icons.chat, color: Warna.font),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatKonsultasiScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny, size: 16, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(
                      "TUES 11 JUL",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const Text(
                  "Overview",
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),
                const Text(
                  "Tracking Laporan",
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 5),
                TrackingLaporan(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        "Statistik Laporan Kekerasan\nNganjuk",
                        style: const TextStyle(
                          fontFamily: "Mulish",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      LineChartScreen(),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        textAlign: TextAlign.left,
                        "Informasi",
                        style: const TextStyle(
                          fontFamily: "Mulish",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10,),
                      CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: false,
                          height: 200,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 800,
                          ),
                          autoPlayInterval: const Duration(seconds: 2),
                          enlargeCenterPage: true,
                          aspectRatio: 2.0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              myCurrentIndex = index;
                            });
                          },
                        ),
                        items: myitems,
                      ),
                      SizedBox(height: 5,),
                      AnimatedSmoothIndicator(
                        activeIndex: myCurrentIndex,
                        count: myitems.length,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 10,
                          dotColor: Colors.grey.shade400,
                          activeDotColor: Warna.backgroundIjo,
                          paintStyle: PaintingStyle.fill,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //   Widget _buildCard(String title, IconData icon) {
  //     return Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(icon, size: 28, color: Colors.green),
  //           const SizedBox(width: 12),
  //           Text(
  //             title,
  //             style: const TextStyle(
  //               fontFamily: "Mulish",
  //               fontSize: 16, fontWeight: FontWeight.bold),
  //           ),
  //         ],
  //       ),

  //     );
  //   }
}