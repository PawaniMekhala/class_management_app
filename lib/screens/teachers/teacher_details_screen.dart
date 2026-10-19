import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/teacher_model.dart';
import '../../models/teacher_detail_model.dart';
import '../../providers/teacher_detail_provider.dart';
import '../../widgets/common/read_only_profile_field.dart';

class TeacherDetailsScreen extends StatelessWidget {
  final TeacherModel teacher;
  final int instituteId;

  const TeacherDetailsScreen({
    super.key,
    required this.teacher,
    required this.instituteId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          TeacherDetailProvider()
            ..loadTeacher(instituteId: instituteId, selectedTeacher: teacher),
      child: const _TeacherDetailsView(),
    );
  }
}

class _TeacherDetailsView extends StatelessWidget {
  const _TeacherDetailsView();

  Widget _buildProfilePhoto(TeacherDetailModel teacher) {
    return Column(
      children: [
        CircleAvatar(
          radius: 39,
          backgroundColor: AppColors.moduleIconBackground,
          backgroundImage:
              teacher.photoUrl != null && teacher.photoUrl!.isNotEmpty
              ? NetworkImage(teacher.photoUrl!)
              : null,
          child: teacher.photoUrl == null || teacher.photoUrl!.isEmpty
              ? const Icon(Icons.person, size: 45, color: AppColors.primary)
              : null,
        ),
        const SizedBox(height: 8),
        const Text(
          'Profile photo',
          style: TextStyle(fontSize: 11, color: AppColors.authHeading),
        ),
      ],
    );
  }

  Widget _buildSharedProfileBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFD9F7FC),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.share_outlined, color: AppColors.primary, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shared profile',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authHeading,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This teacher also works at another institute, '
                  'so they maintain their own details. You can add subjects.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.authIcon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjects(TeacherDetailModel teacher) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Subjects',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
        const SizedBox(height: 10),
        if (teacher.subjects.isEmpty)
          const Text(
            'No subjects assigned.',
            style: TextStyle(fontSize: 12, color: AppColors.authIcon),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: teacher.subjects.map((subject) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.moduleIconBackground,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildContent(TeacherDetailModel teacher) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (teacher.isSharedProfile) ...[
            _buildSharedProfileBanner(),
            const SizedBox(height: 15),
          ],

          Center(child: _buildProfilePhoto(teacher)),

          const SizedBox(height: 17),

          Text(
            teacher.teacherId,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.authHeading,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            teacher.teacherCode,
            style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
          ),

          const SizedBox(height: 13),

          ReadOnlyProfileField(
            label: 'Full name',
            value: teacher.name,
            icon: Icons.person_outline,
          ),

          ReadOnlyProfileField(
            label: 'NIC',
            value: teacher.nic,
            icon: Icons.badge_outlined,
          ),

          ReadOnlyProfileField(
            label: 'Mobile number',
            value: teacher.mobile,
            icon: Icons.phone_android_outlined,
          ),

          // Mobile visibility is also read-only.
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publish mobile number',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.authHeading,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Show it on the teacher's profile to students",
                      style: TextStyle(fontSize: 10, color: AppColors.authIcon),
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                child: Switch(
                  value: teacher.publishMobile,
                  onChanged: (_) {},
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ReadOnlyProfileField(
            label: 'Email',
            value: teacher.email,
            icon: Icons.mail_outline,
          ),

          ReadOnlyProfileField(
            label: 'Qualifications',
            value: teacher.qualifications,
            icon: Icons.workspace_premium_outlined,
            maxLines: 2,
          ),

          ReadOnlyProfileField(
            label: 'About (optional)',
            value: teacher.about,
            icon: Icons.info_outline,
            maxLines: 3,
          ),

          ReadOnlyProfileField(
            label: 'Address',
            value: teacher.address,
            icon: Icons.home_work_outlined,
            maxLines: 2,
          ),

          _buildSubjects(teacher),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherDetailProvider>(
      builder: (context, provider, child) {
        final teacher = provider.teacher;

        return Scaffold(
          backgroundColor: AppColors.profileBackground,
          appBar: AppBar(
            backgroundColor: AppColors.profileBackground,
            foregroundColor: AppColors.authHeading,
            elevation: 0,
            title: Text(
              teacher?.name ?? 'Teacher details',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : teacher == null
              ? const Center(child: Text('Teacher not found'))
              : _buildContent(teacher),
        );
      },
    );
  }
}
