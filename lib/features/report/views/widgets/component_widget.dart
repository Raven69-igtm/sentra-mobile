import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/core/utils/app_colors.dart';

class AppSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color>? gradientColors;

  const AppSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        gradientColors ??
        [Warna.backgroundIjo, Warna().darken(Warna.backgroundIjo, 0.15)];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: "Mulish",
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class AppSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const AppSectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.color = const Color(0xFF2E7D32),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Mulish",
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? icon;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? hintText;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.icon,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
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
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textCapitalization: textCapitalization,
              maxLines: maxLines,
              readOnly: readOnly,
              onTap: onTap,
              cursorColor: Colors.green[600],
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 16,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon:
                    icon != null
                        ? Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: Colors.green[600], size: 20),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final IconData icon;
  final ValueChanged<T?> onChanged;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
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
            child: DropdownButtonFormField<T>(
              value: value,
              items:
                  items
                      .map(
                        (e) => DropdownMenuItem<T>(
                          value: e,
                          child: Text(
                            e.toString(),
                            style: TextStyle(
                              fontFamily: "Mulish",
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.green[600], size: 20),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;

  AppDateField({
    super.key,
    required this.label,
    required this.controller,
    this.icon = Icons.calendar_today_outlined,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? initialDate,
  }) : firstDate = firstDate ?? DateTime(1900),
       lastDate = lastDate ?? DateTime(2100),
       initialDate = initialDate ??  DateTime(2000, 1, 1);

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      icon: icon,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate:
              controller.text.isEmpty
                  ? DateTime.now()
                  : DateTime.tryParse(controller.text) ?? DateTime.now(),
          firstDate: firstDate,
          lastDate: lastDate,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Warna.backgroundIjo,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Warna.backgroundIjo,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          final formatted =
              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          controller.text = formatted;
        }
      },
    );
  }
}

class RadioChips extends StatelessWidget {
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final Color activeColor;

  const RadioChips({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.activeColor = const Color(0xFF2E7D32),
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children:
          options.map((opt) {
            final selected = value == opt;
            return ChoiceChip(
              label: Text(
                opt,
                style: TextStyle(
                  fontFamily: "Mulish",
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey[700],
                ),
              ),
              selected: selected,
              selectedColor: activeColor,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? activeColor : Colors.grey[300]!,
                width: selected ? 2 : 1,
              ),
              onSelected: (_) => onChanged(opt),
            );
          }).toList(),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final IconData icon;
  final Color accent;

  const SectionCard({
    super.key,
    required this.title,
    required this.data,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: accent.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _KeyValueRows(data: data),
          ),
        ],
      ),
    );
  }
}

class _KeyValueRows extends StatelessWidget {
  final Map<String, dynamic> data;

  const _KeyValueRows({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          data.entries.map((e) {
            final key = _formatFieldName(e.key);
            final value = (e.value ?? '').toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      "$key:",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value.isEmpty ? '-' : value,
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontSize: 13,
                        color: value.isEmpty ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

String _formatFieldName(String fieldName) {
  return fieldName
      .split('_')
      .map(
        (w) =>
            w.isNotEmpty
                ? w[0].toUpperCase() + w.substring(1).toLowerCase()
                : w,
      )
      .join(' ');
}
