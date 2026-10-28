import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/attendance_model.dart';
import '../../models/class_model.dart';
import '../../models/tute_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/tute_provider.dart';

class BulkTuteDistributionScreen extends StatefulWidget {
  final TuteModel tute;
  final InstituteClass instituteClass;

  const BulkTuteDistributionScreen({
    super.key,
    required this.tute,
    required this.instituteClass,
  });

  @override
  State<BulkTuteDistributionScreen> createState() =>
      _BulkTuteDistributionScreenState();
}

class _BulkTuteDistributionScreenState
    extends State<BulkTuteDistributionScreen> {
  final Set<int> _selectedStudentIds = {};

  bool _isSubmitting = false;

  ClassSession? _selectedSession;

  bool get _isArchived => widget.tute.status == TuteStatus.archived;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    final todaySessions = _getAvailableSessions().where((session) {
      return session.date.year == now.year &&
          session.date.month == now.month &&
          session.date.day == now.day;
    }).toList();

    // Auto-select only when exactly one session exists today.
    if (todaySessions.length == 1) {
      _selectedSession = todaySessions.first;
    }
  }

  Widget _buildSessionSelector() {
    final sessions = _getAvailableSessions();

    if (sessions.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.profileDivider),
        ),
        child: const Text(
          'No class sessions available.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.profileDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CLASS SESSION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.authHeading,
            ),
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<ClassSession>(
            initialValue: _selectedSession,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.event, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            hint: const Text(
              'Select a class session',
              style: TextStyle(fontSize: 12),
            ),
            items: sessions.map((session) {
              return DropdownMenuItem<ClassSession>(
                value: session,
                child: Text(
                  '${_formatDate(session.date)}  '
                  '${session.startTime} - ${session.endTime}  '
                  '(${session.hallName})',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
            onChanged: (session) {
              setState(() {
                _selectedSession = session;

                // Clear selections when changing sessions.
                _selectedStudentIds.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  List<ClassSession> _getAvailableSessions() {
    final sessions = List<ClassSession>.from(widget.instituteClass.sessions);

    // Show the most recent sessions first.
    sessions.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return b.startTime.compareTo(a.startTime);
    });

    return sessions;
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

  @override
  Widget build(BuildContext context) {
    final tuteProvider = context.watch<TuteProvider>();
    final enrollmentProvider = context.watch<EnrollmentProvider>();

    // Rebuild student cards when attendance changes.
    context.watch<AttendanceProvider>();

    final enrollments = enrollmentProvider.enrollments
        .where(
          (enrollment) =>
              enrollment.instituteId == widget.tute.instituteId &&
              enrollment.classId == widget.tute.classId,
        )
        .toList();

    // Prevent duplicate student rows.
    final uniqueEnrollments = {
      for (final enrollment in enrollments) enrollment.studentId: enrollment,
    }.values.toList();

    final studentIds = uniqueEnrollments
        .map((enrollment) => enrollment.studentId)
        .toList();

    final received = tuteProvider.receivedCount(
      tuteId: widget.tute.id,
      enrolledStudentIds: studentIds,
    );

    final pending = tuteProvider.pendingCount(
      tuteId: widget.tute.id,
      enrolledStudentIds: studentIds,
    );

    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        title: const Text(
          'Bulk Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTuteDetails(
            received: received,
            total: studentIds.length,
            pending: pending,
          ),

          // New session selector
          _buildSessionSelector(),

          if (!_isArchived) _buildSelectionActions(uniqueEnrollments),

          const SizedBox(height: 8),

          Expanded(
            child: uniqueEnrollments.isEmpty
                ? const Center(child: Text('No students found for this class.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: uniqueEnrollments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final enrollment = uniqueEnrollments[index];

                      final hasReceived = tuteProvider.hasReceived(
                        tuteId: widget.tute.id,
                        studentId: enrollment.studentId,
                      );

                      return _buildStudentCard(
                        studentId: enrollment.studentId,
                        studentName: enrollment.studentName,
                        studentCode: enrollment.studentCode,
                        hasReceived: hasReceived,
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: _isArchived ? null : _buildBottomButton(),
    );
  }

  // TUTE DETAILS
  Widget _buildTuteDetails({
    required int received,
    required int total,
    required int pending,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.profileDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.tute.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.authHeading,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '${widget.instituteClass.name} · ${widget.tute.unitName}',
            style: const TextStyle(fontSize: 12, color: AppColors.authIcon),
          ),

          const SizedBox(height: 8),

          Text(
            'Tute · Released ${_formatDate(widget.tute.releaseDate)}',
            style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                '$received/$total received',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              Text(
                total == 0
                    ? 'No students'
                    : pending == 0
                    ? 'Fully Distributed'
                    : '$pending pending',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: total == 0
                      ? Colors.grey
                      : pending == 0
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),

          if (_isArchived) ...[
            const SizedBox(height: 12),
            const Text(
              'Archived — View only',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // SELECTION ACTIONS
  Widget _buildSelectionActions(List<dynamic> enrollments) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _selectPresent(enrollments),
              child: const Text(
                'Select present',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),

          const SizedBox(width: 6),

          Expanded(
            child: OutlinedButton(
              onPressed: () => _selectAllPending(enrollments),
              child: const Text(
                'Select all pending',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),

          const SizedBox(width: 6),

          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedStudentIds.clear();
              });
            },
            child: const Text('Clear', style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  // SELECT PRESENT
  void _selectPresent(List<dynamic> enrollments) {
    final session = _selectedSession;

    // A session must be selected first.
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class session first.')),
      );
      return;
    }

    final attendanceProvider = context.read<AttendanceProvider>();
    final tuteProvider = context.read<TuteProvider>();

    // Retrieve attendance for the selected session.
    final attendanceRecords = attendanceProvider.getSessionRecords(
      instituteId: widget.tute.instituteId,
      classId: widget.tute.classId,
      date: session.date,
      startTime: session.startTime,
    );

    // Identify students currently inside the selected session.
    final presentStudentIds = attendanceRecords
        .where((record) => record.status == AttendanceStatus.inside)
        .map((record) => record.studentId)
        .toSet();

    setState(() {
      _selectedStudentIds.clear();

      for (final enrollment in enrollments) {
        final studentId = enrollment.studentId as int;

        final isPresent = presentStudentIds.contains(studentId);

        final hasReceived = tuteProvider.hasReceived(
          tuteId: widget.tute.id,
          studentId: studentId,
        );

        if (isPresent && !hasReceived) {
          _selectedStudentIds.add(studentId);
        }
      }
    });

    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No eligible students are inside the selected session.',
          ),
        ),
      );
    }
  }

  // SELECT ALL PENDING
  void _selectAllPending(List<dynamic> enrollments) {
    final tuteProvider = context.read<TuteProvider>();

    setState(() {
      _selectedStudentIds.clear();

      for (final enrollment in enrollments) {
        final studentId = enrollment.studentId as int;

        if (!tuteProvider.hasReceived(
          tuteId: widget.tute.id,
          studentId: studentId,
        )) {
          _selectedStudentIds.add(studentId);
        }
      }
    });
  }

  AttendanceStatus _getStudentAttendanceStatus(int studentId) {
    final session = _selectedSession;

    if (session == null) {
      return AttendanceStatus.notEntered;
    }

    final attendanceProvider = context.read<AttendanceProvider>();

    final records = attendanceProvider.getSessionRecords(
      instituteId: widget.tute.instituteId,
      classId: widget.tute.classId,
      date: session.date,
      startTime: session.startTime,
    );

    for (final record in records) {
      if (record.studentId == studentId) {
        return record.status;
      }
    }

    return AttendanceStatus.notEntered;
  }

  Widget _buildAttendanceIndicator(AttendanceStatus status) {
    String label;
    Color color;
    IconData icon;

    switch (status) {
      case AttendanceStatus.inside:
        label = 'Inside Class';
        color = Colors.green;
        icon = Icons.check_circle;
        break;

      case AttendanceStatus.left:
        label = 'Left Class';
        color = Colors.orange;
        icon = Icons.exit_to_app;
        break;

      case AttendanceStatus.done:
        label = 'Class Completed';
        color = Colors.blue;
        icon = Icons.task_alt;
        break;

      case AttendanceStatus.absent:
        label = 'Absent';
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;

      case AttendanceStatus.notEntered:
        label = 'Not in Selected Session';
        color = Colors.grey;
        icon = Icons.remove_circle_outline;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // STUDENT CARD
  Widget _buildStudentCard({
    required int studentId,
    required String studentName,
    required String studentCode,
    required bool hasReceived,
  }) {
    final isSelected = _selectedStudentIds.contains(studentId);
    final canSelect = !_isArchived && !hasReceived;

    final attendanceStatus = _getStudentAttendanceStatus(studentId);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.profileDivider,
          ),
        ),
        child: CheckboxListTile(
          value: isSelected,
          onChanged: canSelect
              ? (value) {
                  setState(() {
                    if (value == true) {
                      _selectedStudentIds.add(studentId);
                    } else {
                      _selectedStudentIds.remove(studentId);
                    }
                  });
                }
              : null,
          activeColor: AppColors.primary,
          controlAffinity: ListTileControlAffinity.trailing,

          title: Text(
            studentName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.authHeading,
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student code
                Text(
                  studentCode,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.authIcon,
                  ),
                ),

                const SizedBox(height: 8),

                // Attendance status
                _buildAttendanceIndicator(attendanceStatus),

                const SizedBox(height: 6),

                // Tute distribution status
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasReceived ? Icons.check_circle : Icons.schedule,
                      size: 14,
                      color: hasReceived ? Colors.green : Colors.orange,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      hasReceived ? 'Received' : 'Not Received',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: hasReceived ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // BOTTOM BUTTON
  Widget _buildBottomButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: _selectedStudentIds.isEmpty || _isSubmitting
                ? null
                : _confirmDistribution,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Mark as Tute Received (${_selectedStudentIds.length})'),
          ),
        ),
      ),
    );
  }

  // CONFIRM DISTRIBUTION
  Future<void> _confirmDistribution() async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Distribution'),
        content: Text(
          'Mark ${_selectedStudentIds.length} student(s) '
          'as having received ${widget.tute.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (shouldProceed != true || !mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<TuteProvider>().markAsReceived(
        instituteId: widget.tute.instituteId,
        tuteId: widget.tute.id,
        studentIds: _selectedStudentIds.toList(),
      );

      if (!mounted) return;

      setState(() {
        _selectedStudentIds.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tute distribution updated successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Distribution failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
