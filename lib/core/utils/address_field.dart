import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/core/utils/app_colors.dart';

class Address {
  final String name;
  final String placeId;
  final String description;

  Address({
    required this.name,
    required this.placeId,
    required this.description,
  });
}

class AddressAutocompleteCustom extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(Address)? onSelected;

  const AddressAutocompleteCustom({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.validator,
    this.onSelected,
  });

  @override
  State<AddressAutocompleteCustom> createState() =>
      _AddressAutocompleteCustomState();
}

class _AddressAutocompleteCustomState extends State<AddressAutocompleteCustom> {
  final TextEditingController _internalController = TextEditingController();
  final Dio _dio = Dio();
  List<Address> _suggestions = [];
  bool _isLoading = false;
  bool _noResults = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _internalController.text = widget.controller!.text;
      _internalController.addListener(() {
        widget.controller!.text = _internalController.text;
      });
    }
  }

  Future<List<Address>> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
        _noResults = false;
      });
      return [];
    }

    setState(() {
      _isLoading = true;
      _noResults = false;
    });

    final String baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
    try {
      final encodedQuery = Uri.encodeComponent(query);
      print('Query: $encodedQuery'); // Debugging
      final response = await _dio.get(
        '$baseUrl/$encodedQuery.json',
        queryParameters: {
          'access_token':
              'MAPBOX_TOKEN_REMOVED',
          'country': 'id',
          'types': 'address,place,locality,neighborhood',
          'autocomplete': true,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('API Response: $data');
        if (data['features'] != null && data['features'].isNotEmpty) {
          final features = data['features'] as List;
          final suggestions =
              features.map((feature) {
                return Address(
                  name: feature['text'] ?? feature['place_name'],
                  placeId: feature['id'],
                  description: feature['place_name'],
                );
              }).toList();
          setState(() {
            _suggestions = suggestions;
            _noResults = false;
          });
          return suggestions;
        } else {
          print('API Error: No features found');
          setState(() {
            _suggestions = [];
            _noResults = true;
          });
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        setState(() {
          _suggestions = [];
          _noResults = true;
        });
        return [];
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat saran alamat: $e')),
        );
      }
      setState(() {
        _suggestions = [];
        _noResults = true;
      });
      return [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _internalController.dispose();
    _dio.close();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Address>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {});
        return await _fetchSuggestions(textEditingValue.text);
      },
      displayStringForOption: (Address option) => option.description,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _internalController.text = controller.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          cursorColor: Colors.black,
          validator: widget.validator,
          onChanged: (value) => _fetchSuggestions(value),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelStyle: const TextStyle(
              color: Colors.black,
              fontFamily: "Mulish",
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            labelText: widget.label,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontFamily: 'Mulish',
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Warna.backgroundIjo,
                width: 2,
              ),
            ),
            suffixIcon:
                _isLoading
                    ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2,
                          color: Warna.backgroundIjo,
                        ),
                      ),
                    )
                    : Icon(Icons.location_on, color: Colors.grey.shade600),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(10.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200,
                maxWidth: MediaQuery.of(context).size.width - 32,
              ),
              child:
                  options.isEmpty && _noResults
                      ? const ListTile(
                        title: Text(
                          'Tidak ada alamat ditemukan',
                          style: TextStyle(fontFamily: 'Mulish', fontSize: 12),
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final Address option = options.elementAt(index);
                          return ListTile(
                            title: Text(
                              option.name,
                              style: const TextStyle(
                                fontFamily: 'Mulish',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              option.description,
                              style: const TextStyle(
                                fontFamily: 'Mulish',
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              onSelected(option);
                              _internalController.text = option.description;
                              if (widget.onSelected != null) {
                                widget.onSelected!(option);
                              }
                            },
                          );
                        },
                      ),
            ),
          ),
        );
      },
    );
  }
}

class AddressAutocompleteEnhanced extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(Address)? onSelected;
  final Color themeColor;

  const AddressAutocompleteEnhanced({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.onSelected,
    required this.themeColor,
  });

  @override
  State<AddressAutocompleteEnhanced> createState() =>
      _AddressAutocompleteEnhancedState();
}

