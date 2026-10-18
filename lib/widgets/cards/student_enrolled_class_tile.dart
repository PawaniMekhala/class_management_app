import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/student_detail_model.dart';

class StudentEnrolledClassTile extends StatelessWidget {
  final StudentEnrolledClassModel enrolledClass;
  final VoidCallback? onTap;

  const StudentEnrolledClassTile({
    super.key,
    required this.enrolledClass,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.moduleIconBackground,
              child: Icon(Icons.groups, color: AppColors.primary, size: 17),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enrolledClass.name,
                    style: const TextStyle(
                      color: AppColors.authHeading,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${enrolledClass.code} · ${enrolledClass.paymentType}',
                    style: const TextStyle(
                      color: AppColors.authIcon,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              enrolledClass.isActive
                  ? Icons.check
                  : Icons.remove_circle_outline,
              size: 17,
              color: enrolledClass.isActive
                  ? const Color(0xFF40B76A)
                  : AppColors.authIcon,
            ),
          ],
        ),
      ),
    );
  }
}
