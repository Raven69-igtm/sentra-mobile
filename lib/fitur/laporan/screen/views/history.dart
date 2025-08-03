import 'dart:async';
import 'package:sentra/fitur/authentikasi/data/provider/userprovider.dart';
import 'package:sentra/fitur/laporan/data/controllers/laporancontroller.dart';
import 'package:sentra/fitur/laporan/data/models/laporanmodels.dart';
import 'package:sentra/fitur/laporan/service/searchservice.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentra/utils/color.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final LaporanController laporanController = Get.put(LaporanController());
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = "all";
  int? userId;
  final SearchService _searchService = SearchService();
  bool isLoading = false;
  Timer? _debounce;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserProvider>(context, listen: false).idAkun;
    print("ID Akun: $userId");
    laporanController.getUserReports(userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Stack(
        children: [
          Obx(() {
            final laporanList =
                selectedFilter.toLowerCase() == "all"
                    ? laporanController.laporanList
                    : laporanController.laporanByCategoryList;
            print(
              "Selected filter: $selectedFilter, List length: ${laporanList.length}",
            );
             if (laporanController.isLoading.value || isLoading) {
              return _buildShimmerEffect(); // Tambahkan shimmer effect saat loading
            }

            return Column(
              children: [
                buildFilterTabs(),
                const SizedBox(height: 8),
                buildSearchField(),
                const SizedBox(height: 8),
                errorMessage.isNotEmpty
                    ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: "Mulish",
                        ),
                      ),
                    )
                    : laporanList.isEmpty
                    ? const Center(
                      child: Text(
                        "No reports available",
                        style: TextStyle(fontFamily: "Mulish"),
                      ),
                    )
                    : Expanded(
                      child: ListView.builder(
                        itemCount: laporanList.length,
                        itemBuilder: (context, index) {
                          return buildReportCard(laporanList[index]);
                        },
                      ),
                    ),
              ],
            );
          }),
          // Obx(() {
          //   return laporanController.isLoading.value || isLoading
          //       ? Container(
          //         color: Colors.black.withOpacity(0.1),
          //         child: const Center(
          //           child: CircularProgressIndicator(color: Colors.grey),
          //         ),
          //       )
          //       : const SizedBox.shrink();
          // }),
        ],
      ),
    );
  }
  Widget _buildShimmerEffect() {
    return Column(
      children: [
        buildFilterTabs(),
        const SizedBox(height: 8),
        buildSearchField(),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: 5, // Jumlah placeholder shimmer
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(width: 150, height: 14, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 200, height: 14, color: Colors.white),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 100,
                              height: 14,
                              color: Colors.white,
                            ),
                            Container(
                              width: 120,
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Warna.backgroundIjo, Warna.backgroundBiru],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      title: Row(
        children: [
          Image.asset('assets/logo/Image.png', height: 30, width: 30),
          const SizedBox(width: 8),
          const Text(
            "SENTRA",
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Spacer(),
          const Text(
            "History Laporan",
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilterTabs() {
    final List<String> tabs = [
      "All",
      "Dikirim",
      "Diterima",
      "Diproses",
      "Selesai",
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            tabs.map((tab) {
              final bool isSelected = selectedFilter == tab.toLowerCase();
              return GestureDetector(
                onTap: () {
                  final kategori = tab.toLowerCase();
                  setState(() {
                    selectedFilter = kategori;
                    errorMessage = '';
                  });
                  print("Fetching reports for filter: $kategori");
                  if (kategori == "all") {
                    laporanController.getUserReports(userId!);
                  } else {
                    laporanController.getUserReportsByCategory(
                      userId!,
                      kategori,
                    );
                  }
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontFamily: "Mulish",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.green : Warna.font,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        height: 3,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search by Name",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          if (_debounce?.isActive ?? false) _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () async {
            setState(() {
              isLoading = true;
              errorMessage = '';
            });
            print(
              'Fetching search results for keyword: $value, userId: $userId',
            );
            final results = await _searchService.fetchSearchResults(
              value,
              userId,
            );
            print('Fetched results: $results');
            if (results != null && results.isNotEmpty) {
              try {
                final transformedResults =
                    results.map((json) {
                      final transformedJson = Map<String, dynamic>.from(json);
                      if (transformedJson['detail_penerima_manfaat'] is Map) {
                        transformedJson['detail_penerima_manfaat'] =
                            transformedJson['detail_penerima_manfaat']['nama']
                                ?.toString() ??
                            'N/A';
                      }
                      return LaporanModel.fromJson(transformedJson);
                    }).toList();
                print('Parsed results: $transformedResults');
                laporanController.updateSearchResults(transformedResults);
              } catch (e) {
                print('Error parsing search results: $e');
                setState(() {
                  errorMessage = 'Failed to process data: $e';
                });
              }
            } else {
              laporanController.clearSearchResults();
              setState(() {
                errorMessage =
                    value.isNotEmpty ? 'No results for "$value"' : '';
              });
            }
            setState(() {
              isLoading = false;
            });
          });
        },
      ),
    );
  }

  Widget buildReportCard(LaporanModel laporan) {
    Color statusColor = Colors.red;
    if (laporan.status == "diproses") {
      statusColor = Colors.orange;
    } else if (laporan.status == "dikirim") {
      statusColor = Colors.blue;
    } else if (laporan.status == "diterima") {
      statusColor = Colors.purple;
    } else if (laporan.status == "selesai") {
      statusColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ID Report: ${laporan.id}",
              style: const TextStyle(
                fontFamily: "Mulish",
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Kategori: ${laporan.kategori}",
              style: const TextStyle(fontFamily: "Mulish"),
            ),
            Text(
              "Korban: ${laporan.deskripsi}",
              style: const TextStyle(fontFamily: "Mulish"),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Status: ${laporan.status[0].toUpperCase()}${laporan.status.substring(1)}",
                  style: TextStyle(
                    fontFamily: "Mulish",
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(laporan.createdAt),
                  style: const TextStyle(
                    fontFamily: "Mulish",
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
