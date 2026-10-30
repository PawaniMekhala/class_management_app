import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/student_model.dart';

class DistributionStudentCard extends StatelessWidget {
  final StudentModel student;

  const DistributionStudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE8ECFF),
              child: Text(
                student.name.isEmpty ? '?' : student.name[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.authHeading,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${student.studentCode} · ${student.grade}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.authIcon,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
