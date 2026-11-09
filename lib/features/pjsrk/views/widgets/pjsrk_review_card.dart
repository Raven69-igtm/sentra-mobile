import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Kartu putih berisi ringkasan, dengan tombol "Ubah" di kanan atas.
class PjsrkReviewCard extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final List<Widget> children;

  const PjsrkReviewCard({
    super.key,
    required this.title,
    required this.onEdit,
    required this.children,
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
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const Spacer(),
            InkWell(
              onTap: onEdit,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text('Ubah',
                    style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PjsrkColors.primary)),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          ...children,
        ]),
      );
}

/// Satu baris ringkasan: label abu di kiri, isi tebal di kanan.
/// Isi bisa berupa teks ([value]) atau widget bebas ([child]).
class PjsrkReviewRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;

  const PjsrkReviewRow({
    super.key,
    required this.label,
    this.value,
    this.child,
  }) : assert(value != null || child != null);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 112,
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    color: PjsrkColors.muted)),
          ),
          Expanded(
            child: child ??
                Text(value!,
                    style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}