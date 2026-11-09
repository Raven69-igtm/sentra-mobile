import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:image_picker/image_picker.dart';
import 'package:sentra/features/pjsrk/views/laporan_sukses_screen.dart';

/// Model item foto bukti yang mendukung file nyata dari kamera / galeri baik di Mobile maupun Web
class PhotoItem {
  final String id;
  final String? name;
  final File? file;
  final Uint8List? bytes;
  final String? path;
  final Color? placeholderColor;
  final IconData? icon;

  PhotoItem({
    required this.id,
    this.name,
    this.file,
    this.bytes,
    this.path,
    this.placeholderColor,
    this.icon,
  });
}

/// Model opsi lokasi untuk Dropdown
class LocationOption {
  final String label;
  final String address;
  final double latitude;
  final double longitude;

  const LocationOption({
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  LatLng get latLng => LatLng(latitude, longitude);
}

/// Halaman Form Pengaduan Permasalahan Sosial (PJSRK)
/// Dilengkapi Google Maps Real-Time, Dropdown Lokasi Interaktif, dan Pengambilan Foto dari Kamera / Galeri
class PermasalahanSosialScreen extends StatefulWidget {
  /// Callback fleksibel untuk menghubungkan ke halaman berikutnya sesuai ketentuan pengguna
  final void Function(Map<String, dynamic> reportData)? onNext;

  const PermasalahanSosialScreen({
    super.key,
    this.onNext,
  });

  @override
  State<PermasalahanSosialScreen> createState() =>
      _PermasalahanSosialScreenState();
}

class _PermasalahanSosialScreenState extends State<PermasalahanSosialScreen> {
  // Palet Warna Sesuai Desain Referensi Sentra
  static const Color _primaryOrange = Color(0xFFD8782E);
  static const Color _lightOrangeBg = Color(0xFFFFF2E6);
  static const Color _neutralDark = Color(0xFF252525);
  static const Color _neutralGrey = Color(0xFF6B7280);
  static const Color _borderGrey = Color(0xFFE5E7EB);
  static const Color _greenActive = Color(0xFF48A868);
  static const Color _pinRed = Color(0xFFE53935);

  // Daftar opsi jenis permasalahan
  final List<String> _jenisPermasalahanList = [
    'Pengemis & pengamen',
    'Lansia terlantar',
    'ODGJ terlantar',
    'Kekerasan dalam keluarga',
    'Penyandang disabilitas',
    'Lainnya',
  ];

  // Daftar 20 Kecamatan Lengkap di Kabupaten Nganjuk & Titik Utama
  final List<LocationOption> _locationOptions = const [
    LocationOption(
      label: 'Kec. Nganjuk (Kel. Pesantren - RT 05 / RW 02)',
      address: 'RT 05 / RW 02, Kel. Pesantren, Kec. Nganjuk',
      latitude: -7.6044,
      longitude: 111.9022,
    ),
    LocationOption(
      label: 'Kec. Bagor',
      address: 'Jl. Raya Madiun - Nganjuk, Kec. Bagor, Kab. Nganjuk',
      latitude: -7.5684,
      longitude: 111.8502,
    ),
    LocationOption(
      label: 'Kec. Baron',
      address: 'Jl. Raya Baron, Kec. Baron, Kab. Nganjuk',
      latitude: -7.6006,
      longitude: 112.0489,
    ),
    LocationOption(
      label: 'Kec. Berbek',
      address: 'Jl. Sunan Kalijaga, Kec. Berbek, Kab. Nganjuk',
      latitude: -7.6433,
      longitude: 111.8689,
    ),
    LocationOption(
      label: 'Kec. Gondang',
      address: 'Jl. Raya Gondang, Kec. Gondang, Kab. Nganjuk',
      latitude: -7.5256,
      longitude: 112.0089,
    ),
    LocationOption(
      label: 'Kec. Jatikalen',
      address: 'Jl. Raya Jatikalen, Kec. Jatikalen, Kab. Nganjuk',
      latitude: -7.4989,
      longitude: 112.1389,
    ),
    LocationOption(
      label: 'Kec. Kertosono',
      address: 'Jl. Supriyadi, Kec. Kertosono, Kab. Nganjuk',
      latitude: -7.5872,
      longitude: 112.0984,
    ),
    LocationOption(
      label: 'Kec. Lengkong',
      address: 'Jl. Raya Lengkong, Kec. Lengkong, Kab. Nganjuk',
      latitude: -7.4722,
      longitude: 112.0389,
    ),
    LocationOption(
      label: 'Kec. Loceret',
      address: 'Jl. Raya Kediri - Nganjuk, Kec. Loceret, Kab. Nganjuk',
      latitude: -7.6489,
      longitude: 111.9056,
    ),
    LocationOption(
      label: 'Kec. Nganjuk (Pusat Kota)',
      address: 'Jl. Basuki Rahmad, Mangundikaran, Kec. Nganjuk',
      latitude: -7.6015,
      longitude: 111.9011,
    ),
    LocationOption(
      label: 'Kec. Ngetos',
      address: 'Jl. Raya Ngetos, Kec. Ngetos, Kab. Nganjuk',
      latitude: -7.7122,
      longitude: 111.8389,
    ),
    LocationOption(
      label: 'Kec. Ngluyu',
      address: 'Jl. Raya Ngluyu, Kec. Ngluyu, Kab. Nganjuk',
      latitude: -7.4389,
      longitude: 111.9522,
    ),
    LocationOption(
      label: 'Kec. Ngronggot',
      address: 'Jl. Raya Ngronggot, Kec. Ngronggot, Kab. Nganjuk',
      latitude: -7.6722,
      longitude: 112.0489,
    ),
    LocationOption(
      label: 'Kec. Pace',
      address: 'Jl. Raya Pace, Kec. Pace, Kab. Nganjuk',
      latitude: -7.6789,
      longitude: 111.9689,
    ),
    LocationOption(
      label: 'Kec. Patianrowo',
      address: 'Jl. Raya Patianrowo, Kec. Patianrowo, Kab. Nganjuk',
      latitude: -7.5389,
      longitude: 112.0889,
    ),
    LocationOption(
      label: 'Kec. Prambon',
      address: 'Jl. Raya Prambon, Kec. Prambon, Kab. Nganjuk',
      latitude: -7.7189,
      longitude: 112.0289,
    ),
    LocationOption(
      label: 'Kec. Rejoso',
      address: 'Jl. Raya Rejoso, Kec. Rejoso, Kab. Nganjuk',
      latitude: -7.5022,
      longitude: 111.8889,
    ),
    LocationOption(
      label: 'Kec. Sawahan',
      address: 'Jl. Raya Sedudo, Kec. Sawahan, Kab. Nganjuk',
      latitude: -7.7422,
      longitude: 111.7889,
    ),
    LocationOption(
      label: 'Kec. Sukomoro',
      address: 'Jl. Raya Sukomoro, Kec. Sukomoro, Kab. Nganjuk',
      latitude: -7.5823,
      longitude: 111.9421,
    ),
    LocationOption(
      label: 'Kec. Tanjunganom',
      address: 'Jl. Panglima Sudirman, Kec. Tanjunganom, Kab. Nganjuk',
      latitude: -7.6189,
      longitude: 112.0078,
    ),
    LocationOption(
      label: 'Kec. Wilangan',
      address: 'Jl. Raya Wilangan, Kec. Wilangan, Kab. Nganjuk',
      latitude: -7.5622,
      longitude: 111.7889,
    ),
  ];

  // State Form
  String _selectedJenis = 'Pengemis & pengamen';
  late final TextEditingController _judulController;
  late final TextEditingController _uraianController;
  late final TextEditingController _lokasiController;
  bool _isAnonymous = true;

  // State Google Maps & Dropdown Lokasi
  final MapController _mapController = MapController();
  late LocationOption _selectedLocation;
  late LatLng _currentLatLng;
  bool _isLoadingGps = false;

  // State Foto Bukti (Maksimal 4 foto nyata dari kamera/galeri)
  final ImagePicker _imagePicker = ImagePicker();
  final List<PhotoItem> _photoList = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller kosong agar pengguna wajib mengisi form sendiri
    _judulController = TextEditingController();
    _uraianController = TextEditingController();

    // Inisialisasi lokasi awal
    _selectedLocation = _locationOptions.first;
    _currentLatLng = _selectedLocation.latLng;
    _lokasiController = TextEditingController(
      text: _selectedLocation.address,
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _uraianController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  /// Mengubah lokasi berdasarkan pilihan Dropdown
  void _onLocationDropdownChanged(LocationOption? newLocation) {
    if (newLocation == null) return;
    setState(() {
      _selectedLocation = newLocation;
      _currentLatLng = newLocation.latLng;
      _lokasiController.text = newLocation.address;
    });

    // Pindahkan kamera Google Maps secara halus ke koordinat lokasi yang dipilih
    _mapController.move(_currentLatLng, 16.0);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.place_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Peta diarahkan ke ${newLocation.label}',
                style: const TextStyle(fontFamily: 'Mulish', fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2C3E50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Saat pengguna mengetuk titik mana pun di peta untuk memilih lokasi kustom
  void _onMapTapped(TapPosition tapPosition, LatLng tappedPoint) {
    setState(() {
      _currentLatLng = tappedPoint;
      _lokasiController.text =
          'Titik Kustom (${tappedPoint.latitude.toStringAsFixed(4)}, ${tappedPoint.longitude.toStringAsFixed(4)})';
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pin diperbarui: Lat ${tappedPoint.latitude.toStringAsFixed(4)}, Long ${tappedPoint.longitude.toStringAsFixed(4)}',
          style: const TextStyle(fontFamily: 'Mulish', fontSize: 12),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  /// Aksi tombol "Lokasi saya" (mengambil GPS terkini)
  void _onGetMyLocation() {
    setState(() {
      _isLoadingGps = true;
    });

    // Simulasi deteksi GPS akurat & pembaruan peta
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final gpsLocation = _locationOptions.first; // Atau koordinat GPS aktif
      setState(() {
        _isLoadingGps = false;
        _selectedLocation = gpsLocation;
        _currentLatLng = gpsLocation.latLng;
        _lokasiController.text = gpsLocation.address;
      });

      _mapController.move(_currentLatLng, 16.5);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Lokasi GPS Anda berhasil ditemukan!',
                  style: TextStyle(fontFamily: 'Mulish', fontSize: 13),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  /// Dialog pemilihan sumber foto (Kamera atau Galeri)
  void _showImageSourcePicker() {
    if (_photoList.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal 4 foto bukti yang dapat diunggah'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ambil Foto Bukti',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _neutralDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilih dari kamera langsung atau pilih dari galeri perangkat Anda',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12.5,
                    color: _neutralGrey,
                  ),
                ),
                const SizedBox(height: 18),

                // Opsi 1: Kamera Langsung
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _lightOrangeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: _primaryOrange),
                  ),
                  title: const Text(
                    'Kamera',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: _neutralDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Ambil foto bukti langsung menggunakan kamera HP',
                    style: TextStyle(fontFamily: 'Mulish', fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const Divider(height: 16),

                // Opsi 2: Galeri Foto
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF2E7D32)),
                  ),
                  title: const Text(
                    'Galeri Foto',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: _neutralDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Pilih foto kejadian dari penyimpanan / galeri',
                    style: TextStyle(fontFamily: 'Mulish', fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Eksekusi pengambilan foto menggunakan ImagePicker (Kompatibel Mobile & Web)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (pickedFile != null) {
        // Baca data bytes agar kompatibel di semua platform termasuk Web
        final Uint8List bytes = await pickedFile.readAsBytes();

        setState(() {
          _photoList.add(
            PhotoItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: source == ImageSource.camera
                  ? 'Foto Kamera ${_photoList.length + 1}'
                  : 'Foto Galeri ${_photoList.length + 1}',
              file: kIsWeb ? null : File(pickedFile.path),
              bytes: bytes,
              path: pickedFile.path,
            ),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Foto berhasil diambil dari kamera!'
                  : 'Foto berhasil dipilih dari galeri!',
              style: const TextStyle(fontFamily: 'Mulish'),
            ),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Menghapus foto dari list
  void _onRemovePhoto(int index) {
    setState(() {
      _photoList.removeAt(index);
    });
  }

  /// Membuka dialog pratinjau foto penuh
  void _onPreviewPhoto(PhotoItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildImageWidget(item, fit: BoxFit.contain, height: 260),
              ),
              const SizedBox(height: 12),
              Text(
                item.name ?? 'Foto Bukti',
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Widget penampil gambar yang aman dan kompatibel di Mobile (Android/iOS) maupun Flutter Web
  Widget _buildImageWidget(PhotoItem item, {BoxFit fit = BoxFit.cover, double? height}) {
    if (item.bytes != null) {
      return Image.memory(
        item.bytes!,
        fit: fit,
        height: height,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(item, height: height),
      );
    } else if (kIsWeb && item.path != null && item.path!.isNotEmpty) {
      return Image.network(
        item.path!,
        fit: fit,
        height: height,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(item, height: height),
      );
    } else if (!kIsWeb && item.file != null) {
      return Image.file(
        item.file!,
        fit: fit,
        height: height,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(item, height: height),
      );
    } else {
      return _buildImagePlaceholder(item, height: height);
    }
  }

  Widget _buildImagePlaceholder(PhotoItem item, {double? height}) {
    return Container(
      height: height,
      color: item.placeholderColor ?? const Color(0xFFCFDCE6),
      alignment: Alignment.center,
      child: Icon(
        item.icon ?? Icons.image_rounded,
        size: height != null ? 54 : 28,
        color: Colors.white,
      ),
    );
  }

  /// Validasi Lengkap & Proses Submit Laporan
  void _onSubmitReport() {
    // 1. Validasi Jenis Permasalahan
    if (_selectedJenis.trim().isEmpty) {
      _showWarningSnackBar('Silakan pilih jenis permasalahan terlebih dahulu');
      return;
    }

    // 2. Validasi Judul Laporan
    if (_judulController.text.trim().isEmpty) {
      _showWarningSnackBar('Judul laporan wajib diisi sebelum mengirim');
      return;
    }

    // 3. Validasi Uraian Kejadian di Lingkungan
    if (_uraianController.text.trim().isEmpty) {
      _showWarningSnackBar('Uraian kejadian di lingkungan wajib diisi secara lengkap');
      return;
    }

    // 4. Validasi Lokasi Kejadian
    if (_lokasiController.text.trim().isEmpty) {
      _showWarningSnackBar('Lokasi kejadian wajib ditentukan / diisi');
      return;
    }

    // 5. Validasi Foto Bukti (Wajib minimal 1 foto terlampir)
    if (_photoList.isEmpty) {
      _showWarningSnackBar('Harap lampirkan minimal 1 foto bukti kejadian');
      return;
    }

    // Pembuatan ID Laporan Otomatis (Format: SP-YYMM-XXXX)
    final DateTime now = DateTime.now();
    final String yearShort = (now.year % 100).toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String randomCode = ((now.millisecondsSinceEpoch ~/ 1000) % 9000 + 1000).toString();
    final String autoReportId = 'SP-$yearShort$month-$randomCode';

    // Mengumpulkan seluruh data form lengkap
    final Map<String, dynamic> reportData = {
      'id_laporan': autoReportId,
      'nomor_tiket': autoReportId,
      'jenis_permasalahan': _selectedJenis,
      'judul': _judulController.text.trim(),
      'uraian': _uraianController.text.trim(),
      'lokasi': _lokasiController.text.trim(),
      'latitude': _currentLatLng.latitude,
      'longitude': _currentLatLng.longitude,
      'foto_paths': _photoList.map((p) => p.path).whereType<String>().toList(),
      'jumlah_foto': _photoList.length,
      'is_anonymous': _isAnonymous,
      'timestamp': now.toIso8601String(),
    };

    // JIKA USER MEMBERIKAN CALLBACK onNext, MAKA SAMBUNGKAN KE HALAMAN BERIKUTNYA
    if (widget.onNext != null) {
      widget.onNext!(reportData);
      return;
    }

    // DEFAULT ACTION: Navigasi langsung ke halaman Laporan Sukses dengan ID Laporan Otomatis
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LaporanSuksesScreen(
          reportData: reportData,
          nomorTiket: autoReportId,
          tanggalWaktu: now,
        ),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
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
        backgroundColor: Colors.red[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF2E7D32),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Laporan Terkirim!',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _neutralDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Laporan "${data['judul']}" berhasil disubmit dan akan segera ditindaklanjuti oleh petugas.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  color: _neutralGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderGrey),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Kategori', data['jenis_permasalahan']),
                    const Divider(height: 14),
                    _buildSummaryRow('Lokasi', data['lokasi']),
                    const Divider(height: 14),
                    _buildSummaryRow('Bukti Foto', '${data['jumlah_foto']} foto'),
                    const Divider(height: 14),
                    _buildSummaryRow(
                      'Identitas',
                      data['is_anonymous'] ? 'Dirahasiakan (Anonim)' : 'Publik',
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Mulish',
            fontSize: 12,
            color: _neutralGrey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _neutralDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
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
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // =================================================================
            // 1. APPBAR / HEADER ORANGE HANGAT
            // =================================================================
            _buildHeader(context),

            // =================================================================
            // 2. KONTEN FORMULIR (SCROLLABLE & RESPONSIVE)
            // =================================================================
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Section 1: Jenis Permasalahan ---
                        _buildSectionTitle('Jenis permasalahan'),
                        const SizedBox(height: 10),
                        _buildJenisPermasalahanGrid(),
                        const SizedBox(height: 18),

                        // --- Section 2: Judul Laporan ---
                        _buildSectionTitle('Judul laporan'),
                        const SizedBox(height: 8),
                        _buildJudulTextField(),
                        const SizedBox(height: 18),

                        // --- Section 3: Uraian Kejadian di Lingkungan ---
                        _buildSectionTitle('Uraian kejadian di lingkungan'),
                        const SizedBox(height: 8),
                        _buildUraianTextField(),
                        const SizedBox(height: 18),

                        // --- Section 4: Lokasi & Real-Time Google Maps & Dropdown ---
                        _buildSectionTitle('Lokasi'),
                        const SizedBox(height: 8),
                        _buildLocationDropdown(),
                        const SizedBox(height: 10),
                        _buildGoogleMapsPreviewBox(),
                        const SizedBox(height: 10),
                        _buildAddressField(),
                        const SizedBox(height: 18),

                        // --- Section 5: Foto Bukti (Maks 4) dari Kamera & Galeri ---
                        _buildSectionTitle('Foto bukti (maks 4)'),
                        const SizedBox(height: 10),
                        _buildPhotoRow(),
                        const SizedBox(height: 18),

                        // --- Section 6: Rahasiakan Identitas Pelapor ---
                        _buildAnonymousToggle(),
                        const SizedBox(height: 24),

                        // --- Section 7: Tombol Kirim Laporan ---
                        _buildSubmitButton(),
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
        color: _primaryOrange,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Tombol Back di sisi kiri
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

              // Judul Header tepat di tengah secara horizontal
              const Text(
                'Permasalahan Sosial',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Label judul setiap section
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Mulish',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _neutralDark,
      ),
    );
  }

  /// Section 1: Grid 2 kolom pilihan jenis permasalahan
  Widget _buildJenisPermasalahanGrid() {
    return Column(
      children: [
        for (int i = 0; i < _jenisPermasalahanList.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
              bottom: i + 2 < _jenisPermasalahanList.length ? 8 : 0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildJenisChip(_jenisPermasalahanList[i]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: i + 1 < _jenisPermasalahanList.length
                      ? _buildJenisChip(_jenisPermasalahanList[i + 1])
                      : const SizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Chip individual jenis permasalahan
  Widget _buildJenisChip(String label) {
    final bool isSelected = _selectedJenis == label;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedJenis = label;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _lightOrangeBg : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _primaryOrange : _borderGrey,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? _primaryOrange : const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }

  /// Section 2: Input Judul Laporan
  Widget _buildJudulTextField() {
    return TextFormField(
      controller: _judulController,
      style: const TextStyle(
        fontFamily: 'Mulish',
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: _neutralDark,
      ),
      decoration: InputDecoration(
        hintText: 'Masukkan judul laporan...',
        hintStyle: const TextStyle(
          fontFamily: 'Mulish',
          fontSize: 13.5,
          color: Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE89A58), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE89A58), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryOrange, width: 1.5),
        ),
      ),
    );
  }

  /// Section 3: Input Uraian Kejadian di Lingkungan (Multiline)
  Widget _buildUraianTextField() {
    return TextFormField(
      controller: _uraianController,
      minLines: 4,
      maxLines: 6,
      style: const TextStyle(
        fontFamily: 'Mulish',
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: _neutralDark,
      ),
      decoration: InputDecoration(
        hintText: 'Apa yang terjadi, sejak kapan, siapa yang terlibat...',
        hintStyle: const TextStyle(
          fontFamily: 'Mulish',
          fontSize: 13.5,
          color: Color(0xFF9CA3AF),
          height: 1.35,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryOrange, width: 1.5),
        ),
      ),
    );
  }

  /// Dropdown Pemilihan Lokasi (Mengubah posisi Google Maps secara real time)
  Widget _buildLocationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderGrey, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LocationOption>(
          value: _locationOptions.contains(_selectedLocation)
              ? _selectedLocation
              : _locationOptions.first,
          isExpanded: true,
          menuMaxHeight: 340,
          borderRadius: BorderRadius.circular(14),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primaryOrange),
          items: _locationOptions.map((LocationOption loc) {
            return DropdownMenuItem<LocationOption>(
              value: loc,
              child: Row(
                children: [
                  const Icon(Icons.location_city_rounded,
                      size: 18, color: _primaryOrange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      loc.label,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _neutralDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: _onLocationDropdownChanged,
        ),
      ),
    );
  }

  /// Section 4: Map Preview dengan Google Maps Real-Time (Live Tiles & Interaktif)
  Widget _buildGoogleMapsPreviewBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderGrey, width: 1),
        ),
        child: Stack(
          children: [
            // Peta Google Maps Real-Time Live Tiles
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLatLng,
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: _onMapTapped,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  userAgentPackageName: 'com.example.sentra_mobile',
                  maxZoom: 20,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLatLng,
                      width: 44,
                      height: 44,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: _pinRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Badge Informasi Google Maps Live
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.public_rounded, size: 12, color: Color(0xFF1976D2)),
                    SizedBox(width: 4),
                    Text(
                      'Google Maps Live',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol "Lokasi saya" di pojok kanan bawah
            Positioned(
              right: 10,
              bottom: 10,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 2,
                shadowColor: const Color(0x30000000),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _onGetMyLocation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoadingGps)
                          const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2E7D32),
                            ),
                          )
                        else
                          const Icon(
                            Icons.my_location_rounded,
                            size: 14,
                            color: Color(0xFF2E7D32),
                          ),
                        const SizedBox(width: 5),
                        const Text(
                          'Lokasi saya',
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
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

  /// Input Alamat Textfield di bawah Map
  Widget _buildAddressField() {
    return TextFormField(
      controller: _lokasiController,
      style: const TextStyle(
        fontFamily: 'Mulish',
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: _neutralDark,
      ),
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 8),
          child: Icon(
            Icons.location_on_outlined,
            color: Color(0xFF6B7280),
            size: 20,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 36),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryOrange, width: 1.5),
        ),
      ),
    );
  }

  /// Section 5: Baris 4 slot foto bukti (Mendukung Kamera & Galeri Nyata)
  Widget _buildPhotoRow() {
    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Expanded(
            child: _buildPhotoSlot(i),
          ),
          if (i < 3) const SizedBox(width: 8),
        ],
      ],
    );
  }

  /// Slot foto individual
  Widget _buildPhotoSlot(int index) {
    final bool hasPhoto = index < _photoList.length;

    if (hasPhoto) {
      final item = _photoList[index];
      return AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: () => _onPreviewPhoto(item),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderGrey, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gambar nyata dari File Kamera / Galeri (Aman di Web & Mobile)
                  _buildImageWidget(item, fit: BoxFit.cover),

                  // Overlay hitam transparan tipis di bagian atas
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 24,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0x60000000), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Tombol Hapus (Silang)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _onRemovePhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xCC000000),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Slot Kosong dengan Border Putus-putus (+ Tambah dari Kamera/Galeri)
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFFCBD5E1),
          strokeWidth: 1.2,
          gap: 3.5,
          radius: 12,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _showImageSourcePicker,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 22,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tambah',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section 6: Switch "Rahasiakan identitas pelapor"
  Widget _buildAnonymousToggle() {
    return InkWell(
      onTap: () {
        setState(() {
          _isAnonymous = !_isAnonymous;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _isAnonymous,
              activeColor: Colors.white,
              activeTrackColor: _greenActive,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFD1D5DB),
              onChanged: (val) {
                setState(() {
                  _isAnonymous = val;
                });
              },
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Rahasiakan identitas pelapor',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _neutralDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section 7: Tombol "Kirim Laporan" Oranye Penuh
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: _onSubmitReport,
        child: const Text(
          'Kirim Laporan',
          style: TextStyle(
            fontFamily: 'Mulish',
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

/// Custom Painter untuk border putus-putus pada slot tambah foto
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.radius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final ui.Path path = ui.Path()..addRRect(rrect);
    final ui.PathMetrics metrics = path.computeMetrics();

    for (final ui.PathMetric metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = (metric.length - distance).clamp(0.0, 5.0);
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += length + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.radius != radius;
  }
}
