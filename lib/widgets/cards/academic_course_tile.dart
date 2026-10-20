import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/academic_course_model.dart';

class AcademicCourseTile extends StatelessWidget {
  final AcademicCourseModel course;
  final VoidCallback onTap;

  const AcademicCourseTile({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.moduleIconBackground,
              child: Icon(
                Icons.school_outlined,
                color: AppColors.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.authHeading,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${course.category} · '
                    '${course.durationMonths} months · '
                    '${course.moduleIds.length} modules · '
                    '${course.code}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.authIcon,
                      height: 1.4,
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
