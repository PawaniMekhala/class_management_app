import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/staff_role_model.dart';

class StaffRoleCard extends StatelessWidget {
  final StaffRoleModel role;
  final int staffCount;
  final VoidCallback onTap;

  const StaffRoleCard({
    super.key,
    required this.role,
    required this.staffCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                child: Icon(
                  role.isSystemRole ? Icons.lock_outline : Icons.tune,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authHeading,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${role.isSystemRole ? 'System role' : 'Custom role'}'
                      ' · $staffCount ${staffCount == 1 ? 'staff' : 'staff'}'
                      ' · ${role.moduleCount} modules',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.authIcon,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
