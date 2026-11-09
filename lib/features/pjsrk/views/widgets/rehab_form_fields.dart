import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_style.dart';

// ------------------------------------------------------------
// JUMLAH ORANG (stepper - / +)
// ------------------------------------------------------------
class RehabJumlahField extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const RehabJumlahField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: RehabStyle.inputBox(),
      child: Row(
        children: [
          const Icon(Icons.people_outline_rounded,
              size: 20, color: RehabStyle.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$value orang',
              style: RehabStyle.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _StepButton(
            icon: Icons.remove_rounded,
            enabled: value > min,
            onTap: () => onChanged(value - 1),
          ),
          const SizedBox(width: 8),
          _StepButton(
            icon: Icons.add_rounded,
            enabled: value < max,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled ? RehabStyle.orangeSoft : const Color(0xFFF0F2F4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? RehabStyle.orange : RehabStyle.muted,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// TEXTAREA (ciri-ciri / keterangan)
// ------------------------------------------------------------
class RehabTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const RehabTextArea({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: RehabStyle.inputBox(),
      child: TextField(
        controller: controller,
        minLines: 3,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        scrollPadding: const EdgeInsets.only(bottom: 160),
        style: RehabStyle.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: RehabStyle.hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// FIELD TELEPON
// ------------------------------------------------------------
class RehabPhoneField extends StatelessWidget {
  final TextEditingController controller;
  const RehabPhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: RehabStyle.inputBox(),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
        ],
        scrollPadding: const EdgeInsets.only(bottom: 160),
        style: RehabStyle.body,
        decoration: const InputDecoration(
          prefixIcon:
              Icon(Icons.phone_outlined, size: 20, color: RehabStyle.muted),
          hintText: '08xxxxxxxxxx',
          hintStyle: RehabStyle.hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// TOGGLE "Rahasiakan identitas pelapor" (tanpa Switch bawaan)
// ------------------------------------------------------------
class RehabRahasiaToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RehabRahasiaToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: 'Rahasiakan identitas pelapor',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Rahasiakan identitas pelapor',
                style: TextStyle(
                  fontFamily: RehabStyle.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: RehabStyle.dark,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 46,
              height: 26,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? RehabStyle.orange : const Color(0xFFD5D9DD),
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 160),
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
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

// ------------------------------------------------------------
// ALERT KEAMANAN (form Anak Terlantar)
// ------------------------------------------------------------
class RehabSafetyAlert extends StatelessWidget {
  final String message;
  const RehabSafetyAlert({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3CBA8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 20, color: RehabStyle.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: RehabStyle.fontFamily,
                fontSize: 12.5,
                height: 1.4,
                color: RehabStyle.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// TOMBOL UTAMA ORANYE (Kirim Laporan)
// ------------------------------------------------------------
class RehabPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const RehabPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: RehabStyle.orange,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: RehabStyle.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
