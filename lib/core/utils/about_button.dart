import 'package:flutter/material.dart';

class InfoIconWithTooltip extends StatefulWidget {
  const InfoIconWithTooltip({Key? key}) : super(key: key);

  @override
  State<InfoIconWithTooltip> createState() => _InfoIconWithTooltipState();
}

class _InfoIconWithTooltipState extends State<InfoIconWithTooltip>
    with SingleTickerProviderStateMixin {
  final GlobalKey _iconKey = GlobalKey();
  OverlayEntry? _bubble;
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  final double bubbleWidth = 250.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _showTooltip() {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final renderBox = _iconKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final iconCenterX = position.dx + (renderBox.size.width / 2);

    _bubble = OverlayEntry(
      builder:
          (context) => Positioned(
            top: position.dy - 50,
            left: iconCenterX - (bubbleWidth / 2),
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: _opacity,
                child: SlideTransition(
                  position: _offset,
                  child: Container(
                    width: bubbleWidth,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Centang opsi ini untuk mengaktifkan login dengan sidik jari di login berikutnya.",
                      style: TextStyle(
                        fontFamily: "Mulish",
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(_bubble!);

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      _controller.reverse().then((_) {
        _bubble?.remove();
        _bubble = null;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _iconKey,
      onTap: _showTooltip,
      child: Icon(
        Icons.info_outline,
        size: MediaQuery.of(context).size.width * 0.04,
        color: Colors.grey[400],
      ),
    );
  }
}
