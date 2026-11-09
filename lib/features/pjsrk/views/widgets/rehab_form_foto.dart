import 'dart:io'; // File dari path lokal (mobile/desktop)
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const _muted = Color(0xFF7A7F85);
const _border = Color(0xFFE8EBEE);
const _greenSoft = Color(0xFFE4F1E9);
const _green = Color(0xFF3F8F63);
const _orange = Color(0xFFD6762E);

// ============================================================
// BARIS 4 SLOT FOTO
// - Ketuk slot kosong → pilih sumber (Kamera / Galeri / File)
// - Ketuk slot terisi → hapus foto
// - image_picker bekerja di:
//     HP  → kamera + galeri
//     Laptop (Windows/macOS/Linux) → file picker gambar
//     Web → file picker (terbatas)
// ============================================================
class RehabFotoRow extends StatelessWidget {
  /// Daftar foto yang sudah dipilih (null = slot kosong)
  /// Kita pakai XFile dari image_picker (lintas platform)
  final List<XFile?> photos;

  /// Dipanggil saat foto di satu index berubah (bisa null = dihapus)
  final void Function(int index, XFile? file) onChanged;

  const RehabFotoRow({
    super.key,
    required this.photos,
    required this.onChanged,
  });

  // ----------------------------------------------------------
  // TAMPILKAN BOTTOM SHEET: Kamera / Galeri / Hapus
  // ----------------------------------------------------------
  Future<void> _pick(BuildContext context, int index) async {
    final sudahAda = photos[index] != null;

    // Jika sudah ada foto → tanya mau hapus atau ganti
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Handle strip
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pilih sumber foto',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),

              // Kamera (utama di HP; di desktop bisa tidak tersedia)
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: _orange),
                  title: const Text('Kamera',
                      style: TextStyle(fontFamily: 'Mulish')),
                  onTap: () => Navigator.pop(ctx, 'camera'),
                ),

              // Galeri / File (HP & laptop)
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: _green),
                title: Text(
                  kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS
                      ? 'Pilih file gambar'
                      : 'Galeri',
                  style: const TextStyle(fontFamily: 'Mulish'),
                ),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),

              // Hapus jika slot sudah terisi
              if (sudahAda)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Hapus foto',
                      style: TextStyle(fontFamily: 'Mulish', color: Colors.red)),
                  onTap: () => Navigator.pop(ctx, 'delete'),
                ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (choice == null) return;

    if (choice == 'delete') {
      onChanged(index, null);
      return;
    }

    // image_picker: ImageSource.camera atau ImageSource.gallery
    final picker = ImagePicker();
    final source =
        choice == 'camera' ? ImageSource.camera : ImageSource.gallery;

    try {
      final file = await picker.pickImage(
        source: source,
        // Kompres ringan agar upload nanti tidak terlalu besar
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file != null) {
        onChanged(index, file);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memilih foto: $e',
              style: const TextStyle(fontFamily: 'Mulish'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final file = photos[i];
        final has = file != null;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Material(
                color: has ? _greenSoft : const Color(0xFFF0F2F4),
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _pick(context, i),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: has ? _green.withOpacity(0.4) : _border,
                      ),
                    ),
                    // Jika ada foto → tampilkan preview; jika tidak → ikon
                    child: has
                        ? _buildPreview(file!)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                i == 0
                                    ? Icons.camera_alt_outlined
                                    : Icons.add_rounded,
                                size: 22,
                                color: _muted,
                              ),
                              if (i > 0) ...[
                                const SizedBox(height: 2),
                                const Text(
                                  'Tambah',
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 10,
                                    color: _muted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Preview gambar:
  /// - Mobile/Desktop: Image.file
  /// - Web: Image.network (blob URL dari XFile)
  Widget _buildPreview(XFile file) {
    if (kIsWeb) {
      // Di web, XFile.path adalah blob URL
      return Image.network(file.path, fit: BoxFit.cover);
    }
    return Image.file(File(file.path), fit: BoxFit.cover);
  }
}