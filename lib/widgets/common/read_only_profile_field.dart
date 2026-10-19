import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ReadOnlyProfileField extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final int maxLines;

  const ReadOnlyProfileField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null || value!.trim().isEmpty
        ? 'Not provided'
        : value!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        initialValue: displayValue,
        readOnly: true,
        enabled: false,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.authHeading, fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.authIcon, fontSize: 11),
          prefixIcon: Icon(icon, color: AppColors.authIcon, size: 19),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.profileDivider),
          ),
        ),
      ),
    );
  }
}
