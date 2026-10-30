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
import '../../providers/academic_subject_provider.dart';
import '../academic/academic_screen.dart';
import '../../providers/academic_course_provider.dart';
import '../../providers/payment_plan_provider.dart';
import '../../providers/hall_provider.dart';
import '../halls/halls_screen.dart';
import '../../providers/class_provider.dart';
import '../classes/classes_screen.dart';
import '../../providers/enrollment_provider.dart';
import '../enrollment/enrollment_screen.dart';
import '../payments/payments_screen.dart';
import '../../providers/payment_provider.dart';
import '../../providers/outstanding_provider.dart';
import '../../providers/refund_provider.dart';
import '../attendance/attendance_screen.dart';
import '../../providers/attendance_provider.dart';
import '../tutes/tutes_screen.dart';
import '../../providers/tute_provider.dart';
import '../../providers/staff_provider.dart';
import '../staff/staff_screen.dart';

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

          // Students module card
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

          // Teachers module card
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

          // Classes module card
          ModuleCard(
            title: 'Classes',
            description: 'Classes, timetable and class sessions.',
            icon: Icons.groups_outlined,
            onTap: () {
              final instituteProvider = context
                  .read<SelectedInstituteProvider>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider<SelectedInstituteProvider>.value(
                        value: instituteProvider,
                      ),
                      ChangeNotifierProvider<ClassProvider>(
                        create: (_) => ClassProvider(),
                      ),
                    ],
                    child: const ClassesScreen(),
                  ),
                ),
              );
            },
          ),

          // Enrollment module card
          ModuleCard(
            title: 'Enrollment',
            description: 'Enroll students into classes.',
            icon: Icons.how_to_reg_outlined,
            onTap: () {
              final instituteProvider = context
                  .read<SelectedInstituteProvider>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider<SelectedInstituteProvider>.value(
                        value: instituteProvider,
                      ),
                      ChangeNotifierProvider<EnrollmentProvider>(
                        create: (_) => EnrollmentProvider(),
                      ),
                    ],
                    child: const EnrollmentScreen(),
                  ),
                ),
              );
            },
          ),

          // Attendance module card
          ModuleCard(
            title: 'Attendance',
            description: 'QR check-in / check-out and attendance records.',
            icon: Icons.fact_check_outlined,
            onTap: () {
              final instituteProvider = context
                  .read<SelectedInstituteProvider>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider<SelectedInstituteProvider>.value(
                        value: instituteProvider,
                      ),
                      ChangeNotifierProvider<StudentProvider>(
                        create: (_) => StudentProvider(),
                      ),
                      ChangeNotifierProvider<ClassProvider>(
                        create: (_) => ClassProvider(),
                      ),
                      ChangeNotifierProvider<EnrollmentProvider>(
                        create: (_) => EnrollmentProvider(),
                      ),
                      ChangeNotifierProvider<AttendanceProvider>(
                        create: (_) => AttendanceProvider(),
                      ),
                    ],
                    child: const AttendanceScreen(),
                  ),
                ),
              );
            },
          ),

          // Payments module card
          ModuleCard(
            title: 'Payments',
            description: 'Fees, payment collection, receipts and refunds.',
            icon: Icons.payments_outlined,
            onTap: () {
              // 1. Get the currently selected institute.
              final instituteProvider = context
                  .read<SelectedInstituteProvider>();

              final selectedInstituteId = instituteProvider.selectedInstituteId;

              // 2. Check whether an institute is selected.
              // if (selectedInstituteId == null) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //       content: Text('Please select an institute first.'),
              //     ),
              //   );
              //   return;
              // }

              // 3. Open the Payments screen.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider<SelectedInstituteProvider>.value(
                        value: instituteProvider,
                      ),

                      ChangeNotifierProvider<PaymentProvider>(
                        create: (_) => PaymentProvider(),
                      ),

                      ChangeNotifierProvider<OutstandingProvider>(
                        create: (_) => OutstandingProvider(),
                      ),

                      ChangeNotifierProvider<RefundProvider>(
                        create: (_) => RefundProvider(),
                      ),
                    ],
                    child: PaymentsScreen(instituteId: selectedInstituteId),
                  ),
                ),
              );
            },
          ),

          // Tutes module card
          ModuleCard(
            title: 'Tutes',
            description: 'Tutes and learning materials, distribution.',
            icon: Icons.menu_book_outlined,
            onTap: () {
              // Get the existing selected institute provider.
              final instituteProvider = context
                  .read<SelectedInstituteProvider>();

              // Get the existing logged-in user's profile provider.
              final profileProvider = context.read<ProfileProvider>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      // Reuse the selected institute.
                      ChangeNotifierProvider<SelectedInstituteProvider>.value(
                        value: instituteProvider,
                      ),

                      // Reuse the currently logged-in user's profile.
                      ChangeNotifierProvider<ProfileProvider>.value(
                        value: profileProvider,
                      ),

                      // Tutes module providers.
                      ChangeNotifierProvider<TuteProvider>(
                        create: (_) => TuteProvider(),
                      ),

                      ChangeNotifierProvider<ClassProvider>(
                        create: (_) => ClassProvider(),
                      ),

                      ChangeNotifierProvider<EnrollmentProvider>(
                        create: (_) => EnrollmentProvider(),
                      ),

                      ChangeNotifierProvider<AttendanceProvider>(
                        create: (_) => AttendanceProvider(),
                      ),

                      ChangeNotifierProvider<StudentProvider>(
                        create: (_) => StudentProvider(),
                      ),
                    ],
                    child: const TutesScreen(),
                  ),
                ),
              );
            },
          ),

          // Halls module card
          ModuleCard(
            title: 'Halls',
            description: 'Lecture halls, facilities and hall schedule.',
            icon: Icons.meeting_room_outlined,
            onTap: () {
              final instituteProvider = context
                  .read<SelectedInstituteProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider<SelectedInstituteProvider>.value(
                        value: instituteProvider,
                      ),
                      ChangeNotifierProvider<HallProvider>(
                        create: (_) => HallProvider(),
                      ),
                      ChangeNotifierProvider(create: (_) => ProfileProvider()),
                    ],
                    child: const HallsScreen(),
                  ),
                ),
              );
            },
          ),

          // Academic module card
          ModuleCard(
            title: 'Academic',
            description: 'Subjects, modules and courses.',
            icon: Icons.auto_stories_outlined,
            onTap: () {
              final instituteProvider = context
                  .read<SelectedInstituteProvider>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider<SelectedInstituteProvider>.value(
                        value: instituteProvider,
                      ),
                      ChangeNotifierProvider<AcademicSubjectProvider>(
                        create: (_) => AcademicSubjectProvider(),
                      ),
                      ChangeNotifierProvider<AcademicCourseProvider>(
                        create: (_) => AcademicCourseProvider(),
                      ),
                      ChangeNotifierProvider<PaymentPlanProvider>(
                        create: (_) => PaymentPlanProvider(),
                      ),
                    ],
                    child: const AcademicScreen(),
                  ),
                ),
              );
            },
          ),

          // Staff module card
          ModuleCard(
            title: 'Staff',
            description: 'Staff accounts and their roles.',
            icon: Icons.badge_outlined,
            onTap: () {
              final instituteProvider = context
                  .read<SelectedInstituteProvider>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      // Reuse selected institute.
                      ChangeNotifierProvider<SelectedInstituteProvider>.value(
                        value: instituteProvider,
                      ),

                      // Staff data provider.
                      ChangeNotifierProvider<StaffProvider>(
                        create: (_) => StaffProvider(),
                      ),
                    ],
                    child: const StaffScreen(),
                  ),
                ),
              );
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