class _AddressAutocompleteEnhancedState
    extends State<AddressAutocompleteEnhanced> {
  final TextEditingController _internalController = TextEditingController();
  final Dio _dio = Dio();
  List<Address> _suggestions = [];
  bool _isLoading = false;
  bool _noResults = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _internalController.text = widget.controller!.text;
      _internalController.addListener(() {
        widget.controller!.text = _internalController.text;
      });
    }
  }

  Future<List<Address>> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
        _noResults = false;
      });
      return [];
    }

    setState(() {
      _isLoading = true;
      _noResults = false;
    });

    final String baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
    try {
      final encodedQuery = Uri.encodeComponent(query);
      print('Query: $encodedQuery'); // Debugging
      final response = await _dio.get(
        '$baseUrl/$encodedQuery.json',
        queryParameters: {
          'access_token':
              'MAPBOX_TOKEN_REMOVED',
          'country': 'id',
          'types': 'address,place,locality,neighborhood',
          'autocomplete': true,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('API Response: $data'); // Debugging
        if (data['features'] != null && data['features'].isNotEmpty) {
          final features = data['features'] as List;
          final suggestions =
              features.map((feature) {
                return Address(
                  name: feature['text'] ?? feature['place_name'],
                  placeId: feature['id'],
                  description: feature['place_name'],
                );
              }).toList();
          setState(() {
            _suggestions = suggestions;
            _noResults = false;
          });
          return suggestions;
        } else {
          print('API Error: No features found');
          setState(() {
            _suggestions = [];
            _noResults = true;
          });
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        setState(() {
          _suggestions = [];
          _noResults = true;
        });
        return [];
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat saran alamat: $e')),
        );
      }
      setState(() {
        _suggestions = [];
        _noResults = true;
      });
      return [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _internalController.dispose();
    _dio.close();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Autocomplete<Address>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {});
                return await _fetchSuggestions(textEditingValue.text);
              },
              displayStringForOption: (Address option) => option.description,
              fieldViewBuilder: (
                context,
                controller,
                focusNode,
                onFieldSubmitted,
              ) {
                _internalController.text = controller.text;
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  cursorColor: widget.themeColor,
                  validator: widget.validator,
                  onChanged: (value) => _fetchSuggestions(value),
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: widget.themeColor,
                        size: 20,
                      ),
                    ),
                    suffixIcon:
                        _isLoading
                            ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Warna.backgroundIjo,
                                ),
                              ),
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.themeColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red[400]!, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(12.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 200,
                        maxWidth: MediaQuery.of(context).size.width - 32,
                      ),
                      child:
                          options.isEmpty && _noResults
                              ? const ListTile(
                                title: Text(
                                  'Tidak ada alamat ditemukan',
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final Address option = options.elementAt(
                                    index,
                                  );
                                  return ListTile(
                                    title: Text(
                                      option.name,
                                      style: const TextStyle(
                                        fontFamily: 'Mulish',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      option.description,
                                      style: const TextStyle(
                                        fontFamily: 'Mulish',
                                        fontSize: 12,
                                      ),
                                    ),
                                    onTap: () {
                                      onSelected(option);
                                      _internalController.text =
                                          option.description;
                                      if (widget.onSelected != null) {
                                        widget.onSelected!(option);
                                      }
                                    },
                                  );
                                },
                              ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class AddressAutocompleteCompact extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(Address)? onSelected;
  final Color iconColor;
  final String? hintText;
  final int maxLength;

  const AddressAutocompleteCompact({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.onSelected,
    required this.iconColor,
    this.hintText,
    required this.maxLength,
  });

  @override
  State<AddressAutocompleteCompact> createState() => _AddressAutocompleteCompactState();
}

class _AddressAutocompleteCompactState extends State<AddressAutocompleteCompact> {
  final TextEditingController _internalController = TextEditingController();
  final Dio _dio = Dio();
  List<Address> _suggestions = [];
  bool _isLoading = false;
  bool _noResults = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _internalController.text = widget.controller!.text;
      _internalController.addListener(() {
        widget.controller!.text = _internalController.text;
      });
    }
  }

  Future<List<Address>> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
        _noResults = false;
      });
      return [];
    }

    setState(() {
      _isLoading = true;
      _noResults = false;
    });

    

    final String baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
    try {
      final encodedQuery = Uri.encodeComponent(query);
      print('Query: $encodedQuery'); 
      final response = await _dio.get(
        '$baseUrl/$encodedQuery.json',
        queryParameters: {
          'access_token': 'MAPBOX_TOKEN_REMOVED',
          'country': 'id',
          'types': 'address,place,locality,neighborhood',
          'autocomplete': true,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('API Response: $data');
        if (data['features'] != null && data['features'].isNotEmpty) {
          final features = data['features'] as List;
          final suggestions = features.map((feature) {
            return Address(
              name: feature['text'] ?? feature['place_name'],
              placeId: feature['id'],
              description: feature['place_name'],
            );
          }).toList();
          setState(() {
            _suggestions = suggestions;
            _noResults = false;
          });
          return suggestions;
        } else {
          print('API Error: No features found');
          setState(() {
            _suggestions = [];
            _noResults = true;
          });
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        setState(() {
          _suggestions = [];
          _noResults = true;
        });
        return [];
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat saran alamat: $e')),
        );
      }
      setState(() {
        _suggestions = [];
        _noResults = true;
      });
      return [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _internalController.dispose();
    _dio.close();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = screenWidth > 600 ? 1.0 : 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.iconColor.withOpacity(0.15),
                      widget.iconColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.iconColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.location_on, size: 16, color: widget.iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13 * textScaleFactor,
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
                      fontSize: 14 * textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Autocomplete<Address>(
            optionsBuilder: (TextEditingValue textEditingValue) async {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {});
              return await _fetchSuggestions(textEditingValue.text);
            },
            displayStringForOption: (Address option) => option.description,
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              _internalController.text = controller.text;
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                cursorColor: widget.iconColor,
                validator: widget.validator,
                onChanged: (value) => _fetchSuggestions(value),
                keyboardType: TextInputType.text,
                maxLength: widget.maxLength,
                inputFormatters: [LengthLimitingTextInputFormatter(widget.maxLength)],
                style: TextStyle(
                  fontSize: 14 * textScaleFactor,
                  fontFamily: 'Mulish',
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Masukkan alamat anda',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13 * textScaleFactor,
                    fontFamily: 'Mulish',
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.iconColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                  ),
                  errorStyle: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 11 * textScaleFactor,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w500,
                  ),
                  counterStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10 * textScaleFactor,
                    fontFamily: 'Mulish',
                  ),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2,color: Warna.backgroundIjo,),
                          ),
                        )
                      : null,
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(12.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                      maxWidth: MediaQuery.of(context).size.width - 32,
                    ),
                    child: options.isEmpty && _noResults
                        ? ListTile(
                            title: Text(
                              'Tidak ada alamat ditemukan',
                              style: TextStyle(
                                fontFamily: 'Mulish',
                                fontSize: 12 * textScaleFactor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final Address option = options.elementAt(index);
                              return ListTile(
                                title: Text(
                                  option.name,
                                  style: const TextStyle(
                                    fontFamily: 'Mulish',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  option.description,
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 12 * textScaleFactor,
                                  ),
                                ),
                                onTap: () {
                                  onSelected(option);
                                  _internalController.text = option.description;
                                  if (widget.onSelected != null) {
                                    widget.onSelected!(option);
                                                                      }
                                    },
                                  );
                                },
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
}

class AddressAutocompleteStandard extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isMultiline;
  final bool isRequired;
  final Function(Address)? onSelected;
  final IconData? icon;
  final bool? isEditing;
  final Function(bool)? onEditingChanged;

  const AddressAutocompleteStandard({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.isMultiline = false,
    this.isRequired = false,
    this.onSelected,
    this.icon,
    this.isEditing,
    this.onEditingChanged,
  });

  @override
  State<AddressAutocompleteStandard> createState() => _AddressAutocompleteStandardState();
}

