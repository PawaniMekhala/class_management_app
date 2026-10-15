import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AppMessageType { success, error, info }

class AppMessageDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    AppMessageType type = AppMessageType.info,
  }) {
    final Color color;
    final IconData icon;

    switch (type) {
      case AppMessageType.success:
        color = const Color(0xFF22C55E);
        icon = Icons.check_circle_outline;
        break;
      case AppMessageType.error:
        color = const Color(0xFFEF4444);
        icon = Icons.error_outline;
        break;
      case AppMessageType.info:
        color = AppColors.primary;
        icon = Icons.info_outline;
        break;
    }

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 48),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF75809C)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
