// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class MiniMapWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: SizedBox(
//           height: 200,
//           child: FlutterMap(
//             options: MapOptions(
//               center: LatLng(
//                 -7.797068,
//                 110.370529,
//               ), // Koordinat contoh (Yogyakarta)
//               zoom: 16,
//               interactiveFlags:
//                   InteractiveFlag.none, // Peta tidak bisa digerakkan
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate:
//                     'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 subdomains: ['a', 'b', 'c'],
//               ),
//               MarkerLayer(
//                 markers: [
//                   Marker(
//                     width: 50,
//                     height: 50,
//                     point: LatLng(-7.797068, 110.370529),
//                     builder:
//                         (ctx) => Icon(
//                           Icons.location_pin,
//                           size: 40,
//                           color: Colors.green,
//                         ),
//                   ),
//                   Marker(
//                     width: 35,
//                     height: 35,
//                     point: LatLng(-7.7965, 110.3710),
//                     builder: (ctx) => _iconMarker(Icons.shopping_cart),
//                   ),
//                   Marker(
//                     width: 35,
//                     height: 35,
//                     point: LatLng(-7.7978, 110.3699),
//                     builder: (ctx) => _iconMarker(Icons.shopping_cart),
//                   ),
//                   Marker(
//                     width: 35,
//                     height: 35,
//                     point: LatLng(-7.7980, 110.3707),
//                     builder: (ctx) => _iconMarker(Icons.home),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _iconMarker(IconData icon) {
//     return Container(
//       padding: EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
//         ],
//       ),
//       child: Icon(icon, size: 20, color: Colors.black),
//     );
//   }
// }
