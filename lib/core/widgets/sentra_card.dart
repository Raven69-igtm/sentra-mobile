import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';

/// Kartu permukaan standar SENTRA: putih, border 1px #E5E9EF, radius 16, tanpa bayangan.
class SentraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final Color borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const SentraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.borderRadius = AppSpacing.radiusLg,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    Widget content = Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          onTap != null
              ? InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: Padding(padding: padding, child: child),
              )
              : Padding(padding: padding, child: child),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (semanticLabel != null) {
      content = Semantics(
        button: onTap != null,
        label: semanticLabel,
        child: content,
      );
    }

    return content;
  }
}
