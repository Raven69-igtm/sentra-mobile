import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'pjsrk_colors.dart';
import 'pjsrk_foto_source_sheet.dart';

/// Baris [max] kotak foto pada Pengaduan Bencana.
///
/// Ketuk kotak kosong -> bottom sheet "Ambil Foto Bukti" (Kamera / Galeri Foto)
/// yang sama dengan form Permasalahan Sosial. Ketuk ikon silang untuk menghapus.
class PjsrkPhotoPicker extends StatelessWidget {
  final List<XFile> items;
  final int max;
  final void Function(XFile file) onAdd;
  final void Function(int index) onRemove;

  const PjsrkPhotoPicker({
    super.key,
    required this.items,
    required this.max,
    required this.onAdd,
    required this.onRemove,
  });

  Future<void> _pick(BuildContext context) async {
    final choice = await showPjsrkFotoSourceSheet(context);
    if (choice == null || !context.mounted) return;
    if (choice == PjsrkFotoSource.hapus) return;

    try {
      final XFile? file = await ImagePicker().pickImage(
        source: choice == PjsrkFotoSource.kamera
            ? ImageSource.camera
            : ImageSource.gallery,
        // Kompres ringan agar upload nanti tidak terlalu besar
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file != null) onAdd(file);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memilih foto: $e',
            style: const TextStyle(fontFamily: 'Mulish'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Row(children: [
        for (int i = 0; i < max; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: i < items.length
                  ? _FilledTile(
                      file: items[i],
                      onRemove: () => onRemove(i),
                    )
                  : _AddTile(
                      denganKamera: i == 0,
                      onTap: () => _pick(context),
                    ),
            ),
          ),
        ],
      ]);
}

/// Kotak foto terisi: pratinjau gambar asli hasil kamera / galeri.
class _FilledTile extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _FilledTile({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FutureBuilder<Uint8List>(
            future: file.readAsBytes(),
            builder: (context, snap) {
              if (snap.hasData) {
                return Image.memory(
                  snap.data!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                );
              }
              return Container(
                color: const Color(0xFFE9EEF3),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 26,
                    color: PjsrkColors.muted,
                  ),
                ),
              );
            },
          ),
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
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ),
      ),
    ]);
  }
}

/// Kotak kosong berbingkai putus-putus.
/// Slot pertama memakai ikon kamera, slot berikutnya tulisan "Tambah".
class _AddTile extends StatelessWidget {
  final bool denganKamera;
  final VoidCallback onTap;

  const _AddTile({required this.denganKamera, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                denganKamera ? Icons.photo_camera_outlined : Icons.add,
                size: 28,
                color: PjsrkColors.muted,
              ),
              if (!denganKamera) ...[
                const SizedBox(height: 2),
                const Text(
                  'Tambah',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PjsrkColors.muted,
                  ),
                ),
              ],
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
