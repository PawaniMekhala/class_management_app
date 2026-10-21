import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/hall_model.dart';

class HallListTile extends StatelessWidget {
  final HallModel hall;
  final bool isUpdating;
  final ValueChanged<String> onStatusChanged;

  const HallListTile({
    super.key,
    required this.hall,
    required this.onStatusChanged,
    this.isUpdating = false,
  });

  String get _statusLabel {
    switch (hall.status) {
      case 'active':
        return 'Active';
      case 'under_maintenance':
        return 'Under maintenance';
      case 'closed':
        return 'Closed';
      default:
        return hall.status;
    }
  }

  Color get _statusColor {
    switch (hall.status) {
      case 'active':
        return const Color(0xFF4CAF50);
      case 'under_maintenance':
        return const Color(0xFFF0A500);
      case 'closed':
        return const Color(0xFFE05252);
      default:
        return AppColors.authIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<String>(
        enabled: !isUpdating,
        tooltip: 'Change hall status',
        onSelected: onStatusChanged,
        itemBuilder: (_) {
          return [
            if (hall.status != 'active')
              const PopupMenuItem(value: 'active', child: Text('Set active')),
            if (hall.status != 'under_maintenance')
              const PopupMenuItem(
                value: 'under_maintenance',
                child: Text('Set under maintenance'),
              ),
            if (hall.status != 'closed')
              const PopupMenuItem(value: 'closed', child: Text('Set closed')),
          ];
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.moduleIconBackground,
                child: Text(
                  hall.number,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authHeading,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hall.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.authHeading,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${hall.capacity} seats · ${hall.building} · ${hall.floor}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.authIcon,
                      ),
                    ),
                    if (hall.weeklyClassCount > 0)
                      Text(
                        '${hall.weeklyClassCount} classes weekly',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.authIcon,
                        ),
                      ),
                    if (hall.facilities.isNotEmpty)
                      Text(
                        hall.facilities.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.authHeading,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              if (isUpdating)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: _statusColor),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
