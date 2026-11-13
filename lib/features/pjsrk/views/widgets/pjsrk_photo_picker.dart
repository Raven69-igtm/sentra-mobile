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
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: i < items.length
                  ? _FilledTile(index: i, onRemove: () => onRemove(i))
                  : _AddTile(onTap: onAdd),
            ),
          ),
        ],
      ]);
}

const _gradients = [
  [Color(0xFFD9E3F0), Color(0xFFB5C9DE)], // biru
  [Color(0xFFC9D9C1), Color(0xFF9DB88F)], // hijau
];

/// Kotak foto terisi (sementara warna tiruan).
/// TODO: kalau sudah pakai image_picker, ganti isinya dengan Image.file(...).
class _FilledTile extends StatelessWidget {
  final int index;
  final VoidCallback onRemove;
  const _FilledTile({required this.index, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[index % _gradients.length];
    return Stack(children: [
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: index == 0
              ? const Center(
                  child: Icon(Icons.photo_camera_outlined,
                      size: 30, color: Colors.white))
              : null,
        ),
      ),
      Positioned(
        top: 4,
        right: 4,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
                color: Colors.black45, shape: BoxShape.circle),
            child: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ),
      ),
    ]);
  }
}

/// Kotak "Tambah" berbingkai putus-putus.
class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add, size: 28, color: PjsrkColors.muted),
              SizedBox(height: 2),
              Text('Tambah',
                  style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PjsrkColors.muted)),
            ]),
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