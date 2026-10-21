import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/class_model.dart';
import '../../providers/class_provider.dart';

class ClassDetailsScreen extends StatelessWidget {
  final InstituteClass item;

  const ClassDetailsScreen({super.key, required this.item});

  String _formatTime(String value) {
    final parts = value.split(':');
    final hour = int.parse(parts[0]);
    return '${hour % 12 == 0 ? 12 : hour % 12}:${parts[1]} '
        '${hour >= 12 ? 'PM' : 'AM'}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _sectionTitle(String title, {String? action, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.authHeading,
              ),
            ),
          ),
          if (action != null) TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = context.read<ClassProvider>().upcomingSessions(item);
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        title: Text(
          item.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TO DO: Open Edit Class screen.
            },
          ),
          PopupMenuButton<String>(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'history', child: Text('Class history')),
              PopupMenuItem(value: 'status', child: Text('Change status')),
            ],
            onSelected: (_) {
              // TO   DO: Connect class management actions.
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 35),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.code,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.authHeading,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        item.status == 'active' ? 'Active' : item.status,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(
                  '${item.subject} · ${item.grade}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.authHeading,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${item.enrolledCount} / ${item.maxStudents} students',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: item.maxStudents == 0
                      ? 0
                      : (item.enrolledCount / item.maxStudents).clamp(0.0, 1.0),
                  backgroundColor: AppColors.moduleIconBackground,
                  color: AppColors.primary,
                  minHeight: 4,
                ),
                const SizedBox(height: 12),
                Text(
                  'From ${_formatDate(item.startDate)}',
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  'Payment plan: ${item.paymentPlanName}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),

          _sectionTitle(
            'Students (${item.students.length})',
            action: '+ Enroll',
            onTap: () {
              // TO DO: Search and enroll a student in this class.
            },
          ),

          for (final student in item.students)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.moduleIconBackground,
                child: Icon(Icons.person_outline, color: AppColors.authHeading),
              ),
              title: Text(student.name, style: const TextStyle(fontSize: 12)),
              subtitle: Text(
                '${student.studentCode} · ${student.paymentPlan}',
                style: const TextStyle(fontSize: 10),
              ),
              trailing:
                  student.outstandingAmount != null &&
                      student.outstandingAmount! > 0
                  ? Text(
                      'Rs. ${student.outstandingAmount!.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.red, fontSize: 11),
                    )
                  : const Icon(Icons.check, color: Colors.green, size: 17),
            ),

          _sectionTitle('Weekly schedule'),

          for (final slot in item.slots)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.moduleIconBackground,
                child: Text(
                  weekdays[slot.weekday - 1],
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              title: Text(
                '${_formatTime(slot.startTime)} – ${_formatTime(slot.endTime)}',
                style: const TextStyle(fontSize: 12),
              ),
              subtitle: Text(slot.hallName),
              trailing: TextButton(
                onPressed: () {
                  // TO DO: Open Change Hall dialog.
                },
                child: const Text('Change hall'),
              ),
            ),

          _sectionTitle(
            'Teachers',
            action: '+ Assign',
            onTap: () {
              // TO DO: Assign teacher.
            },
          ),

          for (final teacher in item.teachers)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.moduleIconBackground,
                child: Icon(Icons.person_outline, size: 18),
              ),
              title: Text(teacher.name),
              subtitle: Text(teacher.role),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: AppColors.primary),
                onPressed: () {
                  // TO DO: Confirm teacher removal and update backend.
                },
              ),
            ),

          _sectionTitle('Next 4 weeks (${sessions.length} sessions)'),

          if (sessions.isEmpty)
            const Text(
              'No upcoming sessions.',
              style: TextStyle(color: AppColors.authIcon),
            ),

          for (final session in sessions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                '${_formatDate(session.date)} · '
                '${_formatTime(session.startTime)} – ${_formatTime(session.endTime)}',
                style: const TextStyle(fontSize: 11),
              ),
              subtitle: Text(
                session.hallName,
                style: const TextStyle(fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
