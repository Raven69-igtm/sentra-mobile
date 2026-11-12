import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pjsrk_colors.dart';

/// Kotak input angka dengan ikon, awalan (±) dan akhiran (jiwa / unit).
class PjsrkNumberBox extends StatefulWidget {
  final IconData icon;
  final TextEditingController controller;
  final String? prefix;
  final String suffix;

  const PjsrkNumberBox({
    super.key,
    required this.icon,
    required this.controller,
    required this.suffix,
    this.prefix,
  });

  @override
  State<PjsrkNumberBox> createState() => _PjsrkNumberBoxState();
}

class _PjsrkNumberBoxState extends State<PjsrkNumberBox> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFocused ? PjsrkColors.primary : PjsrkColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(widget.icon, size: 20, color: const Color(0xFF7B7F86)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Mulish',
                  color: Color(0xFF252525),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  prefixText: widget.prefix != null ? '${widget.prefix} ' : null,
                  prefixStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Mulish',
                    color: Color(0xFF252525),
                  ),
                  suffixText: ' ${widget.suffix}',
                  suffixStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Mulish',
                    color: Color(0xFF252525),
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
