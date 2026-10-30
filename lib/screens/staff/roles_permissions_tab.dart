import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class RolesPermissionsTab extends StatelessWidget {
  const RolesPermissionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: BACKEND INTEGRATION
    // Replace dummy roles and permissions with API data.

    final roles = [
      {
        'name': 'Institute Owner',
        'description': 'Full access to institute management.',
        'permissions': [
          'Manage institutes',
          'Manage staff',
          'Manage students',
          'Manage classes',
          'Manage payments',
          'Manage attendance',
          'Manage tutes',
          'Manage roles and permissions',
        ],
      },
      {
        'name': 'Institute Admin',
        'description': 'Manage daily institute operations.',
        'permissions': [
          'Manage staff',
          'Manage students',
          'Manage teachers',
          'Manage classes',
          'Manage attendance',
          'Manage payments',
          'Manage tutes',
        ],
      },
      {
        'name': 'Cashier',
        'description': 'Manage student payments and receipts.',
        'permissions': [
          'View students',
          'Collect payments',
          'View payment history',
          'Issue receipts',
        ],
      },
      {
        'name': 'Gate Officer',
        'description': 'Manage student entry and exit.',
        'permissions': [
          'Scan student QR codes',
          'Mark student entry',
          'Mark student exit',
          'View attendance',
        ],
      },
      {
        'name': 'Learning Material Distributor',
        'description': 'Manage learning material distribution.',
        'permissions': [
          'View students',
          'View tutes',
          'Distribute tutes',
          'View distribution history',
        ],
      },
      {
        'name': 'Front Desk',
        'description': 'Assist with institute front desk operations.',
        'permissions': [
          'View students',
          'Check payment status',
          'View class details',
        ],
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];

        final permissions = role['permissions'] as List<String>;

        return Card(
          color: AppColors.surface,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              role['name'] as String,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.authHeading,
              ),
            ),
            subtitle: Text(
              role['description'] as String,
              style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
            ),
            children: [
              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Permissions',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authHeading,
                      ),
                    ),

                    const SizedBox(height: 8),

                    ...permissions.map(
                      (permission) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.primary,
                              size: 16,
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                permission,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.authHeading,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
