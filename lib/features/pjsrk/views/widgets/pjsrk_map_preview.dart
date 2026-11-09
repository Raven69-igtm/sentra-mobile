import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// PETA langkah 2 (Lokasi) — pakai OpenStreetMap (flutter_map).
///
/// Fitur:
///  1. Ketuk peta        -> pin pindah, alamat di bawah terisi otomatis.
///  2. Tombol "Lokasi saya" -> ambil GPS, pin pindah, alamat terisi.
///  3. Ketik alamat di bawah peta -> peta OTOMATIS terbang ke alamat itu.
class PjsrkMapPreview extends StatefulWidget {
  final Function(double lat, double lng)? onLocationChanged;
  final TextEditingController? addressController;
  final TextEditingController? kelurahanController;
  final TextEditingController? kecamatanController;

  /// Titik awal peta (default: Nganjuk).
  final double initialLat;
  final double initialLng;

  const PjsrkMapPreview({
    super.key,
    this.onLocationChanged,
    this.addressController,
    this.kelurahanController,
    this.kecamatanController,
    this.initialLat = -7.6051,
    this.initialLng = 111.9046,
  });

  @override
  State<PjsrkMapPreview> createState() => _PjsrkMapPreviewState();
}

class _PjsrkMapPreviewState extends State<PjsrkMapPreview> {
  final MapController _map = MapController();
  late LatLng _current;

  bool _loadingGps = false;
  bool _searching = false;

  Timer? _debounce;

  // true = teks alamat sedang diisi oleh kode (dari tap/GPS),
  // jadi jangan dicari lagi (biar tidak muter-muter).
  bool _isWritingText = false;

  // Penanda permintaan terbaru, jawaban lama yang telat diabaikan.
  int _searchId = 0;

  static const _nominatim = 'nominatim.openstreetmap.org';

  @override
  void initState() {
    super.initState();
    _current = LatLng(widget.initialLat, widget.initialLng);
    widget.addressController?.addListener(_onTextChanged);
    widget.kelurahanController?.addListener(_onTextChanged);
    widget.kecamatanController?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.addressController?.removeListener(_onTextChanged);
    widget.kelurahanController?.removeListener(_onTextChanged);
    widget.kecamatanController?.removeListener(_onTextChanged);
    super.dispose();
  }

