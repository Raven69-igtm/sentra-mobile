import 'package:flutter/material.dart';

class CustomRoundedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final double horizontalMargin; 
  final bool isFullWidth;
  final double iconSize;

  const CustomRoundedButton({
    Key? key,
    required this.text,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.horizontalMargin = 20,
    this.isFullWidth = true,
    this.iconSize = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(0),
              topRight: Radius.circular(0),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: iconSize),
                SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontFamily: "Mulish",
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
