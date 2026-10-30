import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/staff_model.dart';

class StaffCard extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback? onTap;
  final ValueChanged<String>? onActionSelected;

  const StaffCard({
    super.key,
    required this.staff,
    this.onTap,
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final initial = staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?';

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
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
                      staff.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authHeading,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${staff.role} · ${staff.staffCode}',
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

              PopupMenuButton<String>(
                tooltip: 'Staff actions',
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.primary,
                  size: 20,
                ),
                onSelected: onActionSelected,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'view', child: Text('View details')),
                  PopupMenuItem(value: 'edit', child: Text('Edit staff')),
                  PopupMenuItem(value: 'status', child: Text('Manage status')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
