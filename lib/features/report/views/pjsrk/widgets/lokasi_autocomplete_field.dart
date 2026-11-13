import 'package:flutter/material.dart';
import 'package:sentra/features/report/views/pjsrk/data/indonesia_cities.dart';

/// ============================================================================
/// WIDGET: LokasiAutocompleteField
/// ============================================================================
/// Input lokasi dengan fitur Autocomplete Dropdown Rekomendasi:
/// - Memiliki header ikon berlatar belakang lembut seperti form PPPA.
/// - Saat user mengetik huruf (misal: "N"), dropdown rekomendasi kota/kabupaten
///   akan muncul di bawah input.
/// - Rekomendasi dapat DIKLIK secara responsif dan langsung mengisi field form.
/// ============================================================================
class LokasiAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final Color iconColor;
  final String? Function(String?)? validator;

  const LokasiAutocompleteField({
    super.key,
    required this.controller,
    this.label = "Lokasi",
    this.hintText = "Jalan,Desa,Kecamatan",
    this.icon = Icons.location_on_outlined,
    this.iconColor = Colors.red,
    this.validator,
  });

  @override
  State<LokasiAutocompleteField> createState() =>
      _LokasiAutocompleteFieldState();
}

class _LokasiAutocompleteFieldState extends State<LokasiAutocompleteField> {
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredSuggestions = [];
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();

    // Listener saat user mengetik untuk memfilter rekomendasi kota
    widget.controller.addListener(_onTextChanged);

    // Listener saat fokus berpindah dengan delay agar aksi klik di dropdown tetap tertangkap
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_focusNode.hasFocus) {
            setState(() {
              _showDropdown = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  /// Memfilter daftar kota berdasarkan teks yang sedang diketik user
  void _onTextChanged() {
    final query = widget.controller.text.trim().toLowerCase();

    if (query.isEmpty) {
      if (_showDropdown) {
        setState(() {
          _filteredSuggestions = [];
          _showDropdown = false;
        });
      }
      return;
    }

    // Filter daftar kota yang mengandung query teks
    final results = kDaftarKotaDanLokasi.where((lokasi) {
      return lokasi.toLowerCase().contains(query);
    }).take(5).toList();

    setState(() {
      _filteredSuggestions = results;
      _showDropdown = results.isNotEmpty;
    });
  }

  /// Memilih salah satu kota dari dropdown
  void _selectSuggestion(String suggestion) {
    widget.controller.text = suggestion;
    widget.controller.selection = TextSelection.collapsed(
      offset: suggestion.length,
    );

    setState(() {
      _showDropdown = false;
    });

    _focusNode.unfocus(); // Tutup keyboard setelah memilih
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Label Teks + Ikon dengan Kotak Warna (Gaya PPPA)
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(widget.icon, size: 15, color: widget.iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  fontFamily: 'Mulish',
                ),
              ),
              if (widget.validator != null)
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Text(
                    "*",
                    style: TextStyle(
                      color: Colors.red.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 2. Kotak Input Form
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            fontFamily: 'Mulish',
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
              fontFamily: 'Mulish',
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            // Tombol hapus atau ikon lokasi di sisi kanan
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        _showDropdown = false;
                      });
                    },
                  )
                : Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: widget.iconColor.withOpacity(0.7),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.iconColor, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
            ),
            errorStyle: const TextStyle(
              fontSize: 11,
              fontFamily: 'Mulish',
              color: Colors.red,
            ),
          ),
          validator: widget.validator,
        ),

        // 3. Dropdown Menu Rekomendasi Kota (Dapat diklik responsif)
        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Material(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _filteredSuggestions.map((kota) {
                    return Listener(
                      // Listener onPointerDown memastikan klik tertangkap instan sebelum fokus tertutup
                      onPointerDown: (_) => _selectSuggestion(kota),
                      child: InkWell(
                        onTap: () => _selectSuggestion(kota),
                        splashColor: const Color(0xFF2E7D5B).withOpacity(0.12),
                        highlightColor: const Color(0xFF2E7D5B).withOpacity(0.06),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFF1F5F9),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F8F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_city_rounded,
                                  size: 16,
                                  color: Color(0xFF2E7D5B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  kota,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1E293B),
                                    fontFamily: 'Mulish',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
