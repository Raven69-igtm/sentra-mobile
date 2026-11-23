import 'package:flutter/material.dart';
import 'package:sentra/core/theme/app_colors.dart';

/// Header ber-gradient dengan lengkungan ke bawah (concave downward)
/// di atas permukaan putih. Mendukung ilustrasi latar opsional [backgroundAsset].
class SentraCurvedHeader extends StatelessWidget {
  final Widget child;
  final double curveHeight;
  final EdgeInsetsGeometry? padding;
  final Gradient gradient;
  final String? backgroundAsset;
  final double backgroundOpacity;

  const SentraCurvedHeader({
    super.key,
    required this.child,
    this.curveHeight = 32,
    this.padding,
    this.gradient = AppColors.headerCurvedGradient,
    this.backgroundAsset,
    this.backgroundOpacity = 0.24,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final resolvedPadding =
        padding ?? EdgeInsets.fromLTRB(20, topInset + 14, 20, curveHeight + 24);

    return ClipPath(
      clipper: _CurvedHeaderClipper(curveHeight: curveHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (backgroundAsset != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Opacity(
                      opacity: backgroundOpacity,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        heightFactor: 1.0,
                        child: Image.asset(
                          backgroundAsset!,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: Padding(padding: resolvedPadding, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurvedHeaderClipper extends CustomClipper<Path> {
  final double curveHeight;

  const _CurvedHeaderClipper({required this.curveHeight});

  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + curveHeight * 0.6,
        size.width,
        size.height - curveHeight,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _CurvedHeaderClipper oldClipper) =>
      oldClipper.curveHeight != curveHeight;
}
