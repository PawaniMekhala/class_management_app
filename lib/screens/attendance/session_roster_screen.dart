import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/class_model.dart';

class SessionRosterScreen extends StatelessWidget {
  final InstituteClass classItem;
  final ClassSlot slot;
  final DateTime sessionDate;

  const SessionRosterScreen({
    super.key,
    required this.classItem,
    required this.slot,
    required this.sessionDate,
  });

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return time;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return time;

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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

    return '${weekdays[date.weekday - 1]} '
        '${date.day} ${months[date.month - 1]}';
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.notEntered:
        return 'Not entered';

      case AttendanceStatus.inside:
        return 'Inside';

      case AttendanceStatus.left:
        return 'Left';

      case AttendanceStatus.done:
        return 'Done';

      case AttendanceStatus.absent:
        return 'Absent';
    }
  }

  Future<void> _confirmEndClass(BuildContext context) async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End Class?'),
        content: const Text(
          'Are you sure you want to end this class session? '
          'Students currently inside will be marked as inactive, '
          'and students who never entered will be marked absent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('End Class'),
          ),
        ],
      ),
    );

    if (shouldEnd != true || !context.mounted) return;

    try {
      await context.read<AttendanceProvider>().endSession(
        instituteId: classItem.instituteId,
        classId: classItem.id,
        date: sessionDate,
        startTime: slot.startTime,
        enrolledStudentIds: classItem.students.map((s) => s.id).toList(),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class session ended successfully.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to end class: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherName = classItem.teachers.isNotEmpty
        ? classItem.teachers.first.name
        : 'No teacher assigned';

    final attendanceProvider = context.watch<AttendanceProvider>();

    final records = attendanceProvider.getSessionRecords(
      instituteId: classItem.instituteId,
      classId: classItem.id,
      date: sessionDate,
      startTime: slot.startTime,
    );

    final isEnded = attendanceProvider.isSessionEnded(
      instituteId: classItem.instituteId,
      classId: classItem.id,
      date: sessionDate,
      startTime: slot.startTime,
    );

    final insideCount = records
        .where((r) => r.status == AttendanceStatus.inside)
        .length;

    final leftCount = records
        .where((r) => r.status == AttendanceStatus.left)
        .length;

    final doneCount = records
        .where((r) => r.status == AttendanceStatus.done)
        .length;

    final absentCount = records
        .where((r) => r.status == AttendanceStatus.absent)
        .length;

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: AppBar(
        backgroundColor: AppColors.authBackground,
        elevation: 0,
        title: Text(
          classItem.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.profileDivider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${classItem.code} · ${_formatDate(sessionDate)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.authIcon,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isEnded ? 'Completed' : 'Scheduled',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatTime(slot.startTime)} – '
                    '${_formatTime(slot.endTime)} · '
                    '${slot.hallName} · $teacherName',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.authHeading,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Attendance statistics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat('${classItem.enrolledCount}', 'Enrolled'),
                      _buildStat('$insideCount', 'Inside'),
                      _buildStat('$leftCount', 'Left'),
                      _buildStat('$doneCount', 'Done'),
                      _buildStat('$absentCount', 'Absent'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Late 0 · Unpaid entries 0',
                    style: TextStyle(fontSize: 11, color: AppColors.authIcon),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // End Class button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: isEnded ? null : () => _confirmEndClass(context),
                icon: const Icon(Icons.stop_circle_outlined),
                label: Text(isEnded ? 'Class Completed' : 'End Class'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Students',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.authHeading,
              ),
            ),

            const SizedBox(height: 10),

            // Reuse enrolled students from the class model
            if (classItem.students.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No students enrolled in this class.',
                  style: TextStyle(color: AppColors.authIcon, fontSize: 13),
                ),
              )
            else
              ...classItem.students.map((student) {
                AttendanceStatus status = AttendanceStatus.notEntered;

                for (final record in records) {
                  if (record.studentId == student.id) {
                    status = record.status;
                    break;
                  }
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    status == AttendanceStatus.done
                        ? Icons.check_circle_outline
                        : status == AttendanceStatus.absent
                        ? Icons.cancel_outlined
                        : status == AttendanceStatus.inside
                        ? Icons.login
                        : Icons.access_time,
                    color: status == AttendanceStatus.done
                        ? Colors.green
                        : status == AttendanceStatus.absent
                        ? Colors.red
                        : AppColors.authIcon,
                  ),
                  title: Text(
                    student.name,
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    _getStatusText(status),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.authIcon,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.authHeading,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.authIcon),
        ),
      ],
    );
  }
}
