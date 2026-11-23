import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/core/network/endpoints.dart';

/// Provider ringan untuk memantau jumlah notifikasi belum dibaca (`status == 'terkirim'`)
/// agar ikon lonceng di Beranda dapat menampilkan badge angka merah secara real-time.
class NotificationBadgeProvider extends ChangeNotifier {
  final Future<int> Function(int userId)? _unreadFetcher;

  int _unreadCount = 0;
  int? _userId;
  Timer? _pollTimer;
  bool _isFetching = false;

  NotificationBadgeProvider({Future<int> Function(int userId)? unreadFetcher})
    : _unreadFetcher = unreadFetcher;

  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;
  String get badgeText => _unreadCount > 99 ? '99+' : '$_unreadCount';
  int? get activeUserId => _userId;

  /// Mulai memantau notifikasi untuk [userId] dengan polling berkala.
  void startForUser(
    int userId, {
    Duration pollInterval = const Duration(seconds: 15),
  }) {
    if (userId <= 0) return;
    if (_userId == userId && _pollTimer != null && _pollTimer!.isActive) {
      refresh();
      return;
    }

    _userId = userId;
    _pollTimer?.cancel();
    refresh();
    _pollTimer = Timer.periodic(pollInterval, (_) => refresh());
  }

  /// Muat ulang jumlah notifikasi belum dibaca dari server.
  Future<void> refresh() async {
    final int? uid = _userId;
    if (uid == null || uid <= 0 || _isFetching) return;

    _isFetching = true;
    try {
      final int count =
          _unreadFetcher != null
              ? await _unreadFetcher(uid)
              : await _fetchUnreadFromApi(uid);
      syncUnreadCount(count);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        stop();
      }
    } catch (_) {
      // Kegagalan jaringan bersifat non-fatal; pertahankan angka terakhir.
    } finally {
      _isFetching = false;
    }
  }

  Future<int> _fetchUnreadFromApi(int userId) async {
    final response = await ApiClient.getRequest(
      Endpoints.notifications,
      params: {'user_id': userId.toString()},
    );

    if (response.statusCode != 200) return _unreadCount;

    final dynamic raw = response.data;
    final List<dynamic> items =
        raw is List
            ? raw
            : (raw is Map && raw['data'] is List
                ? raw['data'] as List<dynamic>
                : const <dynamic>[]);

    int unread = 0;
    for (final dynamic item in items) {
      if (item is Map && item['status']?.toString() == 'terkirim') {
        unread++;
      }
    }
    return unread;
  }

  /// Sinkronkan angka unread langsung dari halaman Notifikasi (optimistic UI).
  void syncUnreadCount(int count) {
    final int normalized = count < 0 ? 0 : count;
    if (_unreadCount != normalized) {
      _unreadCount = normalized;
      notifyListeners();
    }
  }

  /// Kurangi 1 angka unread seketika saat 1 notifikasi dibaca/dihapus.
  void decrement() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Bersihkan state saat logout atau sesi berakhir.
  void reset() {
    stop();
    _userId = null;
    if (_unreadCount != 0) {
      _unreadCount = 0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
