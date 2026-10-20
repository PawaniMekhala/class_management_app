import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/student_detail_model.dart';
import '../../models/student_model.dart';
import '../../providers/student_detail_provider.dart';
import '../../widgets/cards/student_enrolled_class_tile.dart';
import '../../widgets/cards/student_qr_card.dart';

class StudentDetailsScreen extends StatelessWidget {
  final StudentModel student;
  final int instituteId;

  const StudentDetailsScreen({
    super.key,
    required this.student,
    required this.instituteId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentDetailProvider()
        ..loadStudent(
          instituteId: instituteId,
          studentId: student.id,
          studentName: student.name,
          studentCode: student.studentCode,
          grade: student.grade,
        ),
      child: const _StudentDetailsView(),
    );
  }
}

class _StudentDetailsView extends StatefulWidget {
  const _StudentDetailsView();

  @override
  State<_StudentDetailsView> createState() => _StudentDetailsViewState();
}

class _StudentDetailsViewState extends State<_StudentDetailsView> {
  final ScreenshotController _screenshotController = ScreenshotController();

  bool _isSharing = false;

  Future<void> _downloadQrCard(StudentDetailModel student) async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      final bytes = await _screenshotController.capture(pixelRatio: 3);

      if (bytes == null) {
        throw Exception('Could not capture QR card');
      }

      final directory = await getTemporaryDirectory();

      final file = File('${directory.path}/student_qr_${student.id}.png');

      await file.writeAsBytes(bytes);

      if (!mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Student QR card - ${student.name}',
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to export QR card.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.authHeading,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.authIcon,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.authHeading,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _guardianCard(StudentGuardianModel guardian) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            guardian.name,
            style: const TextStyle(
              color: AppColors.authHeading,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            [
              guardian.relationship,
              guardian.mobile,
              if (guardian.isPrimary) 'Primary contact',
              if (guardian.isEmergency) 'Emergency',
            ].join(' · '),
            style: const TextStyle(color: AppColors.authIcon, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _studentContent(StudentDetailModel student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STUDENT QR CARD
          Screenshot(
            controller: _screenshotController,
            child: StudentQrCard(student: student),
          ),

          const SizedBox(height: 2),

          // DOWNLOAD QR CARD
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: TextButton.icon(
              onPressed: _isSharing ? null : () => _downloadQrCard(student),
              icon: _isSharing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined, size: 16),
              label: const Text(
                'Download QR card',
                style: TextStyle(fontSize: 11),
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),

          const SizedBox(height: 10),

          // PERSONAL DETAILS
          _detailRow(
            icon: Icons.badge_outlined,
            label: 'Username',
            value: student.username,
          ),

          _detailRow(
            icon: Icons.cake_outlined,
            label: 'Date of birth',
            value: student.dateOfBirth,
          ),

          _detailRow(icon: Icons.wc, label: 'Gender', value: student.gender),

          _detailRow(
            icon: Icons.school_outlined,
            label: 'School',
            value: student.school,
          ),

          _detailRow(
            icon: Icons.phone_android,
            label: 'Mobile',
            value: student.mobile,
          ),

          _detailRow(
            icon: Icons.message_outlined,
            label: 'WhatsApp',
            value: student.whatsapp,
          ),

          _detailRow(
            icon: Icons.home_work_outlined,
            label: 'Address',
            value: student.address,
          ),

          _detailRow(
            icon: Icons.event_outlined,
            label: 'Admission',
            value:
                '${DateFormat('MMM d, yyyy').format(student.instituteRegistration.admissionDate)}'
                ' · registration fee '
                '${student.instituteRegistration.currency} '
                '${student.instituteRegistration.registrationFeePaid.toStringAsFixed(2)}',
          ),

          // PARENTS / GUARDIANS
          _sectionTitle('Parents / guardians'),

          ...student.guardians.map(
            (guardian) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _guardianCard(guardian),
            ),
          ),

          const SizedBox(height: 4),

          // ENROLLED CLASSES
          Row(
            children: [
              Expanded(
                child: Text(
                  'Classes (${student.classes.length})',
                  style: const TextStyle(
                    color: AppColors.authHeading,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              TextButton.icon(
                onPressed: () {
                  // TO DO: ADMIN ACTION
                  // Open the Enroll Student in Class screen.
                  // Pass student.id and student.instituteId.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Class enrollment screen will be added later.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1, size: 16),
                label: const Text('Enroll', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),

          if (student.classes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No classes enrolled yet.',
                style: TextStyle(fontSize: 11, color: AppColors.authIcon),
              ),
            )
          else
            ...student.classes.map(
              (enrolledClass) => StudentEnrolledClassTile(
                enrolledClass: enrolledClass,
                onTap: () {
                  // TO DO: Open class details screen.
                  // Pass enrolledClass.id.
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentDetailProvider>(
      builder: (context, provider, child) {
        final student = provider.student;

        return Scaffold(
          backgroundColor: AppColors.profileBackground,

          appBar: AppBar(
            backgroundColor: AppColors.profileBackground,
            foregroundColor: AppColors.authHeading,
            elevation: 0,

            titleSpacing: 0,

            title: Text(
              student?.name ?? 'Student Details',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),

            actions: [
              // ADMIN: EDIT STUDENT
              IconButton(
                tooltip: 'Edit student',
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: student == null
                    ? null
                    : () {
                        // TO DO: Open Edit Student screen.
                        // Pass student.id and student.instituteId.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Edit Student screen will be added later.',
                            ),
                          ),
                        );
                      },
              ),

              // ADMIN: MORE OPTIONS
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  // TO DO: Connect admin actions to backend.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$value action will be added later.'),
                    ),
                  );
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'View history',
                    child: Text('View history'),
                  ),
                  PopupMenuItem(
                    value: 'Manage status',
                    child: Text('Manage status'),
                  ),
                ],
              ),
            ],
          ),

          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : student == null
              ? const Center(child: Text('Student not found'))
              : _studentContent(student),
        );
      },
    );
  }
}
