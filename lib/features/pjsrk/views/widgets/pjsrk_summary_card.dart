import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Kartu ringkasan: judul + tombol Ubah + daftar "label : isi".
class PjsrkSummaryCard extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> rows;
  final VoidCallback onEdit;

  const PjsrkSummaryCard({
    super.key,
    required this.title,
    required this.rows,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PjsrkColors.border, width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
            GestureDetector(
              onTap: onEdit,
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.edit_outlined,
                    size: 16, color: PjsrkColors.primaryText),
                SizedBox(width: 4),
                Text('Ubah',
                    style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PjsrkColors.primaryText)),
              ]),
            ),
          ]),
          const Divider(height: 24, color: PjsrkColors.border),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(r.key,
                          style: const TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 14,
                              color: PjsrkColors.muted)),
                    ),
                    Expanded(
                      child: Text(r.value,
                          style: const TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
            ),
        ]),
      );
}