import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/selected_institute_provider.dart';
import '../../widgets/cards/module_card.dart';
import '../../widgets/common/institute_dropdown.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../providers/profile_provider.dart';
import '../profile/profile_screen.dart';
import '../../providers/student_provider.dart';
import '../students/students_screen.dart';
import '../../providers/teacher_provider.dart';
import '../teachers/teachers_screen.dart';

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

              // TO DO: When backend is connected,
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
              // Get the existing institute provider.
              final instituteProvider = context
                  .read<SelectedInstituteProvider>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      // Share the institute selected in Modules.
                      ChangeNotifierProvider.value(value: instituteProvider),

                      // Create student data only for this route.
                      ChangeNotifierProvider(create: (_) => StudentProvider()),
                    ],
                    child: const StudentsScreen(),
                  ),
                ),
              );
            },
          ),

          ModuleCard(
            title: 'Teachers',
            description: 'Teacher registration and subject allocation.',
            icon: Icons.person_outline,
            onTap: () {
              final selectedInstituteProvider = context
                  .read<SelectedInstituteProvider>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider<SelectedInstituteProvider>.value(
                        value: selectedInstituteProvider,
                      ),
                      ChangeNotifierProvider<TeacherProvider>(
                        create: (_) => TeacherProvider(),
                      ),
                    ],
                    child: const TeachersScreen(),
                  ),
                ),
              );
            },
          ),

          ModuleCard(
            title: 'Classes',
            description: 'Classes, timetable and class sessions.',
            icon: Icons.groups_outlined,
            onTap: () {
              // TO DO: Open Classes screen.
            },
          ),

          ModuleCard(
            title: 'Enrollment',
            description: 'Enroll students into classes.',
            icon: Icons.how_to_reg_outlined,
            onTap: () {
              // TO DO: Open Enrollment screen.
            },
          ),

          ModuleCard(
            title: 'Attendance',
            description: 'QR check-in / check-out and attendance records.',
            icon: Icons.fact_check_outlined,
            onTap: () {
              // TO DO: Open Attendance screen.
            },
          ),

          ModuleCard(
            title: 'Payments',
            description: 'Fees, payment collection, receipts and refunds.',
            icon: Icons.payments_outlined,
            onTap: () {
              // TO DO: Open Payments screen.
            },
          ),

          ModuleCard(
            title: 'Tutes',
            description: 'Tutes and learning materials, distribution.',
            icon: Icons.menu_book_outlined,
            onTap: () {
              // TO DO: Open Tutes screen.
            },
          ),

          ModuleCard(
            title: 'Halls',
            description: 'Lecture halls, facilities and hall schedule.',
            icon: Icons.meeting_room_outlined,
            onTap: () {
              // TO DO: Open Halls screen.
            },
          ),

          ModuleCard(
            title: 'Academic',
            description: 'Subjects, modules and courses.',
            icon: Icons.auto_stories_outlined,
            onTap: () {
              // TO DO: Open Academic screen.
            },
          ),

          ModuleCard(
            title: 'Staff',
            description: 'Staff accounts and their roles.',
            icon: Icons.badge_outlined,
            onTap: () {
              // TO DO: Open Staff screen.
            },
          ),
        ],
      ),

      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 1,

        // Display the same user's profile picture.
        profilePhotoUrl: context.watch<ProfileProvider>().profile?.photoUrl,

        onTabSelected: (index) {
          if (index == 0) {
            Navigator.pop(context);
            return;
          }

          // MODULES
          if (index == 1) {
            return;
          }

          // PROFILE
          if (index == 2) {
            final profileProvider = context.read<ProfileProvider>();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: profileProvider,
                  child: const ProfileScreen(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
