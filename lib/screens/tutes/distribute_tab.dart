import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/student_model.dart';
import '../../models/enrollment_model.dart';
import '../../models/tute_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/tute_provider.dart';
import '../../widgets/common/student_search_field.dart';
import '../../providers/profile_provider.dart';
import 'widgets/distribution_student_card.dart';
import 'widgets/distribution_tute_tile.dart';

class DistributeTab extends StatefulWidget {
  const DistributeTab({super.key});

  @override
  State<DistributeTab> createState() => _DistributeTabState();
}

class _DistributeTabState extends State<DistributeTab> {
  StudentModel? _selectedStudent;
  List<StudentModel> _results = [];

  int? _issuingTuteId;

  // Confirm before issuing a tute.
  Future<void> _confirmIssue(TuteModel tute, StudentModel student) async {
    if (_issuingTuteId != null) return;

    if (tute.status != TuteStatus.active ||
        tute.releaseDate.isAfter(DateTime.now())) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Issue tute?'),
        content: Text('Issue "${tute.name}" to ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Confirm Issue'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _issuingTuteId = tute.id;
    });

    try {
      // Get the currently logged-in user's profile.
      final profile = context.read<ProfileProvider>().profile;

      debugPrint('Current user: ${profile?.name}');
      debugPrint('Current user ID: ${profile?.id}');

      if (profile == null) {
        throw Exception(
          'User profile is not available. Please reload your profile.',
        );
      }

      // TO DO: BACKEND INTEGRATION
      // The backend should identify the issuing staff member
      // using the authenticated user's access token.
      await context.read<TuteProvider>().markAsReceived(
        instituteId: student.instituteId,
        tuteId: tute.id,
        studentIds: [student.id],
        issuedById: profile.id,
        issuedByName: profile.name,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tute issued successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not issue tute: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _issuingTuteId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<StudentProvider, EnrollmentProvider, TuteProvider>(
      builder:
          (
            context,
            studentsProvider,
            enrollmentsProvider,
            tutesProvider,
            child,
          ) {
            if (studentsProvider.isLoading ||
                enrollmentsProvider.isLoading ||
                tutesProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (studentsProvider.errorMessage != null ||
                enrollmentsProvider.errorMessage != null ||
                tutesProvider.errorMessage != null) {
              return Center(
                child: Text(
                  studentsProvider.errorMessage ??
                      enrollmentsProvider.errorMessage ??
                      tutesProvider.errorMessage!,
                ),
              );
            }

            final students = studentsProvider.students;
            final student = _selectedStudent;

            final selectedExists =
                student != null &&
                students.any(
                  (s) =>
                      s.id == student.id &&
                      s.instituteId == student.instituteId,
                );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Scan QR or enter student no. / code',
                  style: TextStyle(fontSize: 11, color: AppColors.authIcon),
                ),

                const SizedBox(height: 6),

                // Reuse the existing student search widget.
                StudentSearchField(
                  students: students,
                  onResultsChanged: (results) {
                    setState(() {
                      _results = results;
                      _selectedStudent = null;
                    });
                  },
                ),

                // Search results.
                if (_results.isNotEmpty && _selectedStudent == null) ...[
                  const SizedBox(height: 8),

                  ..._results
                      .take(8)
                      .map(
                        (result) => ListTile(
                          tileColor: AppColors.surface,
                          leading: const Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                          ),
                          title: Text(result.name),
                          subtitle: Text(result.studentCode),
                          onTap: () {
                            setState(() {
                              _selectedStudent = result;
                              _results = [];
                            });
                          },
                        ),
                      ),
                ],

                if (!selectedExists) ...[
                  const SizedBox(height: 28),

                  const Center(
                    child: Text(
                      'Search and select a student to view tutes.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),

                  // Selected student information.
                  DistributionStudentCard(student: student),

                  const SizedBox(height: 16),

                  // Student's class-wise tute list.
                  ..._classSections(
                    student,
                    enrollmentsProvider.enrollments,
                    tutesProvider,
                  ),
                ],
              ],
            );
          },
    );
  }

  List<Widget> _classSections(
    StudentModel student,
    List<EnrollmentModel> enrollments,
    TuteProvider provider,
  ) {
    // Find classes in which this student is enrolled.
    final studentEnrollments = enrollments
        .where(
          (e) =>
              e.instituteId == student.instituteId &&
              e.studentId == student.id &&
              e.status == 'enrolled',
        )
        .toList();

    // Avoid displaying the same class multiple times.
    final uniqueClasses = <int, EnrollmentModel>{};

    for (final enrollment in studentEnrollments) {
      uniqueClasses[enrollment.classId] = enrollment;
    }

    if (uniqueClasses.isEmpty) {
      return [
        const Text('No active class enrollments found for this student.'),
      ];
    }

    final sections = <Widget>[];

    for (final enrollment in uniqueClasses.values) {
      // Find tutes belonging to this class.
      final classTutes =
          provider.tutes
              .where(
                (tute) =>
                    tute.instituteId == student.instituteId &&
                    tute.classId == enrollment.classId,
              )
              .toList()
            ..sort((a, b) => a.releaseDate.compareTo(b.releaseDate));

      // Class heading.
      sections.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Text(
            '${enrollment.className} (${enrollment.classCode})',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      );

      if (classTutes.isEmpty) {
        sections.add(
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('No tutes for this class.'),
          ),
        );
      }

      for (final tute in classTutes) {
        // Check whether the selected student received this tute.
        final distribution = provider.getDistribution(
          instituteId: student.instituteId,
          tuteId: tute.id,
          studentId: student.id,
        );

        final available =
            distribution == null &&
            tute.status == TuteStatus.active &&
            !tute.releaseDate.isAfter(DateTime.now());

        sections.add(
          DistributionTuteTile(
            tute: tute,
            receivedAt: distribution?.receivedAt,
            issuedByName: distribution?.issuedByName,
            isIssuing: _issuingTuteId == tute.id,
            onTap: available ? () => _confirmIssue(tute, student) : null,

            // TO DO: Connect to Reissue Tute form.
            onReissue: distribution != null
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reissue form will be implemented next.'),
                      ),
                    );
                  }
                : null,
          ),
        );
      }
    }

    return sections;
  }
}
