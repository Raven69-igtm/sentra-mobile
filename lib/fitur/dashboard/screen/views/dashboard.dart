import 'package:sentra/fitur/authentikasi/data/provider/userprovider.dart';
import 'package:sentra/fitur/chat/screen/views/chat.dart';
import 'package:sentra/fitur/chat/screen/views/roomchat.dart';
import 'package:sentra/fitur/dashboard/data/models/informasimodel.dart';
import 'package:sentra/fitur/dashboard/service/informasiservice.dart';
import 'package:sentra/fitur/laporan/screen/widget/graph.dart';
import 'package:sentra/utils/color.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widget/trackinglaporan.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 2;
  int myCurrentIndex = 0;
  List<Informasi> informasiList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInformasi();
  }

  Future<void> _fetchInformasi() async {
    try {
      final informasiService = InformasiService();
      final data = await informasiService.fetchInformasi();
      setState(() {
        print('Fetched ${data} informasi items from API');
        informasiList = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching informasi: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat informasi')));
    }
  }

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
    String? role = Provider.of<UserProvider>(context, listen: false).role;
    final String tanggal =
        DateFormat('EEE dd MMM').format(DateTime.now()).toUpperCase();
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
                        print(role);
                        if (role == 'user') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatKonsultasiScreen(
                                    receiverId: 2,
                                    receiverName: 'Admin Konsul',
                                  ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RoomChat()),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny, size: 16, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(
                      tanggal,
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
                      SizedBox(height: 10),
                      isLoading
                          ? Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )
                          : informasiList.isEmpty
                          ? Center(child: Text('Tidak ada informasi tersedia'))
                          : CarouselSlider(
                            options: CarouselOptions(
                              enableInfiniteScroll: false,
                              autoPlay: informasiList.length > 1,
                              height: 200,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              autoPlayAnimationDuration: const Duration(
                                milliseconds: 1000,
                              ),
                              autoPlayInterval: const Duration(seconds: 3),
                              enlargeCenterPage: true,
                              aspectRatio: 2.0,
                              onPageChanged:
                                  informasiList.length > 1
                                      ? (index, reason) {
                                        setState(() {
                                          myCurrentIndex = index;
                                        });
                                      }
                                      : null,
                            ),
                            items:
                                informasiList.map((informasi) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (_) => Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Gambar
                                                    ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                      child:
                                                          informasi.gambar !=
                                                                  null
                                                              ? Image.network(
                                                                informasi
                                                                    .gambar!,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                width:
                                                                    double
                                                                        .infinity,
                                                                height: 180,
                                                                errorBuilder: (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  return Image.asset(
                                                                    'assets/image/placeholder.png',
                                                                    width:
                                                                        double
                                                                            .infinity,
                                                                    height: 180,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                  );
                                                                },
                                                              )
                                                              : Image.asset(
                                                                'assets/image/placeholder.png',
                                                                width:
                                                                    double
                                                                        .infinity,
                                                                height: 180,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                              ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            16.0,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            informasi.judul ??
                                                                'Judul Tidak Tersedia',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 18,
                                                                  fontFamily: 'Mulish',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            informasi
                                                                    .deskripsi ??
                                                                'Konten tidak tersedia',
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontFamily: "Mulish",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Align(
                                                            alignment:
                                                                Alignment
                                                                    .centerRight,
                                                            child: TextButton(
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                      ),
                                                              child: const Text(
                                                                'Tutup',
                                                                style: TextStyle(
                                                                  fontFamily: "Mulish",
                                                                  color:
                                                                      Warna
                                                                          .backgroundIjoDark,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      );
                                    },

                                    child:
                                        informasi.gambar != null
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                informasi.gambar!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                loadingBuilder: (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      height: 200,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  print(
                                                    'Error loading image: ${informasi.gambar}, $error',
                                                  );
                                                  return Image.asset(
                                                    'assets/image/placeholder.png',
                                                  );
                                                },
                                              ),
                                            )
                                            : Image.asset(
                                              'assets/image/placeholder.png',
                                            ),
                                  );
                                }).toList(),
                          ),
                      SizedBox(height: 5),
                      if (!isLoading && informasiList.isNotEmpty)
                        AnimatedSmoothIndicator(
                          activeIndex: myCurrentIndex,
                          count: informasiList.length,
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
}
