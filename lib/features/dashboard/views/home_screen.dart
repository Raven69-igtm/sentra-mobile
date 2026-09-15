import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:async';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/report/controllers/report_controller.dart';
import 'package:sentra/features/notification/controllers/notif_controller.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/features/dashboard/views/dashboard_screen.dart';
import 'package:sentra/features/report/views/history_screen.dart';
import 'package:sentra/features/report/views/report_screen.dart';
import 'package:sentra/features/notification/views/notification_screen.dart';
import 'package:sentra/features/auth/views/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({Key? key, this.initialIndex = 2}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _fabAnimationController;
  late AnimationController _badgeAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _badgeAnimation;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Notification badge state
  int _unreadNotificationCount = 0;
  NotificationController? _notificationController;
  StreamSubscription<List<Map<String, dynamic>>>? _notificationSubscription;

  final List<PageConfig> _pageConfigs = [
    PageConfig(
      page: HistoryPage(),
      icon: Icons.history_rounded,
      label: 'Riwayat',
      activeColor: Warna.backgroundIjo,
    ),
    PageConfig(
      page: LaporanPage(),
      icon: Icons.article_rounded,
      label: 'Laporan',
      activeColor: Warna.backgroundIjo,
    ),
    PageConfig(
      page: DashboardScreen(),
      icon: Icons.dashboard_rounded,
      label: 'Beranda',
      activeColor: Warna.backgroundIjo,
    ),
    PageConfig(
      page: NotificationPage(),
      icon: Icons.notifications_rounded,
      label: 'Notifikasi',
      activeColor: Warna.backgroundIjo,
    ),
    PageConfig(
      page: ProfileScreen(),
      icon: Icons.person_rounded,
      label: 'Profil',
      activeColor: Warna.backgroundIjo,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _pageConfigs.length - 1);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _badgeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _badgeAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(
        parent: _badgeAnimationController,
        curve: Curves.elasticInOut,
      ),
    );

    _fabAnimationController.forward();
    _startBadgeAnimation();
    _initializeNotificationController();
  }

  void _startBadgeAnimation() {
    if (_unreadNotificationCount > 0) {
      _badgeAnimationController.repeat(reverse: true);
    }
  }

  void _stopBadgeAnimation() {
    _badgeAnimationController.stop();
    _badgeAnimationController.reset();
  }

  void _initializeNotificationController() {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String? userId = userProvider.idAkun?.toString();

      if (userId != null) {
        _notificationController = NotificationController(userId);

        _notificationSubscription = _notificationController!.notificationStream
            .listen(
              (notifications) {
                int unreadCount =
                    notifications.where((notification) {
                      return notification['dibaca'] == false ||
                          notification['status'] == false ||
                          notification['status'] == 'terkirim';
                    }).length;

                updateNotificationCount(unreadCount);
              },
              onError: (error) {
                print('Error listening to notifications: $error');
              },
            );
      } else {
        print('UserID is null, cannot initialize notification controller');
      }
    } catch (e) {
      print('Error initializing notification controller: $e');
    }
  }

  Future<void> _markNotificationsAsRead() async {
    try {
      if (_notificationController != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final String? userId = userProvider.idAkun?.toString();

        if (userId != null) {
          updateNotificationCount(0);
        }
      }
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  void updateNotificationCount(int count) {
    setState(() {
      _unreadNotificationCount = count;
    });

    if (count > 0) {
      _startBadgeAnimation();
    } else {
      _stopBadgeAnimation();
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _badgeAnimationController.dispose();
    _notificationSubscription?.cancel(); 
    _notificationController?.dispose(); 
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      _fabAnimationController.reset();
      _fabAnimationController.forward();

      setState(() {
        _currentIndex = index;
      });

      if (index == 3) {
        _markNotificationsAsRead(); 
      }

      if (index == 0) {
        _refreshHistoryData();
      }
    }
  }

  void _refreshHistoryData() {
    try {
      final LaporanController laporanController = Get.find<LaporanController>();
      final int? userId =
          Provider.of<UserProvider>(context, listen: false).idAkun;

      if (userId != null) {
        laporanController.getUserReports(userId);
        print('History data refresh triggered for user: $userId');
      } else {
        print('UserID is null, cannot refresh history data');
      }
    } catch (e) {
      print('Error refreshing history data: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat ulang data riwayat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Widget _buildIconWithBadge(PageConfig config, int index, bool isActive) {
    bool isNotification = index == 3; 
    bool showBadge = isNotification && _unreadNotificationCount > 0;

    Widget icon = Icon(
      config.icon,
      size: isActive ? 32 : 28,
      color:
          isActive
              ? Colors.white
              : Warna.font?.withOpacity(0.7) ?? Colors.grey[600],
    );

    if (!showBadge) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: icon,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            icon,
            Positioned(
              right: -3,
              top: -5,
              child: AnimatedBuilder(
                animation: _badgeAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _badgeAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(
                        _unreadNotificationCount > 99 ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        _unreadNotificationCount > 99
                            ? '99+'
                            : _unreadNotificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 16),
              spreadRadius: 0,
            ),
          ],
        ),
        child: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: _currentIndex,
          height: 65,
          items:
              _pageConfigs.asMap().entries.map((entry) {
                int index = entry.key;
                PageConfig config = entry.value;
                bool isActive = index == _currentIndex;

                return _buildIconWithBadge(config, index, isActive);
              }).toList(),

          // Enhanced styling untuk transparansi
          color: Colors.white.withOpacity(0.95), // Sedikit transparan
          buttonBackgroundColor: _pageConfigs[_currentIndex].activeColor,
          backgroundColor: Colors.transparent, // Background transparan
          animationCurve: Curves.easeInOutCubic,
          animationDuration: const Duration(milliseconds: 400),

          onTap: _onTabTapped,
          letIndexChange: (index) => true,
        ),
      ),

      // Body dengan background management yang lebih baik
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.white.withOpacity(0.8),
              Colors.transparent, // Fade ke transparent di bawah
            ],
            stops: [0.0, 0.7, 1.0], // Control gradient stops
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: IndexedStack(
            key: ValueKey<int>(_currentIndex),
            index: _currentIndex,
            children: _pageConfigs.map((config) => config.page).toList(),
          ),
        ),
      ),
    );
  }
}

// Configuration class for better organization
class PageConfig {
  final Widget page;
  final IconData icon;
  final String label;
  final Color activeColor;

  const PageConfig({
    required this.page,
    required this.icon,
    required this.label,
    required this.activeColor,
  });
}
