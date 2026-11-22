import 'package:flutter/material.dart';

/// Kartu layanan PJSRK dengan ikon lembut, bayangan halus, dan
/// feedback visual saat ditekan.
class PjsrkFeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const PjsrkFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  State<PjsrkFeatureCard> createState() => _PjsrkFeatureCardState();
}

class _PjsrkFeatureCardState extends State<PjsrkFeatureCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.975 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDF0F3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onTap,
            onHighlightChanged: (value) {
              setState(() => _pressed = value);
            },
            mouseCursor: SystemMouseCursors.click,
            splashColor: widget.iconColor.withAlpha(26),
            highlightColor: widget.iconColor.withAlpha(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Icon(widget.icon, color: widget.iconColor, size: 25),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 12,
                            height: 1.45,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withAlpha(_pressed ? 34 : 18),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: widget.iconColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
