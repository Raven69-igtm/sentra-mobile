import 'package:flutter/material.dart';
import 'package:sentra/core/utils/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    required this.keyboardType,
    required this.icon,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      cursorColor: Colors.black,
      obscureText: _isObscure,
      validator: widget.validator,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        labelStyle: const TextStyle(
          color: Colors.black,
          fontFamily: "Mulish",
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        labelText: widget.label,
        hintText: widget.hintText,
        hintStyle: TextStyle(fontFamily: 'Mulish', color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          borderSide: const BorderSide(color: Warna.backgroundIjo, width: 2),
        ),
        suffixIcon:
            widget.obscureText
                ? IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                )
                : Icon(widget.icon, color: Colors.grey.shade600),
      ),
    );
  }
}
