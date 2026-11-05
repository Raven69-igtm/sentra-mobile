import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// ============================================================
// WARNA YANG DIPAKAI BERULANG DI FORM
// ============================================================
const _dark = Color(0xFF2A2A2A);
const _muted = Color(0xFF7A7F85);
const _border = Color(0xFFE8EBEE);
const _orange = Color(0xFFD6762E);
const _green = Color(0xFF3F8F63);

// ------------------------------------------------------------
// JUMLAH ORANG + JENIS KELAMIN
// ------------------------------------------------------------
class RehabJumlahGender extends StatelessWidget {
  final int jumlah;
  final String gender;
  final ValueChanged<int> onJumlah;
  final ValueChanged<String> onGender;

  const RehabJumlahGender({
    super.key,
    required this.jumlah,
    required this.gender,
    required this.onJumlah,
    required this.onGender,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ---- Jumlah orang (naik/turun) ----
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jumlah orang',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.people_outline_rounded,
                        size: 20, color: _muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$jumlah orang',
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _dark,
                        ),
                      ),
                    ),
                    // Tombol + / -
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => onJumlah(jumlah + 1),
                          child: const Icon(Icons.keyboard_arrow_up_rounded,
                              size: 20, color: _muted),
                        ),
                        InkWell(
                          onTap: () {
                            if (jumlah > 1) onJumlah(jumlah - 1);
                          },
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 20, color: _muted),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // ---- Dropdown jenis kelamin ----
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jenis kelamin',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: gender,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: _muted),
                    style: const TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _dark,
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Laki-laki', child: Text('Laki-laki')),
                      DropdownMenuItem(
                          value: 'Perempuan', child: Text('Perempuan')),
                      DropdownMenuItem(
                          value: 'Campuran', child: Text('Campuran')),
                    ],
                    onChanged: (v) {
                      if (v != null) onGender(v);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PETA + LOKASI (GPS + OpenStreetMap via flutter_map)
// ============================================================
/// Widget peta interaktif:
/// - Menampilkan marker di koordinat yang dipilih
/// - Tombol "Lokasi saya" → minta izin GPS → ambil posisi → pindahkan marker
/// - Tap di peta → pindahkan marker ke titik yang disentuh
/// - Field teks alamat di bawah peta (bisa diedit manual)
class RehabMapField extends StatefulWidget {
  /// Controller untuk teks alamat / keterangan lokasi
  final TextEditingController controller;

  /// Dipanggil setiap kali koordinat berubah (lat, lng)
  final void Function(double lat, double lng)? onLocationChanged;

  /// Koordinat awal (default: Nganjuk)
  final double initialLat;
  final double initialLng;

  const RehabMapField({
    super.key,
    required this.controller,
    this.onLocationChanged,
    this.initialLat = -7.6051,
    this.initialLng = 111.9046,
  });

  @override
  State<RehabMapField> createState() => _RehabMapFieldState();
}

class _RehabMapFieldState extends State<RehabMapField> {
  final MapController _mapController = MapController();
  late LatLng _markerPos;
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    _markerPos = LatLng(widget.initialLat, widget.initialLng);
  }

  /// Minta izin + ambil lokasi GPS perangkat
  Future<void> _getMyLocation() async {
    setState(() => _loadingGps = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _snack('Aktifkan GPS / lokasi di pengaturan perangkat');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _snack('Izin lokasi ditolak');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _snack('Izin lokasi diblokir. Buka pengaturan aplikasi.');
        await openAppSettings();
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final latLng = LatLng(pos.latitude, pos.longitude);

      setState(() => _markerPos = latLng);
      _mapController.move(latLng, 16);

      widget.controller.text =
          'Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)}';

      widget.onLocationChanged?.call(pos.latitude, pos.longitude);
      _snack('Lokasi berhasil diambil');
    } catch (e) {
      _snack('Gagal ambil lokasi: $e');
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Mulish')),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---------- PETA ----------
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _markerPos,
                    initialZoom: 15,
                    onTap: (tapPos, latLng) {
                      setState(() => _markerPos = latLng);
                      widget.controller.text =
                          'Lat ${latLng.latitude.toStringAsFixed(5)}, Lng ${latLng.longitude.toStringAsFixed(5)}';
                      widget.onLocationChanged
                          ?.call(latLng.latitude, latLng.longitude);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.sentra_mobile',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _markerPos,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFFE54D5E),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Tombol "Lokasi saya"
                Positioned(
                  right: 12,
                  bottom: 10,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 3,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _loadingGps ? null : _getMyLocation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_loadingGps)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _green,
                                ),
                              )
                            else
                              const Icon(Icons.my_location_rounded,
                                  size: 14, color: _green),
                            const SizedBox(width: 6),
                            Text(
                              _loadingGps ? 'Mengambil…' : 'Lokasi saya',
                              style: const TextStyle(
                                fontFamily: 'Mulish',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _green,
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
        ),

        const SizedBox(height: 10),

        // ---------- FIELD ALAMAT ----------
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: TextField(
            controller: widget.controller,
            style: const TextStyle(
                fontFamily: 'Mulish', fontSize: 14, color: _dark),
            decoration: const InputDecoration(
              prefixIcon:
                  Icon(Icons.place_outlined, size: 20, color: _muted),
              hintText: 'Alamat / keterangan lokasi',
              hintStyle: TextStyle(
                  fontFamily: 'Mulish', fontSize: 13, color: _muted),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// TEXTAREA CIRI-CIRI
// ------------------------------------------------------------
class RehabTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const RehabTextArea({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        style: const TextStyle(
            fontFamily: 'Mulish', fontSize: 14, color: _dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Mulish', fontSize: 13, color: _muted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// FIELD TELEPON
// ------------------------------------------------------------
class RehabPhoneField extends StatelessWidget {
  final TextEditingController controller;
  const RehabPhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
            fontFamily: 'Mulish', fontSize: 14, color: _dark),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.phone_outlined, size: 20, color: _muted),
          hintText: '08xxxxxxxxxx',
          hintStyle:
              TextStyle(fontFamily: 'Mulish', fontSize: 13, color: _muted),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// TOGGLE RAHASIAKAN IDENTITAS
// ------------------------------------------------------------
class RehabRahasiaToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const RehabRahasiaToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Rahasiakan identitas pelapor',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _dark,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: _orange,
          onChanged: onChanged,
        ),
      ],
    );
  }
}