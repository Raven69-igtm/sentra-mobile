import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';
import 'package:sentra/core/widgets/sentra_gradient_icon.dart';

/// Input teks standar SENTRA dengan label di atas field (13 px w700).
class SentraTextField extends StatefulWidget {
  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final Color? accentColor;
  final String? helperText;
  final bool useGradientIcon;

  const SentraTextField({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.onTap,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.accentColor,
    this.helperText,
    this.useGradientIcon = false,
  });

  @override
  State<SentraTextField> createState() => _SentraTextFieldState();
}

class _SentraTextFieldState extends State<SentraTextField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final focusColor = widget.accentColor ?? AppColors.primary;

    Widget? resolvedSuffix = widget.suffix;
    if (resolvedSuffix == null && widget.obscureText) {
      final visIcon =
          _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined;
      resolvedSuffix = IconButton(
        tooltip: _isObscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
        icon:
            widget.useGradientIcon
                ? SentraGradientIcon(visIcon, size: 20)
                : Icon(visIcon, color: AppColors.textMuted, size: 20),
        onPressed: () => setState(() => _isObscure = !_isObscure),
      );
    } else if (resolvedSuffix == null && widget.suffixIcon != null) {
      resolvedSuffix =
          widget.useGradientIcon
              ? SentraGradientIcon(widget.suffixIcon!, size: 20)
              : Icon(widget.suffixIcon, color: AppColors.textMuted, size: 20);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 2),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _isObscure,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          onTap: widget.onTap,
          validator: widget.validator,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          cursorColor: focusColor,
          style: AppTypography.body.copyWith(
            color:
                widget.enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            helperStyle: AppTypography.caption,
            filled: true,
            fillColor:
                widget.enabled && !widget.readOnly
                    ? AppColors.surface
                    : AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            prefixIcon:
                widget.prefixIcon != null
                    ? (widget.useGradientIcon
                        ? SentraGradientIcon(widget.prefixIcon!, size: 20)
                        : Icon(
                          widget.prefixIcon,
                          color: AppColors.textMuted,
                          size: 20,
                        ))
                    : null,
            suffixIcon: resolvedSuffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: focusColor, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.error, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
