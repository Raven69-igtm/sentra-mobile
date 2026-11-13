import 'dart:io'; // File dari path lokal (mobile/desktop)
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'pjsrk_foto_source_sheet.dart';

const _muted = Color(0xFF7A7F85);
const _border = Color(0xFFE8EBEE);
const _greenSoft = Color(0xFFE4F1E9);
const _green = Color(0xFF3F8F63);

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

    // Bottom sheet "Ambil Foto Bukti" yang sama dengan halaman
    // Permasalahan Sosial & Pengaduan Bencana (Kamera / Galeri Foto).
    final choice = await showPjsrkFotoSourceSheet(
      context,
      izinkanHapus: sudahAda,
    );

    if (choice == null || !context.mounted) return;

    if (choice == PjsrkFotoSource.hapus) {
      onChanged(index, null);
      return;
    }

    // image_picker: ImageSource.camera atau ImageSource.gallery
    final picker = ImagePicker();
    final source = choice == PjsrkFotoSource.kamera
        ? ImageSource.camera
        : ImageSource.gallery;

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