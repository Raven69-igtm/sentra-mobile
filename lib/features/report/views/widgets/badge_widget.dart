import 'package:sentra/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class TrackingBadge extends StatelessWidget {
  final String status;

  const TrackingBadge({super.key, required this.status});

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
      case 'dikirim':
        icon = Icons.send;
        break;
      case 'diterima':
        icon = Icons.fact_check_outlined;
        break;
      case 'diproses':
        icon = Icons.autorenew;
        break;
      case 'selesai':
        icon = Icons.check_rounded;
        break;
      case 'dirujuk':
        icon = Icons.forward_to_inbox_rounded;
        break;
      default:
        icon = Icons.help_outline; 
    }

    return ClipPath(
      clipper: CustomBadgeClipper(),
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          color: Warna.backgroundIjo,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 45),
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

