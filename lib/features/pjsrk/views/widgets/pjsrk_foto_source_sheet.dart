import 'package:flutter/material.dart';

/// Pilihan sumber foto pada bottom sheet "Ambil Foto Bukti".
enum PjsrkFotoSource { kamera, galeri, hapus }

const _dark = Color(0xFF252525);
const _muted = Color(0xFF7A7F85);
const _orange = Color(0xFFD6762E);
const _orangeSoft = Color(0xFFFFF2E6);
const _greenSoft = Color(0xFFE4F1E9);
const _greenIcon = Color(0xFF2E7D32);
const _redSoft = Color(0xFFFDECEC);
const _redText = Color(0xFFD32F2F);

/// Bottom sheet "Ambil Foto Bukti" — satu desain untuk form Permasalahan
/// Sosial, Rehabilitasi Sosial, dan Pengaduan Bencana.
///
/// Opsi yang selalu tersedia: Kamera dan Galeri Foto. Opsi Hapus hanya muncul
/// bila [izinkanHapus] bernilai true (slot foto sudah terisi).
Future<PjsrkFotoSource?> showPjsrkFotoSourceSheet(
  BuildContext context, {
  bool izinkanHapus = false,
}) {
  return showModalBottomSheet<PjsrkFotoSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ambil Foto Bukti',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih dari kamera langsung atau pilih dari galeri perangkat Anda',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 12.5,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 18),

              // Opsi 1: Kamera langsung
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _orangeSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: _orange,
                  ),
                ),
                title: const Text(
                  'Kamera',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: _dark,
                  ),
                ),
                subtitle: const Text(
                  'Ambil foto bukti langsung menggunakan kamera HP',
                  style: TextStyle(fontFamily: 'Mulish', fontSize: 12),
                ),
                onTap: () => Navigator.pop(ctx, PjsrkFotoSource.kamera),
              ),
              const Divider(height: 16),

              // Opsi 2: Galeri foto
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _greenSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: _greenIcon,
                  ),
                ),
                title: const Text(
                  'Galeri Foto',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: _dark,
                  ),
                ),
                subtitle: const Text(
                  'Pilih foto kejadian dari penyimpanan / galeri',
                  style: TextStyle(fontFamily: 'Mulish', fontSize: 12),
                ),
                onTap: () => Navigator.pop(ctx, PjsrkFotoSource.galeri),
              ),

              // Opsi 3: Hapus foto (hanya bila slot sudah terisi)
              if (izinkanHapus) ...[
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _redSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: _redText,
                    ),
                  ),
                  title: const Text(
                    'Hapus Foto',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: _redText,
                    ),
                  ),
                  subtitle: const Text(
                    'Kosongkan slot ini untuk memilih foto lain',
                    style: TextStyle(fontFamily: 'Mulish', fontSize: 12),
                  ),
                  onTap: () => Navigator.pop(ctx, PjsrkFotoSource.hapus),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
