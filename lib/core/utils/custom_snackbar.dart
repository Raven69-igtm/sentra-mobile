import 'package:sentra/main.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(
    String message, {
    IconData icon = Icons.check_circle,
    String? actionText,
    Color? warna = Warna.backgroundIjo,
    VoidCallback? onAction,
    int? tinggi = 150, 
  }) {
    final context = scaffoldMessengerKey.currentState?.context;
    if (context == null) return;

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
          if (actionText != null)
            TextButton(
              onPressed: () {
                scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                onAction?.call();
              },
              child: Text(
                actionText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      margin: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).size.height - tinggi!,
        left: 20,
        right: 20,
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: warna!.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      duration: const Duration(seconds: 3),
      elevation: 6,
    );

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
