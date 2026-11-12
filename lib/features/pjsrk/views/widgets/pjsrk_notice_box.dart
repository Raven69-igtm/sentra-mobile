import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Kotak pemberitahuan berwarna krem dengan ikon.
class PjsrkNoticeBox extends StatelessWidget {
  final IconData icon;
  final String text;
  const PjsrkNoticeBox({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PjsrkColors.noticeBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PjsrkColors.noticeBorder, width: 1.5),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 22, color: PjsrkColors.noticeText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    height: 1.4,
                    color: PjsrkColors.noticeText)),
          ),
        ]),
      );
}