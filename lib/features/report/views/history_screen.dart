import 'dart:async';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/report/controllers/report_controller.dart';
import 'package:sentra/features/report/models/report_model.dart';
import 'package:sentra/features/report/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

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
    laporanController.getUserReports(userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: Obx(() {
        final List<LaporanModel> laporanList =
            selectedFilter.toLowerCase() == "all"
                ? laporanController.laporanList
                : laporanController.laporanByCategoryList;

        if (laporanController.isLoading.value || isLoading) {
          return _buildShimmerEffect();
        }

        return Column(
          children: [
            buildFilterTabs(),
            const SizedBox(height: 8),
            buildSearchField(),
            const SizedBox(height: 8),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: "Mulish",
                  ),
                ),
              ),
            if (errorMessage.isEmpty)
              Expanded(
                child:
                    laporanList.isEmpty
                        ? const Center(
                          child: Text(
                            "No reports available",
                            style: TextStyle(fontFamily: "Mulish"),
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: laporanList.length + 1,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            if (index == laporanList.length) {
                              final screenHeight =
                                  MediaQuery.of(context).size.height;
                              return SizedBox(height: screenHeight * 0.07);
                            }
                            return _buildReportTile(laporanList[index]);
                          },
                        ),
              ),
          ],
        );
      }),
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
            "Riwayat Laporan",
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
    final List<Map<String, String>> tabs = [
      {"label": "All", "value": "all"},
      {"label": "Dikirim", "value": "dikirim"},
      {"label": "Diterima", "value": "diterima"},
      {"label": "Diproses", "value": "diproses"},
      {"label": "Selesai", "value": "selesai"},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final String label = tabs[index]["label"]!;
          final String value = tabs[index]["value"]!;
          final bool isSelected = selectedFilter == value;
          return ChoiceChip(
            label: Text(
              label,
              style: TextStyle(
                fontFamily: "Mulish",
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Warna.font,
              ),
            ),
            checkmarkColor: Colors.white,
            selected: isSelected,
            selectedColor: Warna.backgroundIjo,
            backgroundColor: Colors.grey.shade100,
            onSelected: (_) => _onFilterSelected(value),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }

  void _onFilterSelected(String kategori) {
    setState(() {
      selectedFilter = kategori;
      errorMessage = '';
    });
    if (kategori == "all") {
      laporanController.getUserReports(userId!);
    } else {
      laporanController.getUserReportsByCategory(userId!, kategori);
    }
  }

  Widget buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Search by Name",
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      searchController.clear();
                      FocusScope.of(context).unfocus();
                      setState(() {
                        errorMessage = '';
                      });
                      laporanController.clearSearchResults();
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Warna.backgroundIjo, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          fillColor: Colors.white,
          filled: true,
        ),
        onChanged: (value) {
          setState(() {});
          if (_debounce?.isActive ?? false) _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () async {
            setState(() {
              isLoading = true;
              errorMessage = '';
            });
            final results = await _searchService.fetchSearchResults(
              value,
              userId,
            );
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
                laporanController.updateSearchResults(transformedResults);
              } catch (e) {
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

  Widget _buildReportTile(LaporanModel laporan) {
    final Color statusColor = _statusColor(laporan.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _showReportDetail(laporan),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "ID Report: ${laporan.id}",
                        style: const TextStyle(
                          fontFamily: "Mulish",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _StatusPill(text: laporan.status, color: statusColor),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Kategori: ${laporan.kategori}",
                        style: const TextStyle(
                          fontFamily: "Mulish",
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        laporan.deskripsi,
                        style: const TextStyle(
                          fontFamily: "Mulish",
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(laporan.createdAt),
                          style: const TextStyle(
                            fontFamily: "Mulish",
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReportDetail(LaporanModel laporan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return FutureBuilder<Map<String, dynamic>?>(
              future: laporanController.getReportDetailById(
                laporan.id.toString(),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState(scrollController);
                }

                if (snapshot.hasError) {
                  return _buildErrorState(
                    scrollController,
                    snapshot.error.toString(),
                  );
                }

                final Map<String, dynamic>? data = snapshot.data;

                print('API Response: $data');

                if (data == null) {
                  return _buildEmptyState(scrollController);
                }

                Map<String, dynamic>? laporanData;

                if (data['laporan'] != null &&
                    data['laporan'] is Map<String, dynamic>) {
                  laporanData = data['laporan'] as Map<String, dynamic>;
                }
                else if (data.containsKey('id_laporan') ||
                    data.containsKey('detail_pelapor') ||
                    data.containsKey('kategori') ||
                    data.containsKey('status')) {
                  laporanData = data;
                }

                if (laporanData == null || laporanData.isEmpty) {
                  print(
                    'No valid laporan data found. Available keys: ${data.keys}',
                  );
                  return _buildEmptyState(scrollController);
                }

                print('Using laporan data with keys: ${laporanData.keys}');
                return _buildReportDetail(scrollController, laporanData);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildDragHandle(),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              'Memuat detail laporan...',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ScrollController scrollController, String error) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildDragHandle(),
            const SizedBox(height: 40),
            Icon(Icons.error_outline, color: Colors.red[400], size: 48),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat detail laporan',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.close),
              label: const Text(
                'Tutup',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildDragHandle(),
            const SizedBox(height: 40),
            Icon(Icons.inbox_outlined, color: Colors.grey[400], size: 48),
            const SizedBox(height: 16),
            Text(
              'Detail laporan tidak tersedia',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildReportDetail(
    ScrollController scrollController,
    Map<String, dynamic> laporan,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 16),

          _buildHeader(laporan),
          const SizedBox(height: 24),

          _buildBasicInfoCard(laporan),
          const SizedBox(height: 20),

          ..._buildDataSections(laporan),

          const SizedBox(height: 24),
          _buildCloseButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildDataSections(Map<String, dynamic> laporan) {
    List<Widget> sections = [];

    // Pelapor Section
    if (laporan['detail_pelapor'] != null) {
      sections.addAll([
        _buildSectionCard(
          title: 'Detail Pelapor',
          icon: Icons.person_outline,
          iconColor: Colors.blue,
          data: laporan['detail_pelapor'],
          fields: [
            {'key': 'nama', 'label': 'Nama'},
            {'key': 'nik', 'label': 'NIK'},
            {'key': 'alamat', 'label': 'Alamat'},
            {
              'key': 'hubungan_dengan_korban',
              'label': 'Hubungan dengan Korban',
            },
            {'key': 'no_telp', 'label': 'No. Telepon'},
          ],
        ),
        const SizedBox(height: 16),
      ]);
    }

    // Terlapor Section
    if (laporan['detail_terlapor'] != null) {
      sections.addAll([
        _buildSectionCard(
          title: 'Detail Terlapor',
          icon: Icons.person_4_rounded,
          iconColor: Colors.orange,
          data: laporan['detail_terlapor'],
          fields: [
            {'key': 'nama', 'label': 'Nama'},
            {'key': 'nik', 'label': 'NIK'},
            {'key': 'umur', 'label': 'Umur'},
            {'key': 'jenis_kelamin', 'label': 'Jenis Kelamin'},
            {'key': 'alamat', 'label': 'Alamat'},
            {
              'key': 'hubungan_dengan_korban',
              'label': 'Hubungan dengan Korban',
            },
            {'key': 'informasi_tambahan', 'label': 'Informasi Tambahan'},
          ],
        ),
        const SizedBox(height: 16),
      ]);
    }

    // Penerima Manfaat Section
    if (laporan['detail_penerima_manfaat'] != null) {
      sections.addAll([
        _buildSectionCard(
          title: 'Detail Penerima Manfaat',
          icon: Icons.favorite_outline,
          iconColor: Colors.red,
          data: laporan['detail_penerima_manfaat'],
          fields: [
            {'key': 'nama', 'label': 'Nama'},
            {'key': 'nik', 'label': 'NIK'},
            {'key': 'tempat_lahir', 'label': 'Tempat Lahir'},
            {'key': 'tanggal_lahir', 'label': 'Tanggal Lahir'},
            {'key': 'umur', 'label': 'Umur'},
            {'key': 'jenis_kelamin', 'label': 'Jenis Kelamin'},
            {'key': 'pekerjaan', 'label': 'Pekerjaan'},
            {'key': 'agama', 'label': 'Agama'},
            {'key': 'alamat', 'label': 'Alamat'},
            {'key': 'pendidikan', 'label': 'Pendidikan'},
            {
              'key': 'hubungan_dengan_terlapor',
              'label': 'Hubungan dengan Terlapor',
            },
            {'key': 'notelp', 'label': 'No. Telepon'},
            {'key': 'informasi_tambahan', 'label': 'Informasi Tambahan'},
          ],
        ),
        const SizedBox(height: 16),
      ]);

      // Informasi Anak (nested in detail_penerima_manfaat)
      final detailPenerima = laporan['detail_penerima_manfaat'];
      if (detailPenerima is Map<String, dynamic> &&
          detailPenerima['informasi_anak'] != null &&
          detailPenerima['informasi_anak'].isNotEmpty) {
        final informasiAnak = detailPenerima['informasi_anak'];
        List<Widget> anakItems = [];

        // Cek apakah informasi_anak adalah List
        if (informasiAnak is List) {
          for (var i = 0; i < informasiAnak.length; i++) {
            anakItems.add(
              _buildAnakItem(
                data: informasiAnak[i],
                index: i,
                fields: [
                  {'key': 'nama', 'label': 'Nama'},
                  {'key': 'tanggal_lahir', 'label': 'Tanggal Lahir'},
                  {'key': 'umur', 'label': 'Umur'},
                  {'key': 'jenis_kelamin', 'label': 'Jenis Kelamin'},
                  {'key': 'pendidikan', 'label': 'Pendidikan'},
                  {'key': 'agama', 'label': 'Agama'},
                  {'key': 'status', 'label': 'Status'},
                ],
              ),
            );
          }
        } else if (informasiAnak is Map<String, dynamic>) {
          // Jika hanya satu anak
          anakItems.add(
            _buildAnakItem(
              data: informasiAnak,
              index: 0,
              fields: [
                {'key': 'nama', 'label': 'Nama'},
                {'key': 'tanggal_lahir', 'label': 'Tanggal Lahir'},
                {'key': 'umur', 'label': 'Umur'},
                {'key': 'jenis_kelamin', 'label': 'Jenis Kelamin'},
                {'key': 'pendidikan', 'label': 'Pendidikan'},
                {'key': 'agama', 'label': 'Agama'},
                {'key': 'status', 'label': 'Status'},
              ],
            ),
          );
        }

        // Tambahkan kartu Informasi Anak dengan item-item anak
        sections.addAll([
          _buildSectionAnakCard(
            title: 'Informasi Anak',
            icon: Icons.child_care,
            iconColor: Colors.purple,
            children: anakItems,
          ),
          const SizedBox(height: 16),
        ]);
      } else {
        // Fallback jika tidak ada data anak
        sections.addAll([
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Tidak ada informasi anak tersedia',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ]);
      }
    }

    // Detail Kasus Section
    if (laporan['detail_kasus'] != null) {
      sections.addAll([
        _buildSectionCard(
          title: 'Detail Kasus',
          icon: Icons.gavel_outlined,
          iconColor: Colors.teal,
          data: laporan['detail_kasus'],
          fields: [
            {'key': 'tanggal', 'label': 'Tanggal Kejadian'},
            {'key': 'tempat_kejadian', 'label': 'Tempat Kejadian'},
            {'key': 'kronologi', 'label': 'Kronologi', 'multiline': 'true'},
          ],
        ),
      ]);
    }

    return sections;
  }
  Widget _buildSectionAnakCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    Map<String, dynamic>? data,
    List<Map<String, String>>? fields,
    List<Widget>? children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withOpacity(0.1),
                      iconColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child:
                    children != null && children.isNotEmpty
                        ? Column(
                          children:
                              children
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => Column(
                                      children: [
                                        entry.value,
                                        if (entry.key < children.length - 1)
                                          const Divider(
                                            height: 24,
                                            thickness: 1,
                                          ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        )
                        : data != null && fields != null
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              fields.map((field) {
                                final key = field['key']!;
                                final label = field['label']!;
                                final isMultiline =
                                    field['multiline'] == 'true';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontFamily: 'Mulish',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          data[key]?.toString() ?? '-',
                                          style: TextStyle(
                                            fontFamily: 'Mulish',
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: isMultiline ? 1.5 : null,
                                          ),
                                          maxLines: isMultiline ? null : 1,
                                          overflow:
                                              isMultiline
                                                  ? null
                                                  : TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        )
                        : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnakItem({
    required Map<String, dynamic> data,
    required int index,
    required List<Map<String, String>> fields,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul item anak
          Text(
            'Anak ${index + 1}',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Detail anak
          ...fields.map((field) {
            final key = field['key']!;
            final label = field['label']!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      data[key]?.toString() ?? '-',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> laporan) {
    final String status = laporan['status']?.toString() ?? '-';
    final String kategori = laporan['kategori']?.toString() ?? '-';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Laporan',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                kategori,
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildStatusPill(status),
      ],
    );
  }

  Widget _buildStatusPill(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'dikirim':
        backgroundColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        break;
      case 'diproses':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        break;
      case 'selesai':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Mulish',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(Map<String, dynamic> laporan) {
    final String idLaporan = laporan['id_laporan']?.toString() ?? '-';
    final String kategori = laporan['kategori']?.toString() ?? '-';
    final String createdAt = laporan['created_at']?.toString() ?? '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow('ID Laporan', idLaporan, Icons.tag),
          const Divider(height: 20),
          _buildInfoRow('Kategori', kategori, Icons.category_outlined),
          const Divider(height: 20),
          _buildInfoRow(
            'Waktu Dibuat',
            _formatDateTime(createdAt),
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Map<String, dynamic>? data,
    required List<Map<String, String>> fields,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),

          // Section Content
          if (data != null && data.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children:
                    fields.map((field) {
                      final value = data[field['key']]?.toString();
                      if (value == null || value.isEmpty || value == 'null') {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildDetailRow(
                          field['label']!,
                          value,
                          multiline: field['multiline'] == 'true',
                        ),
                      );
                    }).toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Tidak ada data tersedia',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool multiline = false}) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
            maxLines: multiline ? null : 2,
            overflow: multiline ? null : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text(
          'Tutup',
          style: TextStyle(
            fontFamily: 'Mulish',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];

      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "diproses":
        return Colors.orange;
      case "dikirim":
        return Colors.blue;
      case "diterima":
        return Colors.purple;
      case "selesai":
        return Colors.green;
      default:
        return Colors.red;
    }
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
            itemCount: 5,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 140,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 100,
                            height: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120,
                                height: 14,
                                color: Colors.white,
                              ),
                              Container(
                                width: 60,
                                height: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
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

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text[0].toUpperCase() + text.substring(1),
        style: TextStyle(
          fontFamily: 'Mulish',
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}
