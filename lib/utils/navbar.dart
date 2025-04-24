// import 'package:flutter/material.dart';
// import '../utils/color.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// class Navbar extends StatefulWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const Navbar({Key? key, required this.currentIndex, required this.onTap})
//     : super(key: key);

//   @override
//   _NavbarState createState() => _NavbarState();
// }

// class _NavbarState extends State<Navbar> {
//   int _page = 0;
//   GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: const BorderRadius.only(
//         topLeft: Radius.circular(20),
//         topRight: Radius.circular(20),
//       ),
//       child: Material(
//         elevation: 10,
//         shadowColor: Colors.black.withOpacity(0.3),
//         child: CurvedNavigationBar(
//           key: _bottomNavigationKey,
//           index: widget.currentIndex,
//           items: <Widget>[
//             Icon(Icons.add, size: 30),
//             Icon(Icons.list, size: 30),
//             Icon(Icons.compare_arrows, size: 30),
//             Icon(Icons.call_split, size: 30),
//             Icon(Icons.perm_identity, size: 30),
//           ],
//           color: Warna.backgroundIjo,
//           buttonBackgroundColor: Warna.backgroundIjo,
//           backgroundColor: const Color.fromARGB(255, 248, 249, 250),
//           animationCurve: Curves.easeInOut,
//           animationDuration: Duration(milliseconds: 600),
//           onTap: (index) {
//             setState(() {
//               _page = index;
//             });
//           },
//           letIndexChange: (index) => true,
//         ),
//       ),
//     );
//   }
// }
