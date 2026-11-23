import 'package:flutter/material.dart';
import 'package:sentra/core/widgets/sentra_bottom_nav.dart';
import 'package:sentra/features/auth/views/profile_screen.dart';
import 'package:sentra/features/dashboard/views/beranda_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  late final List<Widget> _pages = [
    const BerandaScreen(),
    ProfileScreen(onBack: _showBeranda),
  ];

  void _showBeranda() {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 1);
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SentraBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        floating: true,
        useBrandGradient: true,
      ),
    );
  }
}
