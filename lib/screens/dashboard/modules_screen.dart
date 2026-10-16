import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/selected_institute_provider.dart';
import '../../widgets/cards/module_card.dart';
import '../../widgets/common/institute_dropdown.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final instituteProvider = context.watch<SelectedInstituteProvider>();

    return Scaffold(
      backgroundColor: AppColors.authBackground,

      appBar: AppBar(
        backgroundColor: AppColors.authBackground,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Modules',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const Text(
            'Institute',
            style: TextStyle(fontSize: 11, color: AppColors.authIcon),
          ),

          const SizedBox(height: 5),

          InstituteDropdown(
            selectedInstitute: instituteProvider.selectedInstitute,
            institutes: instituteProvider.institutes,
            onChanged: (institute) {
              instituteProvider.selectInstitute(institute);

              // TODO: When backend is connected,
              // refresh institute-specific module data.
            },
          ),

          const SizedBox(height: 12),

          ModuleCard(
            title: 'Students',
            description:
                'Register students, profiles, guardians and approvals.',
            icon: Icons.school_outlined,
            onTap: () {
              // TODO: Open Students screen using
              // instituteProvider.selectedInstituteId
            },
          ),

          ModuleCard(
            title: 'Teachers',
            description: 'Teacher registration and subject allocation.',
            icon: Icons.person_outline,
            onTap: () {
              // TODO: Open Teachers screen.
            },
          ),

          ModuleCard(
            title: 'Classes',
            description: 'Classes, timetable and class sessions.',
            icon: Icons.groups_outlined,
            onTap: () {
              // TODO: Open Classes screen.
            },
          ),

          ModuleCard(
            title: 'Enrollment',
            description: 'Enroll students into classes.',
            icon: Icons.how_to_reg_outlined,
            onTap: () {
              // TODO: Open Enrollment screen.
            },
          ),

          ModuleCard(
            title: 'Attendance',
            description: 'QR check-in / check-out and attendance records.',
            icon: Icons.fact_check_outlined,
            onTap: () {
              // TODO: Open Attendance screen.
            },
          ),

          ModuleCard(
            title: 'Payments',
            description: 'Fees, payment collection, receipts and refunds.',
            icon: Icons.payments_outlined,
            onTap: () {
              // TODO: Open Payments screen.
            },
          ),

          ModuleCard(
            title: 'Tutes',
            description: 'Tutes and learning materials, distribution.',
            icon: Icons.menu_book_outlined,
            onTap: () {
              // TODO: Open Tutes screen.
            },
          ),

          ModuleCard(
            title: 'Halls',
            description: 'Lecture halls, facilities and hall schedule.',
            icon: Icons.meeting_room_outlined,
            onTap: () {
              // TODO: Open Halls screen.
            },
          ),

          ModuleCard(
            title: 'Academic',
            description: 'Subjects, modules and courses.',
            icon: Icons.auto_stories_outlined,
            onTap: () {
              // TODO: Open Academic screen.
            },
          ),

          ModuleCard(
            title: 'Staff',
            description: 'Staff accounts and their roles.',
            icon: Icons.badge_outlined,
            onTap: () {
              // TODO: Open Staff screen.
            },
          ),
        ],
      ),

      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 1,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }

          // Profile screen will be connected later.
        },
      ),
    );
  }
}
