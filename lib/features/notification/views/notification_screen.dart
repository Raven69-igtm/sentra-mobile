import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/notification/controllers/notif_controller.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  final Function(int)? onBadgeCountChanged;

  const NotificationPage({super.key, this.onBadgeCountChanged});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  NotificationController? _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  // Local state untuk optimistic updates
  List<Map<String, dynamic>> _notifications = [];
  String? _currentUserId;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _initializeController(String userId) {
    if (_currentUserId != userId) {
      _controller?.dispose();

      _controller = NotificationController(userId);
      _currentUserId = userId;

      print('NotificationController initialized for user: $userId');
    }
  }

  Color _getTitleColor(String? title) {
    if (title == null) return Colors.grey[800]!;

    final parts = title.split(' - ');
    if (parts.length < 2) {
      switch (title.toLowerCase()) {
        case 'pesan baru':
          return Colors.blue[700]!;
        default:
          return Colors.grey[800]!;
      }
    }

    final status = parts[1].trim().toLowerCase();
    switch (status) {
      case 'laporan terkirim':
        return Colors.orange[700]!;
      case 'laporan diterima':
        return Colors.blue[700]!;
      case 'laporan diproses':
        return Colors.deepOrange[700]!;
      case 'laporan selesai':
        return Colors.green[700]!;
      default:
        return Colors.grey[800]!;
    }
  }

  IconData _getNotificationIcon(String? title) {
    if (title == null) return Icons.notifications;

    final parts = title.split(' - ');
    if (parts.length < 2) {
      switch (title.toLowerCase()) {
        case 'pesan baru':
          return Icons.message;
        default:
          return Icons.notifications;
      }
    }

    final status = parts[1].trim().toLowerCase();
    switch (status) {
      case 'laporan terkirim':
        return Icons.send;
      case 'laporan diterima':
        return Icons.inbox;
      case 'laporan diproses':
        return Icons.hourglass_empty;
      case 'laporan selesai':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildFilterTabs() {
    final tabs = ['Semua', 'Notif Pesan', 'Notif Laporan'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                tabs.map((tab) {
                  final isSelected = _selectedFilter == tab;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilter = tab;
                        });
                        _updateBadgeCount();
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Warna.backgroundIjo.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 14,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? Warna.backgroundIjo
                                      : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(String? title) {
    final color = _getTitleColor(title);
    return color.withOpacity(0.1);
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Baru saja';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} menit lalu';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else {
        return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
      }
    } catch (e) {
      return dateString;
    }
  }

  // Update badge count dan notify HomeScreen
  void _updateBadgeCount() {
    final unreadCount =
        _notifications
            .where(
              (notif) => notif['status'] == false || notif['dibaca'] == false,
            )
            .length;

    // Notify HomeScreen untuk update badge
    widget.onBadgeCountChanged?.call(unreadCount);
  }

  // Optimistic mark as read
  Future<void> _markAsReadOptimistic(Map<String, dynamic> notif) async {
    final String? notificationId = notif['id']?.toString();

    if (notificationId == null || _controller == null) return;

    // Store original state for rollback
    final originalStatus = notif['status'];

    // 1. INSTANT UI UPDATE (Optimistic)
    setState(() {
      notif['status'] = true; // Mark as read immediately
    });

    // 2. Update badge count immediately
    _updateBadgeCount();

    // 3. Haptic feedback
    HapticFeedback.lightImpact();

    // 4. Background database update
    try {
      await _controller!.markAsRead(notificationId);

      // Success feedback
      _showReadFeedback();
      print('Notification marked as read successfully: $notificationId');
    } catch (e) {
      print('Error marking notification as read: $e');

      // 5. ROLLBACK on error
      setState(() {
        notif['status'] = originalStatus; // Revert to original state
      });

      // Update badge count back
      _updateBadgeCount();

      // Show error feedback
      _showErrorFeedback();
    }
  }

  void _showReadFeedback() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Notifikasi ditandai sudah dibaca',
              style: TextStyle(fontFamily: 'Mulish', fontSize: 14),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green[600],
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorFeedback() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Gagal memperbarui status notifikasi',
              style: TextStyle(fontFamily: 'Mulish', fontSize: 14),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.red[600],
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.user == null) {
                  return _buildUserNotFoundState();
                }

                final userId = userProvider.user!.idAkun.toString();
                _initializeController(userId);

                if (_controller == null) {
                  return _buildLoadingState();
                }

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _controller!.notificationStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildErrorState();
                    }

                    if (!snapshot.hasData) {
                      return _buildLoadingState();
                    }

                    _notifications = List.from(snapshot.data!);
                    // Apply filter based on _selectedFilter
                    if (_selectedFilter == 'Notif Pesan') {
                      _notifications =
                          _notifications
                              .where(
                                (notif) =>
                                    notif['title']?.toLowerCase() ==
                                    'pesan baru',
                              )
                              .toList();
                    } else if (_selectedFilter == 'Notif Laporan') {
                      _notifications =
                          _notifications
                              .where(
                                (notif) =>
                                    notif['title']?.toLowerCase().contains(
                                      'laporan',
                                    ) ??
                                    false,
                              )
                              .toList();
                    }

                    _notifications.sort((a, b) {
                      final dateA =
                          DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
                      final dateB =
                          DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
                      return dateB.compareTo(dateA);
                    });

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _updateBadgeCount();
                    });

                    if (_notifications.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildNotificationList(_notifications);
                  },
                );
              },
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: _buildFilterTabs()),
        ],
      ),
    );
  }

  Widget _buildUserNotFoundState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_outlined,
                color: Colors.orange[400],
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'User Tidak Ditemukan',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan login terlebih dahulu untuk melihat notifikasi',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Warna.backgroundIjo, Warna.backgroundBiru],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      title: Row(
        children: [
          Image.asset('assets/logo/Image.png', height: 30, width: 30),
          const SizedBox(width: 8),
          const Text(
            "SENTRA",
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const Text(
            "Notifikasi",
            style: TextStyle(
              fontFamily: "Mulish",
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red[400],
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gagal Memuat Notifikasi',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Terjadi kesalahan saat mengambil data notifikasi',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: Warna.backgroundIjo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: Warna.backgroundIjo,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Memuat notifikasi...',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Notifikasi',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi akan muncul di sini ketika ada pembaruan terkait laporan Anda',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> notifications) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
      itemCount: notifications.length + 1,
      itemBuilder: (context, index) {
        if (index == notifications.length) {
          return SizedBox(height: screenHeight * 0.05);
        }
        final notif = notifications[index];
        return _buildNotificationCard(notif, index);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, int index) {
    final isUnread = notif['status'] == false;
    final titleColor = _getTitleColor(notif['title']);
    final icon = _getNotificationIcon(notif['title']);
    final iconBgColor = _getIconBackgroundColor(notif['title']);

    return Dismissible(
      key: Key(notif['id']?.toString() ?? '$index'),
      background: _buildDismissBackground(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmation(notif),
      onDismissed: (direction) => _handleNotificationDismiss(notif),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isUnread ? () => _markAsReadOptimistic(notif) : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: isUnread ? Colors.blue[50] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnread ? Colors.blue[200]! : Colors.grey[200]!,
                  width: isUnread ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: titleColor, size: 24),
                    ),
                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notif['title'] ?? 'Notifikasi',
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 16,
                                    fontWeight:
                                        isUnread
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.red[500],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(notif['date'] ?? ''),
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notif['message'] ?? '',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            'Hapus',
            style: TextStyle(
              fontFamily: 'Mulish',
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(Map<String, dynamic> notif) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.red[400]),
                const SizedBox(width: 8),
                const Text(
                  'Hapus Notifikasi',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus notifikasi "${notif['title']}"?',
              style: const TextStyle(fontFamily: 'Mulish', fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hapus',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handleNotificationDismiss(Map<String, dynamic> notif) async {
    if (_controller == null) return;

    final removedNotif = Map<String, dynamic>.from(notif);
    final notifId = notif['id']?.toString();

    if (notifId == null) {
      _showErrorSnackBar('Gagal memproses: ID notifikasi tidak valid');
      return;
    }

    try {
      await _controller!.deleteNotification(notifId);
      _showSuccessSnackBar(
        'Notifikasi "${removedNotif['title']}" dihapus',
        removedNotif,
      );
      _updateBadgeCount();
    } catch (e) {
      _showErrorSnackBar('Gagal menghapus notifikasi: $e');
      await _controller!.restoreNotification(removedNotif);
    }
  }

  void _showSuccessSnackBar(String message, Map<String, dynamic> removedNotif) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Urungkan',
          textColor: Colors.white,
          onPressed: () async {
            if (_controller != null) {
              await _controller!.restoreNotification(removedNotif);
            }
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller?.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
