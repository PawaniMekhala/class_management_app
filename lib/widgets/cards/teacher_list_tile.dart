import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/teacher_model.dart';

class TeacherListTile extends StatelessWidget {
  final TeacherModel teacher;
  final VoidCallback onTap;
  final ValueChanged<String> onMenuSelected;

  const TeacherListTile({
    super.key,
    required this.teacher,
    required this.onTap,
    required this.onMenuSelected,
  });

  String get _initials {
    final parts = teacher.name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = teacher.subjects.join(', ');

    final subtitle = [
      teacher.teacherCode,
      if (subjects.isNotEmpty) subjects,
      if (teacher.instituteCount > 1) '${teacher.instituteCount} institutes',
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.moduleIconBackground,
              backgroundImage:
                  teacher.photoUrl != null && teacher.photoUrl!.isNotEmpty
                  ? NetworkImage(teacher.photoUrl!)
                  : null,
              child: teacher.photoUrl == null || teacher.photoUrl!.isEmpty
                  ? Text(
                      _initials,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authHeading,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.authHeading,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: AppColors.authIcon,
                    ),
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              tooltip: 'Teacher options',
              icon: const Icon(
                Icons.more_vert,
                size: 20,
                color: AppColors.primary,
              ),
              onSelected: onMenuSelected,
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'view', child: Text('View teacher')),
                PopupMenuItem(value: 'edit', child: Text('Edit teacher')),
                PopupMenuItem(value: 'classes', child: Text('View classes')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
