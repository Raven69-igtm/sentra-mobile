import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/chat/views/chat_screen.dart';
import 'package:sentra/features/chat/views/room_chat_screen.dart';
import 'package:sentra/features/dashboard/models/info_model.dart';
import 'package:sentra/features/dashboard/services/info_service.dart';
import 'package:sentra/features/report/views/widgets/graph_widget.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/core/constants/app_constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sentra/features/dashboard/views/widgets/tracking_report_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
        print('Fetched $data informasi items from API');
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
      backgroundColor: Colors.transparent, 
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false, 
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom:
                  MediaQuery.of(context).padding.bottom +
                  kBottomNavigationBarHeight +
                  40, // Extra padding
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content dashboard sama seperti sebelumnya...
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
                                    receiverId: AppConstants.ADMIN_ID,
                                    receiverName: AppConstants.ADMIN_NAME,
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
                              height: 220,
                              viewportFraction: 0.88,
                              padEnds: true,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: true,
                              enlargeStrategy: CenterPageEnlargeStrategy.height,
                              autoPlay: informasiList.length > 1,
                              autoPlayCurve: Curves.easeInOut,
                              autoPlayAnimationDuration: const Duration(
                                milliseconds: 800,
                              ),
                              autoPlayInterval: const Duration(seconds: 4),
                              onPageChanged:
                                  informasiList.length > 1
                                      ? (index, reason) {
                                        setState(() => myCurrentIndex = index);
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
                                                    BorderRadius.circular(16),
                                              ),
                                              insetPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 24,
                                                  ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        informasi.gambar != null
                                                            ? Image.network(
                                                              informasi.gambar!,
                                                              fit: BoxFit.cover,
                                                              width:
                                                                  double
                                                                      .infinity,
                                                              height: 200,
                                                              errorBuilder:
                                                                  (
                                                                    _,
                                                                    __,
                                                                    ___,
                                                                  ) => Image.asset(
                                                                    'assets/image/placeholder.png',
                                                                    height: 200,
                                                                    width:
                                                                        double
                                                                            .infinity,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                  ),
                                                            )
                                                            : Image.asset(
                                                              'assets/image/placeholder.png',
                                                              height: 200,
                                                              width:
                                                                  double
                                                                      .infinity,
                                                              fit: BoxFit.cover,
                                                            ),
                                                        Positioned(
                                                          bottom: 12,
                                                          right: 12,
                                                          child: Material(
                                                            color:
                                                                Colors.black54,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            child: IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .fullscreen,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              onPressed: () {
                                                                 showDialog(
                                                          context: context,
                                                          builder: (_) => Dialog(
                                                            backgroundColor: Colors.transparent,
                                                            child: GestureDetector(
                                                            onTap: () => Navigator.pop(context),
                                                            child: InteractiveViewer(
                                                              panEnabled: true,
                                                              minScale: 0.5,
                                                              maxScale: 4.0,
                                                              child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(12),
                                                              child: informasi.gambar != null
                                                                ? Image.network(
                                                                  informasi.gambar!,
                                                                  fit: BoxFit.contain,
                                                                  )
                                                                : Image.asset(
                                                                  'assets/image/placeholder.png',
                                                                  fit: BoxFit.contain,
                                                                  ),
                                                              ),
                                                            ),
                                                            ),
                                                          ),
                                                          );
                                                
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                            16,
                                                            14,
                                                            16,
                                                            8,
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
                                                                  fontFamily:
                                                                      'Mulish',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Warna
                                                                          .backgroundIjo,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                                child: const Text(
                                                                  'Informasi',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontFamily:
                                                                        'Mulish',
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              const Icon(
                                                                Icons
                                                                    .access_time_rounded,
                                                                size: 16,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                informasi
                                                                        .waktu ??
                                                                    'Waktu Tidak Tersedia',
                                                                style: const TextStyle(
                                                                  fontSize: 13,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              const Icon(
                                                                Icons
                                                                    .calendar_today,
                                                                size: 16,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                informasi
                                                                        .tanggal ??
                                                                    'Tanggal Tidak Tersedia',
                                                                style: const TextStyle(
                                                                  fontSize: 13,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 12,
                                                          ),
                                                          Text(
                                                            informasi
                                                                    .deskripsi ??
                                                                'Konten tidak tersedia',
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Mulish',
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
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
                                                                  color:
                                                                      Warna
                                                                          .backgroundIjoDark,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
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
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.06,
                                            ),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child:
                                          informasi.gambar != null
                                              ? Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: Image.network(
                                                      informasi.gambar!,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (
                                                        context,
                                                        child,
                                                        progress,
                                                      ) {
                                                        if (progress == null)
                                                          return child;
                                                        return Shimmer.fromColors(
                                                          baseColor:
                                                              Colors.grey[300]!,
                                                          highlightColor:
                                                              Colors.grey[100]!,
                                                          child: Container(
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder:
                                                          (
                                                            _,
                                                            __,
                                                            ___,
                                                          ) => Image.asset(
                                                            'assets/image/placeholder.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin:
                                                              Alignment
                                                                  .bottomCenter,
                                                          end:
                                                              Alignment
                                                                  .topCenter,
                                                          colors: [
                                                            Colors.black
                                                                .withOpacity(
                                                                  0.55,
                                                                ),
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Warna
                                                                      .backgroundIjo,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            child: const Text(
                                                              'Informasi',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontFamily:
                                                                    'Mulish',
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              informasi.judul ??
                                                                  'Judul Tidak Tersedia',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontFamily:
                                                                    'Mulish',
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                              : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.asset(
                                                  'assets/image/placeholder.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                    ),
                                  );
                                }).toList(),
                          ),
                      SizedBox(height: 5),
                      if (!isLoading && informasiList.isNotEmpty)
                       AnimatedSmoothIndicator(
                          activeIndex: myCurrentIndex,
                          count: informasiList.length,
                          effect: ExpandingDotsEffect(
                            dotHeight: 6,
                            dotWidth: 6,
                            expansionFactor: 3,
                            spacing: 8,
                            dotColor: Colors.grey.shade400,
                            activeDotColor: Warna.backgroundIjo,
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
