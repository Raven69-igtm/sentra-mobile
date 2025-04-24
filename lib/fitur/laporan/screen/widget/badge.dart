import 'package:SENTRA/utils/color.dart';
import 'package:flutter/material.dart';

class TrackingBadge extends StatelessWidget {
  final String status;

  const TrackingBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBadge(status),
        SizedBox(height: 4),
      ],
    );
  }

  Widget _buildBadge(String status) {
    IconData icon;

    switch (status) {
      case 'Dikirim':
        icon = Icons.send;
        break;
      case 'Diterima':
        icon = Icons.check_box;
        break;
      case 'Diproses':
        icon = Icons.autorenew;
        break;
      case 'Selesai':
        icon = Icons.check_circle;
        break;
      default:
        icon = Icons.help_outline; 
    }

    return ClipPath(
      clipper: CustomBadgeClipper(),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Warna.backgroundIjo,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}


class CustomBadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(
      size.width,
      size.height * 0.85,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.95,
      size.width * 0.5,
      size.height * 0.98,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.95, 
      0,
      size.height * 0.85,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

