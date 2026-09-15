import 'package:flutter/material.dart';
import 'package:sentra/core/utils/app_colors.dart';

class Navbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Navbar({super.key, required this.currentIndex, required this.onTap});

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Material(
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.3),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          backgroundColor: const Color.fromARGB(255, 255, 254, 254),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          showSelectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.history, 0),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.article, 1),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.home, 2),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.notifications, 3),
              label: 'Notification',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.account_circle, 4),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    return ShaderMask(
      shaderCallback:
          (bounds) => LinearGradient(
            colors: [
              Warna.backgroundIjo,
              Color.lerp(Warna.backgroundIjo, Colors.black, 0.3)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
      child: Icon(
        icon,
        color:
            widget.currentIndex == index
                ? Colors.white
                : null, 
      ),
    );
  }
}