class _AddressAutocompleteStandardState extends State<AddressAutocompleteStandard> {
  final TextEditingController _internalController = TextEditingController();
  final Dio _dio = Dio();
  List<Address> _suggestions = [];
  bool _isLoading = false;
  bool _noResults = false;
  Timer? _debounce;
  bool _localIsEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _internalController.text = widget.controller!.text;
      _internalController.addListener(() {
        widget.controller!.text = _internalController.text;
        if (widget.isEditing == null) {
          setState(() => _localIsEditing = _internalController.text.isNotEmpty);
          if (widget.onEditingChanged != null) {
            widget.onEditingChanged!(_localIsEditing);
          }
        }
      });
    }
    _localIsEditing = widget.isEditing ?? _localIsEditing;
  }

  bool _showErrorStyle() {
    final isEditing = widget.isEditing ?? _localIsEditing;
    if (!isEditing) return false;
    if (widget.isRequired && _internalController.text.trim().isEmpty) return true;
    return false;
  }

  Future<List<Address>> _fetchSuggestions(String query) async {
    if (query.isEmpty || !(widget.isEditing ?? _localIsEditing)) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
        _noResults = false;
      });
      return [];
    }

    setState(() {
      _isLoading = true;
      _noResults = false;
    });

    final String baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
    try {
      final encodedQuery = Uri.encodeComponent(query);
      print('Query: $encodedQuery'); 
      final response = await _dio.get(
        '$baseUrl/$encodedQuery.json',
        queryParameters: {
          'access_token': 'MAPBOX_TOKEN_REMOVED',
          'country': 'id',
          'types': 'address,place,locality,neighborhood',
          'autocomplete': true,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('API Response: $data'); // Debugging
        if (data['features'] != null && data['features'].isNotEmpty) {
          final features = data['features'] as List;
          final suggestions = features.map((feature) {
            return Address(
              name: feature['text'] ?? feature['place_name'],
              placeId: feature['id'],
              description: feature['place_name'],
            );
          }).toList();
          setState(() {
            _suggestions = suggestions;
            _noResults = false;
          });
          return suggestions;
        } else {
          print('API Error: No features found');
          setState(() {
            _suggestions = [];
            _noResults = true;
          });
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        setState(() {
          _suggestions = [];
          _noResults = true;
        });
        return [];
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat saran alamat: $e')),
        );
      }
      setState(() {
        _suggestions = [];
        _noResults = true;
      });
      return [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _internalController.dispose();
    _dio.close();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing ?? _localIsEditing;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isEditing
            ? Autocomplete<Address>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {});
                  return await _fetchSuggestions(textEditingValue.text);
                },
                displayStringForOption: (Address option) => option.description,
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  _internalController.text = controller.text;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.black54) : null,
                      labelText: widget.isRequired ? '${widget.label} *' : widget.label,
                      hintText: widget.hint,
                      filled: true,
                      fillColor: isEditing ? Colors.white : Colors.grey.shade50,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _showErrorStyle() ? Colors.red.shade700 : Colors.black87,
                      ),
                      hintStyle: const TextStyle(
                        color: Colors.black45,
                        fontFamily: 'Mulish',
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: _showErrorStyle() ? Colors.red.shade300 : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: _showErrorStyle() ? Colors.red : Colors.black,
                          width: 1.8,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.red, width: 1.6),
                      ),
                      suffixIcon: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    style: const TextStyle(fontFamily: 'Mulish'),
                    maxLines: widget.isMultiline ? 3 : 1,
                    readOnly: !isEditing,
                    onChanged: (_) {
                      if (!isEditing) {
                        setState(() => _localIsEditing = true);
                        if (widget.onEditingChanged != null) {
                          widget.onEditingChanged!(_localIsEditing);
                        }
                      }
                      _fetchSuggestions(_internalController.text);
                    },
                    onTap: () {
                      if (!isEditing) {
                        setState(() => _localIsEditing = true);
                        if (widget.onEditingChanged != null) {
                          widget.onEditingChanged!(_localIsEditing);
                        }
                      }
                    },
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(14.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 200,
                          maxWidth: MediaQuery.of(context).size.width - 32,
                        ),
                        child: options.isEmpty && _noResults
                            ? ListTile(
                                title: Text(
                                  'Tidak ada alamat ditemukan',
                                  style: const TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final Address option = options.elementAt(index);
                                  return ListTile(
                                    title: Text(
                                      option.name,
                                      style: const TextStyle(
                                        fontFamily: 'Mulish',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      option.description,
                                      style: const TextStyle(
                                        fontFamily: 'Mulish',
                                        fontSize: 12,
                                      ),
                                    ),
                                    onTap: () {
                                      onSelected(option);
                                      _internalController.text = option.description;
                                      if (widget.onSelected != null) {
                                        widget.onSelected!(option);
                                      }
                                      setState(() {});
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  );
                },
              )
            : TextField(
                controller: _internalController,
                decoration: InputDecoration(
                  prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.black54) : null,
                  labelText: widget.isRequired ? '${widget.label} *' : widget.label,
                  hintText: widget.hint,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  hintStyle: const TextStyle(
                    color: Colors.black45,
                    fontFamily: 'Mulish',
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.black, width: 1.8),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Mulish'),
                maxLines: widget.isMultiline ? 3 : 1,
                readOnly: true,
              ),
      ),
    );
  }
}
