import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../models/student_detail_model.dart';

class StudentQrCard extends StatelessWidget {
  final StudentDetailModel student;

  const StudentQrCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Student QR code
          QrImageView(
            data: student.qrValue,
            version: QrVersions.auto,
            size: 115,
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 13,
                      backgroundColor: AppColors.moduleIconBackground,
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        student.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.authHeading,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  student.studentCode,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.authHeading,
                  ),
                ),

                Text(
                  student.username,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.authHeading,
                  ),
                ),

                Text(
                  student.instituteRegistration.grade,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.authHeading,
                  ),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    _StatusChip(
                      text: student.instituteRegistration.isActive
                          ? 'Active'
                          : 'Inactive',
                      active: student.instituteRegistration.isActive,
                    ),
                    _StatusChip(text: '${student.instituteCount} institutes'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final bool active;

  const _StatusChip({required this.text, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE9F8EE) : AppColors.profileBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? const Color(0xFF8ED3A0) : AppColors.profileDivider,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: active ? const Color(0xFF258447) : AppColors.authIcon,
        ),
      ),
    );
  }
}
