import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/academic_subject_model.dart';

class AcademicSubjectTile extends StatelessWidget {
  final AcademicSubjectModel subject;
  final VoidCallback onTap;

  const AcademicSubjectTile({
    super.key,
    required this.subject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.moduleIconBackground,
              child: Icon(
                subject.isModule
                    ? Icons.settings_outlined
                    : Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.authHeading,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${subject.educationLevel} · '
                    '${subject.code} · '
                    '${subject.classCount} classes',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.authIcon,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.public, color: AppColors.primary, size: 17),
          ],
        ),
      ),
    );
  }
}
