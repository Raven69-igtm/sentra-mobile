import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/core/utils/pjsrk_photo_urls.dart';
import 'package:sentra/core/widgets/sentra_status_badge.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/chat/models/chat_model.dart';
import 'package:sentra/features/notification/controllers/notif_badge_provider.dart';
import 'package:sentra/features/pjsrk/models/pjsrk_rehab_model.dart';
import 'package:sentra/features/pjsrk/repositories/pjsrk_rehab_repository.dart';
import 'package:sentra/features/report/controllers/report_controller.dart';
import 'package:sentra/features/report/models/report_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson, toJson, and logout behave consistently', () {
      final user = UserModel.fromJson({
        'id_akun': 42,
        'notelp': '081234567890',
        'nama': 'Siti Aminah',
        'email': 'siti@contoh.test',
        'role': 'user',
        'alamat': 'Nganjuk',
        'jenis_kelamin': 'Perempuan',
      });

      expect(user.id, 42);
      expect(user.idAkun, 42);
      expect(user.nama, 'Siti Aminah');
      expect(user.toJson()['notelp'], '081234567890');
      expect(user.toJson()['jenis_kelamin'], 'Perempuan');

      final loggedOut = user.logout();
      expect(loggedOut.id, isNull);
      expect(loggedOut.notelp, isNull);
    });
  });

  group('LaporanModel', () {
    test('parses PJSRK report fields, location, photoUrls, and layananLabel', () {
      final laporan = LaporanModel.fromJson({
        'id_laporan': 'RKN000123',
        'judul': 'Pengaduan Bencana - Banjir (Bagor)',
        'kategori': 'unset',
        'layanan_pjsrk': 'pengaduan_bencana',
        'status': 'diproses',
        'created_at': '2026-11-20T08:00:00Z',
        'detail_pjsrk': {
          'alamat': 'Desa Gandu, Kec. Bagor',
          'foto': ['foto-1.jpg'],
        },
      });

      expect(laporan.id, 'RKN000123');
      expect(laporan.deskripsi, 'Pengaduan Bencana - Banjir (Bagor)');
      expect(laporan.layanan, 'pengaduan_bencana');
      expect(laporan.layananLabel, 'Pengaduan Bencana');
      expect(laporan.lokasi, 'Desa Gandu, Kec. Bagor');
      expect(laporan.fotoUrls, [
        '${ApiClient.apiOrigin}/uploads/pjsrk/RKN000123/foto-1.jpg',
      ]);
    });

    test('falls back to detail_penerima_manfaat nama for PPA report', () {
      final laporan = LaporanModel.fromJson({
        'id_laporan': 'RKN000456',
        'kategori': 'Kekerasan Fisik',
        'status': 'diterima',
        'detail_penerima_manfaat': {'nama': 'Korban Uji'},
        'detail_kasus': {'tempat_kejadian': 'Kecamatan Nganjuk'},
      });

      expect(laporan.deskripsi, 'Korban Uji');
      expect(laporan.lokasi, 'Kecamatan Nganjuk');
      expect(laporan.layanan, '');
      expect(laporan.layananLabel, 'Kekerasan Fisik');
    });
  });

  group('Chat model', () {
    test('parses integer, string, and boolean variations cleanly', () {
      final chat = Chat.fromJson({
        'id_chat': '99',
        'sender_id': 12,
        'receiver_id': '15',
        'message': 'Halo admin',
        'replied_to_id': '88',
        'sent_at': '2026-11-22 10:15:00',
        'is_read': '1',
        'is_notified': true,
      });

      expect(chat.idChat, 99);
      expect(chat.senderId, 12);
      expect(chat.receiverId, 15);
      expect(chat.repliedToId, 88);
      expect(chat.isRead, isTrue);
      expect(chat.isNotified, isTrue);
      expect(chat.isTemporary, isFalse);
      expect(chat.toJson()['id_chat'], 99);
    });
  });

  group('PjsrkPhotoUrls', () {
    test('normalizes localhost URLs to current ApiClient.apiOrigin', () {
      final urls = PjsrkPhotoUrls.resolve({
        'foto_urls': ['http://127.0.0.1:8000/uploads/pjsrk/RKN01/a.jpg'],
      }, idLaporan: 'RKN01');

      expect(urls, ['${ApiClient.apiOrigin}/uploads/pjsrk/RKN01/a.jpg']);
    });

    test('parses JSON-encoded string list in foto column', () {
      final urls = PjsrkPhotoUrls.resolve({
        'foto': '["img1.png","img2.webp"]',
      }, idLaporan: 'RKN02');

      expect(urls, [
        '${ApiClient.apiOrigin}/uploads/pjsrk/RKN02/img1.png',
        '${ApiClient.apiOrigin}/uploads/pjsrk/RKN02/img2.webp',
      ]);
    });
  });

  group('ApiException', () {
    test('extracts validation error and HTTP status from DioException', () {
      final req = RequestOptions(path: '/post-report');
      final dioErr = DioException(
        requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: req,
          statusCode: 422,
          data: {
            'message': 'Validasi gagal',
            'errors': {
              'notelp': ['Nomor telepon sudah terdaftar.'],
            },
          },
        ),
      );

      final ex = ApiException.fromDio(dioErr);
      expect(ex.statusCode, 422);
      expect(ex.message, 'Validasi gagal');
      expect(ex.isNetworkError, isFalse);
      expect(ex.errors?['notelp'], ['Nomor telepon sudah terdaftar.']);
    });

    test('maps timeout to network error', () {
      final req = RequestOptions(path: '/user');
      final ex = ApiException.fromDio(
        DioException(
          requestOptions: req,
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(ex.isNetworkError, isTrue);
      expect(ex.message, contains('timeout'));
    });
  });

  group('SentraStatusStyle', () {
    test('resolves all 6 backend statuses including Laporan Dalam Proses and dirujuk', () {
      expect(SentraStatusStyle.resolve('dikirim').label, 'Terkirim');
      expect(SentraStatusStyle.resolve('diterima').label, 'Diterima');
      expect(SentraStatusStyle.resolve('diproses').label, 'Diproses');
      expect(
        SentraStatusStyle.resolve('Laporan Dalam Proses').label,
        'Diproses',
      );
      expect(SentraStatusStyle.resolve('selesai').label, 'Selesai');
      expect(SentraStatusStyle.resolve('ditolak').label, 'Ditolak');
      expect(SentraStatusStyle.resolve('dirujuk').label, 'Dirujuk');
    });
  });

  group('LaporanController (Provider)', () {
    test('resets state cleanly on logout', () {
      final controller = LaporanController();
      addTearDown(controller.dispose);

      controller.updateSearchResults([
        LaporanModel(
          id: 'RKN001',
          kategori: 'Lainnya',
          deskripsi: 'Tes',
          status: 'dikirim',
          createdAt: DateTime(2026, 11, 20),
        ),
      ]);
      expect(controller.laporanList, hasLength(1));

      controller.reset();
      expect(controller.laporanList, isEmpty);
      expect(controller.trackingStatus, isEmpty);
      expect(controller.errorMessage, isEmpty);
    });
  });

  group('NotificationBadgeProvider', () {
    test('loads unread count, formats 99+, decrements, and resets cleanly', () async {
      var mockUnread = 4;
      final provider = NotificationBadgeProvider(
        unreadFetcher: (_) async => mockUnread,
      );
      addTearDown(provider.dispose);

      provider.startForUser(10, pollInterval: const Duration(hours: 1));
      await Future<void>.delayed(Duration.zero);

      expect(provider.unreadCount, 4);
      expect(provider.hasUnread, isTrue);
      expect(provider.badgeText, '4');

      provider.decrement();
      expect(provider.unreadCount, 3);

      provider.syncUnreadCount(125);
      expect(provider.badgeText, '99+');

      provider.syncUnreadCount(-3);
      expect(provider.unreadCount, 0);
      expect(provider.hasUnread, isFalse);

      mockUnread = 7;
      await provider.refresh();
      expect(provider.unreadCount, 7);

      provider.reset();
      expect(provider.unreadCount, 0);
      expect(provider.activeUserId, isNull);
    });
  });

  group('PjsrkRehabRepository', () {
    test('builds multipart form data from XFile bytes without dart:io', () async {
      final repo = PjsrkRehabRepository();
      final model = PjsrkRehabModel(
        jenisRehabilitasi: 'Tunawisma',
        jumlahPenerima: 1,
        jenisKelamin: 'Laki-laki',
        kelompokUsia: 'Dewasa',
        kondisiSaatDitemukan: 'Sakit',
        ciriCiri: 'Baju biru',
        rahasia: true,
        alamat: 'Jl. Gatot Subroto, Nganjuk',
        latitude: -7.59458,
        longitude: 111.89536,
        kontak: '081234567890',
      );

      final fotoPng = XFile.fromData(
        Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]),
        name: 'bukti.png',
        path: 'bukti.png',
        mimeType: 'image/png',
      );
      final fotoNoExt = XFile.fromData(
        Uint8List.fromList([255, 216, 255, 224]),
        name: 'blob-upload',
      );

      final form = await repo.buildFormData(
        idAkun: 99,
        data: model,
        foto: [fotoPng, fotoNoExt],
      );

      expect(form.files, hasLength(2));
      expect(form.files[0].key, 'foto[]');
      expect(form.files[0].value.filename, 'bukti.png');
      expect(form.files[0].value.contentType?.mimeType, 'image/png');
      expect(form.files[1].key, 'foto[]');
      expect(form.files[1].value.filename, endsWith('.jpg'));
      expect(form.files[1].value.contentType?.mimeType, 'image/jpeg');
    });
  });
}
