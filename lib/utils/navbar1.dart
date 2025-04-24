import 'package:flutter/material.dart';
import '../utils/color.dart';

class Navbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Navbar({Key? key, required this.currentIndex, required this.onTap})
    : super(key: key);

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
          selectedItemColor: Warna.backgroundIjo,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          showSelectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notification',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
