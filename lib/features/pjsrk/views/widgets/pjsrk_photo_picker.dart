import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'pjsrk_colors.dart';

/// Baris [max] kotak foto: yang terisi tampil gambar, sisanya "Tambah".
class PjsrkPhotoPicker extends StatelessWidget {
  final List<String> items;
  final int max;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const PjsrkPhotoPicker({
    super.key,
    required this.items,
    required this.max,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        for (int i = 0; i < max; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: i < items.length
                  ? _FilledTile(
                      index: i,
                      path: items[i],
                      onRemove: () => onRemove(i),
                    )
                  : _AddTile(
                      isFirst: i == 0,
                      onTap: onAdd,
                    ),
            ),
          ),
        ],
      ]);
}

/// Kotak media terisi (menampilkan preview foto asli atau ikon video)
class _FilledTile extends StatelessWidget {
  final int index;
  final String path;
  final VoidCallback onRemove;

  const _FilledTile({
    required this.index,
    required this.path,
    required this.onRemove,
  });

  bool get _isVideo {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.3gp') ||
        lower.contains('video');
  }

  Widget _buildPreview() {
    if (_isVideo) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.play_circle_fill_rounded,
              size: 32,
              color: Colors.white,
            ),
            Positioned(
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_rounded, size: 10, color: Colors.white),
                    SizedBox(width: 3),
                    Text(
                      'Video',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackPlaceholder(),
        ),
      );
    }

    final file = File(path);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackPlaceholder(),
        ),
      );
    }

    return _fallbackPlaceholder();
  }

  Widget _fallbackPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFE2E8F0),
      ),
      child: const Center(
        child: Icon(Icons.photo_camera_outlined, size: 28, color: Color(0xFF64748B)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildPreview()),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Kotak "Tambah" berbingkai putus-putus.
class _AddTile extends StatelessWidget {
  final bool isFirst;
  final VoidCallback onTap;

  const _AddTile({
    this.isFirst = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFirst ? Icons.photo_camera_outlined : Icons.add_rounded,
                  size: 26,
                  color: PjsrkColors.muted,
                ),
                const SizedBox(height: 2),
                Text(
                  isFirst ? 'Foto' : 'Tambah',
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: PjsrkColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Menggambar bingkai putus-putus berujung bulat.
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9CCD2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
            Offset.zero & size, const Radius.circular(16))
        .deflate(0.75);
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
