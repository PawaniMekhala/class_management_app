import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class RegisterFab extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const RegisterFab({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      icon: const Icon(Icons.add, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
