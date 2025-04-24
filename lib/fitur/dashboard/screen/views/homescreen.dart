import 'package:SENTRA/utils/color.dart';
// import 'package:SENTRA/utils/navbar.dart';
import 'package:SENTRA/fitur/dashboard/screen/views/dashboard.dart';
import 'package:SENTRA/fitur/notifikasi/screen/views/history.dart';
import 'package:SENTRA/fitur/laporan/screen/views/laporan.dart';
import 'package:SENTRA/fitur/notifikasi/screen/views/notification.dart';
import 'package:SENTRA/fitur/authentikasi/screen/views/profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  HomeScreen({this.initialIndex = 2});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Ambil index dari parameter
  }

  final List<Widget> _pages = [
    HistoryPage(),
    LaporanPage(),
    DashboardScreen(),
    NotificationPage(),
    ProfileScreen(),
  ];

  // void _onTabTapped(int index) {
  //   setState(() {
  //     _currentIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _currentIndex,
        items: <Widget>[
          Icon(Icons.history, size: 30, color: Warna.font),
          Icon(Icons.article, size: 30, color: Warna.font),
          Icon(Icons.home, size: 30, color: Warna.font),
          Icon(Icons.notifications, size: 30, color: Warna.font),
          Icon(Icons.account_circle, size: 30, color: Warna.font),
        ],
        color: const Color.fromARGB(255, 254, 254, 254),
        buttonBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        backgroundColor: Warna.backgroundIjo,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    );
  }
}
