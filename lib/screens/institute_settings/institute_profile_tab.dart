import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/institute_settings_provider.dart';
import '../../widgets/common/settings_detail_row.dart';
import 'edit_institute_profile_screen.dart';

class InstituteProfileTab extends StatelessWidget {
  const InstituteProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InstituteSettingsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.institute == null) {
          return Center(
            child: Text(provider.errorMessage ?? 'Institute not found.'),
          );
        }

        final institute = provider.institute!;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                institute.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.authHeading,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Code: ${institute.code}',
                style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
              ),
              const SizedBox(height: 14),

              SettingsDetailRow(
                icon: Icons.business_outlined,
                label: 'Organization',
                value: institute.organization,
              ),
              SettingsDetailRow(
                icon: Icons.mail_outline,
                label: 'Email',
                value: institute.email,
              ),
              SettingsDetailRow(
                icon: Icons.phone_outlined,
                label: 'Contact',
                value: institute.contact,
              ),
              SettingsDetailRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: institute.address,
              ),
              SettingsDetailRow(
                icon: Icons.event_outlined,
                label: 'Established',
                value: DateFormat('d MMMM yyyy')
                    .format(institute.establishedDate),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 38,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChangeNotifierProvider<
                              InstituteSettingsProvider
                            >.value(
                              value: provider,
                              child: EditInstituteProfileScreen(
                                institute: institute,
                              ),
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text(
                    'Edit profile',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.profileDivider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
