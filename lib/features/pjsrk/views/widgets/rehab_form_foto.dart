import 'dart:typed_data';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentra/features/pjsrk/views/widgets/rehab_style.dart';

/// Foto yang sudah dipilih. Bytes dibaca sekali agar preview bekerja sama di
/// Android, iOS, desktop, dan Web (tanpa dart:io).
class RehabPhoto {
  final XFile file;
  final Uint8List bytes;
  const RehabPhoto({required this.file, required this.bytes});
}

enum _PhotoAction { camera, gallery, delete }

/// Baris 4 slot foto (maks 4).
/// - Slot kosong  -> pilih Kamera / Galeri
/// - Slot terisi  -> ganti (Kamera / Galeri) atau Hapus
class RehabFotoRow extends StatelessWidget {
  static const int maxPhotos = 4;

  final List<RehabPhoto?> photos;
  final void Function(int index, RehabPhoto? photo) onChanged;

  const RehabFotoRow({
    super.key,
    required this.photos,
    required this.onChanged,
  });

  /// Kamera hanya ditawarkan di HP. Di Web/desktop cukup pilih file.
  static bool get _canUseCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _onSlotTap(BuildContext context, int index) async {
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5D9DD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Pilih sumber foto',
                style: TextStyle(
                  fontFamily: RehabStyle.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: RehabStyle.dark,
                ),
              ),
              const SizedBox(height: 6),
              if (_canUseCamera)
                _SheetOption(
                  icon: Icons.camera_alt_outlined,
                  color: RehabStyle.orange,
                  label: 'Kamera',
                  onTap: () => Navigator.pop(ctx, _PhotoAction.camera),
                ),
              _SheetOption(
                icon: Icons.photo_library_outlined,
                color: RehabStyle.green,
                label: _canUseCamera ? 'Galeri' : 'Pilih file gambar',
                onTap: () => Navigator.pop(ctx, _PhotoAction.gallery),
              ),
              if (photos[index] != null)
                _SheetOption(
                  icon: Icons.delete_outline_rounded,
                  color: RehabStyle.red,
                  label: 'Hapus foto',
                  onTap: () => Navigator.pop(ctx, _PhotoAction.delete),
                ),
            ],
          ),
        ),
      ),
    );

    if (action == null) return;
    if (action == _PhotoAction.delete) {
      onChanged(index, null);
      return;
    }

    try {
      final file = await ImagePicker().pickImage(
        source: action == _PhotoAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null) return; // user membatalkan
      final bytes = await file.readAsBytes();
      onChanged(index, RehabPhoto(file: file, bytes: bytes));
    } on Exception {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal memilih foto',
            style: TextStyle(fontFamily: RehabStyle.fontFamily),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(maxPhotos, (i) {
        final photo = photos[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < maxPhotos - 1 ? 8 : 0),
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onSlotTap(context, i),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: photo != null
                        ? const Color(0xFFE4F1E9)
                        : const Color(0xFFF0F2F4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: photo != null
                          ? RehabStyle.green.withAlpha(100)
                          : RehabStyle.border,
                    ),
                  ),
                  child: photo != null
                      ? Image.memory(
                          photo.bytes,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : _EmptySlot(index: i),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final int index;
  const _EmptySlot({required this.index});

  @override
  Widget build(BuildContext context) {
    // Slot 0 = kamera, slot 1 = slot foto, slot 2-3 = tambah.
    final icon = switch (index) {
      0 => Icons.camera_alt_outlined,
      1 => Icons.image_outlined,
      _ => Icons.add_rounded,
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: RehabStyle.muted),
        if (index >= 2) ...[
          const SizedBox(height: 2),
          const Text(
            'Tambah',
            style: TextStyle(
              fontFamily: RehabStyle.fontFamily,
              fontSize: 10,
              color: RehabStyle.muted,
            ),
          ),
        ],
      ],
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontFamily: RehabStyle.fontFamily,
                fontSize: 14,
                color: color == RehabStyle.red ? color : RehabStyle.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
