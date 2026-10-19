import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PrivacySettingTile extends StatelessWidget {
  final String title;
  final String description;
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const PrivacySettingTile({
    super.key,
    required this.title,
    required this.description,
    required this.isPublic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.authHeading,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
              ),
            ],
          ),
        ),
        Switch(
          value: isPublic,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }
}
