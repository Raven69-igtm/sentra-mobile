import 'package:flutter/material.dart';

/// Membuat semua teks (termasuk isian TextField) di dalamnya pakai Mulish.
class PjsrkFontScope extends StatelessWidget {
  final Widget child;
  const PjsrkFontScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'Mulish'),
        primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'Mulish'),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontFamily: 'Mulish'),
        child: child,
      ),
    );
  }
}