  // ------------------------------------------------------------
  // 1) User ngetik alamat -> tunggu berhenti -> cari -> pindah peta
  // ------------------------------------------------------------
  void _onTextChanged() {
    if (_isWritingText) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), _searchAddress);
  }

  Future<void> _searchAddress() async {
    final alamat = widget.addressController?.text.trim() ?? '';
    final kel = widget.kelurahanController?.text.trim() ?? '';
    final kec = widget.kecamatanController?.text.trim() ?? '';

    if (alamat.length < 4) return; // terlalu pendek
    if (alamat.startsWith('Lat ')) return; // isinya koordinat, tidak dicari

    final myId = ++_searchId;
    setState(() => _searching = true);

    try {
      // Coba dari yang paling lengkap sampai yang paling umum.
      final queries = <String>[
        [alamat, kel, kec, 'Jawa Timur'].where((e) => e.isNotEmpty).join(', '),
        [alamat, kec, 'Jawa Timur'].where((e) => e.isNotEmpty).join(', '),
        alamat,
        if (kel.isNotEmpty || kec.isNotEmpty)
          [kel, kec, 'Jawa Timur'].where((e) => e.isNotEmpty).join(', '),
      ];

      LatLng? hasil;
      for (final q in queries) {
        hasil = await _forwardGeocode(q);
        if (myId != _searchId || !mounted) return; // ada pencarian lebih baru
        if (hasil != null) break;
      }

      if (hasil == null) {
        _snack('Alamat belum ketemu di peta. Coba tulis lebih lengkap, '
            'atau ketuk peta langsung.');
        return;
      }

      setState(() => _current = hasil!);
      _map.move(hasil, 17);
      widget.onLocationChanged?.call(hasil.latitude, hasil.longitude);
    } catch (_) {
      _snack('Gagal mencari alamat. Cek koneksi internet.');
    } finally {
      if (mounted && myId == _searchId) setState(() => _searching = false);
    }
  }

  /// Alamat (teks) -> koordinat.
  Future<LatLng?> _forwardGeocode(String query) async {
    final uri = Uri.https(_nominatim, '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '1',
      'countrycodes': 'id',
    });
    final res = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final list = jsonDecode(res.body) as List;
    if (list.isEmpty) return null;
    final lat = double.tryParse('${list.first['lat']}');
    final lon = double.tryParse('${list.first['lon']}');
    if (lat == null || lon == null) return null;
    return LatLng(lat, lon);
  }

  // ------------------------------------------------------------
  // 2) Koordinat -> alamat (dipakai saat tap peta / GPS)
  // ------------------------------------------------------------
  Future<void> _fillAddressFrom(LatLng p) async {
    // Isi koordinat dulu sebagai cadangan.
    _setText(
      widget.addressController,
      'Lat ${p.latitude.toStringAsFixed(5)}, Lng ${p.longitude.toStringAsFixed(5)}',
    );

    try {
      final uri = Uri.https(_nominatim, '/reverse', {
        'lat': '${p.latitude}',
        'lon': '${p.longitude}',
        'format': 'jsonv2',
        'addressdetails': '1',
        'zoom': '18',
      });
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200 || !mounted) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final a = (data['address'] as Map?)?.cast<String, dynamic>() ?? {};

      final jalan = [a['road'], a['house_number']]
          .where((e) => e != null && '$e'.isNotEmpty)
          .join(' ');
      final kel = a['village'] ?? a['suburb'] ?? a['neighbourhood'];
      final kec = a['city_district'] ?? a['municipality'] ?? a['county'];

      final alamat = jalan.isNotEmpty
          ? jalan
          : (data['display_name'] as String?)?.split(',').take(3).join(',');

      if (alamat != null && alamat.isNotEmpty) {
        _setText(widget.addressController, alamat);
      }
      if (kel != null) _setText(widget.kelurahanController, '$kel');
      if (kec != null) _setText(widget.kecamatanController, '$kec');
    } catch (_) {
      // Gagal? Tidak apa-apa, koordinat sudah terisi.
    }
  }

  /// Isi teks tanpa memicu pencarian ulang.
  void _setText(TextEditingController? c, String text) {
    if (c == null) return;
    _isWritingText = true;
    c.text = text;
    _isWritingText = false;
  }

  Map<String, String> get _headers => const {
        // Aturan Nominatim: wajib ada identitas aplikasi.
        'User-Agent': 'SENTRA-DPPPA-Nganjuk/1.0',
        'Accept-Language': 'id',
      };

  // ------------------------------------------------------------
  // 3) Tap peta
  // ------------------------------------------------------------
  void _onMapTap(LatLng p) {
    _debounce?.cancel();
    _searchId++; // batalkan pencarian alamat yang masih jalan
    setState(() {
      _current = p;
      _searching = false;
    });
    widget.onLocationChanged?.call(p.latitude, p.longitude);
    _fillAddressFrom(p);
  }

  // ------------------------------------------------------------
  // 4) Tombol "Lokasi saya"
  // ------------------------------------------------------------
  Future<void> _getMyLocation() async {
    setState(() => _loadingGps = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _snack('GPS belum dinyalakan');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _snack('Izin lokasi ditolak');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _snack('Izin lokasi ditolak permanen. Buka pengaturan HP.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final p = LatLng(pos.latitude, pos.longitude);
      _debounce?.cancel();
      _searchId++;
      setState(() => _current = p);
      _map.move(p, 17);
      widget.onLocationChanged?.call(p.latitude, p.longitude);
      await _fillAddressFrom(p);
    } catch (e) {
      _snack('Gagal ambil lokasi: $e');
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontFamily: 'Mulish')),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: _current,
                initialZoom: 15,
                minZoom: 4,
                maxZoom: 19,
                onTap: (_, latLng) => _onMapTap(latLng),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.sentra_mobile',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _current,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter, // ujung pin = titik
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFE54D5E),
                        size: 44,
                      ),
                    ),
                  ],
                ),
                const RichAttributionWidget(
                  alignment: AttributionAlignment.bottomLeft,
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),

            // Penanda "sedang mencari alamat..."
            if (_searching)
              Positioned(
                left: 12,
                top: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Mencari alamat…',
                        style: TextStyle(fontFamily: 'Mulish', fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

            // Tombol "Lokasi saya"
            Positioned(
              right: 12,
              bottom: 12,
              child: Material(
                color: Colors.white,
                elevation: 3,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _loadingGps ? null : _getMyLocation,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_loadingGps)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(Icons.my_location,
                              size: 18, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 6),
                        const Text(
                          'Lokasi saya',
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
}