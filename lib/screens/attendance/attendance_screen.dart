import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../models/class_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/enrollment_provider.dart';
import 'session_roster_screen.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/qr_scan_button.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _selectedTab = 0;
  bool _isEntry = true;
  StudentModel? _selectedStudent;
  String? _studentSearchError;
  InstituteClass? _selectedClass;
  ClassSlot? _selectedSlot;
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _qrController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Temporary institute ID for testing.
      const instituteId = 1;

      context.read<StudentProvider>().loadStudents(instituteId);
      context.read<ClassProvider>().loadClasses(instituteId);
      context.read<EnrollmentProvider>().load(instituteId);
    });
  }

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  void _clearSelectedStudent() {
    setState(() {
      _selectedStudent = null;
      _selectedClass = null;
      _selectedSlot = null;
      _studentSearchError = null;
      _qrController.clear();
    });
  }

  void _searchStudent(String value) {
    final searchValue = value.trim().toLowerCase();

    final students = context.read<StudentProvider>().students;

    StudentModel? foundStudent;

    for (final student in students) {
      if (student.studentCode.toLowerCase() == searchValue ||
          (student.qrCode?.toLowerCase() == searchValue)) {
        foundStudent = student;
        break;
      }
    }

    setState(() {
      _selectedStudent = foundStudent;
      _selectedClass = null;
      _studentSearchError = foundStudent == null ? 'Student not found.' : null;
    });
  }

  Future<void> _confirmStudentEntry() async {
    final student = _selectedStudent;
    final classItem = _selectedClass;
    final slot = _selectedSlot;

    // Make sure the admin selected a student and class session.
    if (student == null || classItem == null || slot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an eligible class first.')),
      );
      return;
    }

    // Check the session is still eligible at confirmation time.
    final isStillEligible = _getEligibleSessions().any(
      (session) =>
          session.classItem.id == classItem.id &&
          session.slot.startTime == slot.startTime &&
          session.slot.hallId == slot.hallId,
    );

    if (!isStillEligible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This class session is no longer eligible.'),
        ),
      );
      return;
    }

    final attendanceProvider = context.read<AttendanceProvider>();

    // Prevent duplicate attendance.
    final existingRecords = attendanceProvider.getSessionRecords(
      instituteId: classItem.instituteId,
      classId: classItem.id,
      date: DateTime.now(),
      startTime: slot.startTime,
    );

    final alreadyRecorded = existingRecords.any(
      (record) => record.studentId == student.id,
    );

    if (alreadyRecorded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Attendance has already been recorded for this student.',
          ),
        ),
      );
      return;
    }

    // Ask for confirmation before recording attendance.
    final shouldConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Student Entry'),
        content: Text(
          'Student: ${student.name}\n'
          'Class: ${classItem.name}\n'
          'Time: ${_formatClassTime(slot.startTime)}'
          ' – ${_formatClassTime(slot.endTime)}\n\n'
          'Mark this student as entered?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm Entry'),
          ),
        ],
      ),
    );

    if (shouldConfirm != true || !mounted) return;

    try {
      final record = AttendanceRecord(
        instituteId: classItem.instituteId,
        classId: classItem.id,
        studentId: student.id,
        sessionDate: DateTime.now(),
        sessionStartTime: slot.startTime,
      );

      await attendanceProvider.checkIn(record);

      if (!mounted) return;

      setState(() {
        _selectedClass = null;
        _selectedSlot = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${student.name} successfully entered ${classItem.name}.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to record attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        // elevation: 0,
        title: const Text(
          'Attendance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
      ),
      body: Column(
        children: [
          // Gate and Classes tabs
          Row(
            children: [
              Expanded(child: _buildTab(title: 'Gate', index: 0)),
              Expanded(child: _buildTab(title: 'Classes', index: 1)),
            ],
          ),

          const Divider(height: 1, color: AppColors.profileDivider),

          Expanded(
            child: _selectedTab == 0 ? _buildGateTab() : _buildClassesTab(),
          ),
        ],
      ),
    );
  }

  // List<InstituteClass> _getEnrolledClasses() {
  //   if (_selectedStudent == null) return [];

  //   final classProvider = context.read<ClassProvider>();
  //   final enrollmentProvider = context.read<EnrollmentProvider>();

  //   final studentEnrollments = enrollmentProvider.enrollments.where(
  //     (enrollment) =>
  //         enrollment.studentId == _selectedStudent!.id &&
  //         enrollment.status == 'enrolled',
  //   );

  //   final enrolledClassIds = studentEnrollments
  //       .map((enrollment) => enrollment.classId)
  //       .toSet();

  //   return classProvider.allClasses.where((classItem) {
  //     final isEnrolled = enrolledClassIds.contains(classItem.id);

  //     final isEligible = _isClassEligible(classItem);

  //     return isEnrolled && isEligible;
  //   }).toList();
  // }

  List<({InstituteClass classItem, ClassSlot slot})> _getEligibleSessions() {
    if (_selectedStudent == null) return [];

    // final classProvider = context.read<ClassProvider>();
    final enrollmentProvider = context.read<EnrollmentProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();

    final now = DateTime.now();

    // Find classes in which the selected student is enrolled.
    final enrolledClassIds = enrollmentProvider.enrollments
        .where(
          (enrollment) =>
              enrollment.studentId == _selectedStudent!.id &&
              enrollment.status == 'enrolled',
        )
        .map((enrollment) => enrollment.classId)
        .toSet();

    final eligibleSessions = <({InstituteClass classItem, ClassSlot slot})>[];

    // Reuse the existing schedule method from the Classes tab.
    final todaySessions = _getScheduledClassesForDate(now);

    for (final session in todaySessions) {
      final classItem = session.classItem;
      final slot = session.slot;

      // 1. Student must be enrolled.
      if (!enrolledClassIds.contains(classItem.id)) {
        continue;
      }

      // 2. Validate the scheduled start time.
      final parts = slot.startTime.split(':');

      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null ||
          minute == null ||
          hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        continue;
      }

      final classStart = DateTime(now.year, now.month, now.day, hour, minute);

      // 3. Apply the approved ±1-hour entry window.
      final allowedStart = classStart.subtract(const Duration(hours: 1));

      final allowedEnd = classStart.add(const Duration(hours: 1));

      final isWithinWindow =
          !now.isBefore(allowedStart) && !now.isAfter(allowedEnd);

      if (!isWithinWindow) {
        continue;
      }

      // 4. Exclude completed sessions.
      final isEnded = attendanceProvider.isSessionEnded(
        instituteId: classItem.instituteId,
        classId: classItem.id,
        date: now,
        startTime: slot.startTime,
      );

      if (isEnded) {
        continue;
      }

      eligibleSessions.add(session);
    }

    return eligibleSessions;
  }

  List<({InstituteClass classItem, ClassSlot slot})>
  _getScheduledClassesForDate(DateTime date) {
    final classes = context.read<ClassProvider>().allClasses;

    final scheduledClasses = <({InstituteClass classItem, ClassSlot slot})>[];

    for (final classItem in classes) {
      final selectedDay = DateTime(date.year, date.month, date.day);

      final classStartDate = DateTime(
        classItem.startDate.year,
        classItem.startDate.month,
        classItem.startDate.day,
      );

      if (selectedDay.isBefore(classStartDate)) {
        continue;
      }

      if (classItem.endDate != null) {
        final classEndDate = DateTime(
          classItem.endDate!.year,
          classItem.endDate!.month,
          classItem.endDate!.day,
        );

        if (selectedDay.isAfter(classEndDate)) {
          continue;
        }
      }

      for (final slot in classItem.slots) {
        if (slot.weekday == selectedDay.weekday) {
          scheduledClasses.add((classItem: classItem, slot: slot));
        }
      }
    }

    scheduledClasses.sort(
      (a, b) => a.slot.startTime.compareTo(b.slot.startTime),
    );

    return scheduledClasses;
  }

  // bool _isClassEligible(InstituteClass classItem) {
  //   final now = DateTime.now();

  //   for (final slot in classItem.slots) {
  //     // Check whether the class is scheduled for today.
  //     if (slot.weekday != now.weekday) {
  //       continue;
  //     }

  //     final parts = slot.startTime.split(':');

  //     if (parts.length != 2) {
  //       continue;
  //     }

  //     final hour = int.tryParse(parts[0]);
  //     final minute = int.tryParse(parts[1]);

  //     if (hour == null || minute == null) {
  //       continue;
  //     }

  //     final classStart = DateTime(now.year, now.month, now.day, hour, minute);

  //     final allowedStart = classStart.subtract(const Duration(hours: 1));

  //     final allowedEnd = classStart.add(const Duration(hours: 1));

  //     if (!now.isBefore(allowedStart) && !now.isAfter(allowedEnd)) {
  //       return true;
  //     }
  //   }

  //   return false;
  // }

  String _formatSelectedDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

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

    final today = DateTime.now();

    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    final formattedDate =
        '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';

    return isToday ? '$formattedDate · Today' : formattedDate;
  }

  String _formatClassTime(String time) {
    final parts = time.split(':');

    if (parts.length != 2) return time;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return time;

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildTab({required String title, required int index}) {
    final isSelected = _selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.authIcon,
              ),
            ),
          ),
          Container(
            height: 2,
            width: 28,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entry / Exit toggle
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.profileDivider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildGateModeButton(
                          title: 'Entry',
                          icon: Icons.check,
                          isSelected: _isEntry,
                          onTap: () {
                            if (_isEntry) return;

                            setState(() {
                              _isEntry = true;
                            });

                            _clearSelectedStudent();
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildGateModeButton(
                          title: 'Exit',
                          icon: Icons.logout,
                          isSelected: !_isEntry,
                          onTap: () {
                            if (!_isEntry) return;

                            setState(() {
                              _isEntry = false;
                            });

                            _clearSelectedStudent();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Group icon shown in the reference UI
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.profileDivider),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            _isEntry
                ? 'Scan student QR to check in'
                : 'Scan student QR to check out',
            style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
          ),

          const SizedBox(height: 5),

          // QR input field
          TextField(
            controller: _qrController,
            textInputAction: TextInputAction.done,
            onSubmitted: _searchStudent,
            decoration: InputDecoration(
              hintText: 'Enter student code or scan QR',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.authHint,
              ),
              prefixIcon: const Icon(
                Icons.qr_code,
                color: AppColors.authIcon,
                size: 20,
              ),
              suffixIcon: QrScanButton(
                scannerTitle: _isEntry
                    ? 'Scan Student Entry QR'
                    : 'Scan Student Exit QR',
                onScanned: (value) {
                  _qrController.text = value;
                  _searchStudent(value);
                },
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),

          if (_studentSearchError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _studentSearchError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          if (_selectedStudent != null) ...[
            const SizedBox(height: 16),

            // Student information card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.profileDivider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student name
                        Text(
                          _selectedStudent!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Student code and grade
                        Text(_selectedStudent!.studentCode),
                        Text(_selectedStudent!.grade),

                        const SizedBox(height: 6),

                        //  Active / Inactive Attendance Status widget
                        Consumer<AttendanceProvider>(
                          builder: (context, attendanceProvider, child) {
                            final activeAttendance = attendanceProvider
                                .getActiveAttendance(
                                  instituteId: _selectedStudent!.instituteId,
                                  studentId: _selectedStudent!.id,
                                );

                            final isActive = activeAttendance != null;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.green
                                      : AppColors.authIcon,
                                ),
                              ),
                            );
                          },
                        ),

                        // ADD ENROLLED CLASSES HERE
                        const SizedBox(height: 12),

                        const Text(
                          'Enrolled Classes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.authHeading,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Consumer<EnrollmentProvider>(
                          builder: (context, enrollmentProvider, child) {
                            final studentEnrollments = enrollmentProvider
                                .enrollments
                                .where(
                                  (enrollment) =>
                                      enrollment.studentId ==
                                          _selectedStudent!.id &&
                                      enrollment.status == 'enrolled',
                                )
                                .toList();

                            if (studentEnrollments.isEmpty) {
                              return const Text(
                                'No enrolled classes found.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.authIcon,
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: studentEnrollments.map((enrollment) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    '• ${enrollment.className}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.authIcon,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Enrolled and available classes
            const Text(
              'Eligible Classes',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            // if (_getEnrolledClasses().isEmpty)
            //   const Padding(
            //     padding: EdgeInsets.symmetric(vertical: 12),
            //     child: Text(
            //       'No classes available for attendance at this time.',
            //       style: TextStyle(fontSize: 13, color: AppColors.authIcon),
            //     ),
            //   )
            // else
            //   ..._getEnrolledClasses().map(
            //     (classItem) => Card(
            //       margin: const EdgeInsets.only(bottom: 10),
            //       child: ListTile(
            //         // title: Text(classItem.name),
            //         // subtitle: Text('${classItem.subject} • ${classItem.grade}'),
            //         // trailing: const Icon(Icons.chevron_right),
            //         onTap: () {
            //           setState(() {
            //             _selectedClass = classItem;
            //           });
            //         },
            //         title: Text(classItem.name),
            //         subtitle: Text('${classItem.subject} • ${classItem.grade}'),
            //         trailing: Icon(
            //           _selectedClass?.id == classItem.id
            //               ? Icons.check_circle
            //               : Icons.chevron_right,
            //           color: _selectedClass?.id == classItem.id
            //               ? AppColors.primary
            //               : AppColors.authIcon,
            //         ),
            //       ),
            //     ),
            //   ),
            Consumer<AttendanceProvider>(
              builder: (context, attendanceProvider, child) {
                final eligibleSessions = _getEligibleSessions();

                if (eligibleSessions.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No eligible classes available at this time.',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: eligibleSessions.map((session) {
                    final classItem = session.classItem;
                    final slot = session.slot;

                    final isSelected =
                        _selectedClass?.id == classItem.id &&
                        _selectedSlot?.startTime == slot.startTime &&
                        _selectedSlot?.hallId == slot.hallId;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: isSelected
                          ? const Color(0xFFE8ECFF)
                          : AppColors.surface,
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _selectedClass = classItem;
                            _selectedSlot = slot;
                          });
                        },
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.authIcon,
                        ),
                        title: Text(
                          classItem.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${_formatClassTime(slot.startTime)}'
                          ' – ${_formatClassTime(slot.endTime)}'
                          '\n${slot.hallName}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.authIcon,
                          ),
                        ),
                        isThreeLine: true,
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              )
                            : const Icon(
                                Icons.chevron_right,
                                color: AppColors.authIcon,
                              ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            // CONFIRM ENTRY BUTTON HERE
            if (_isEntry &&
                _selectedClass != null &&
                _selectedSlot != null) ...[
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _confirmStudentEntry,
                  icon: const Icon(Icons.login),
                  label: const Text('Confirm Entry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],

            // CANCEL/ NEXT STUDENT BUTTON HERE
            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: _clearSelectedStudent,
                child: const Text(
                  'Cancel / Next Student',
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGateModeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.authHeading,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.authHeading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassesTab() {
    return Consumer<ClassProvider>(
      builder: (context, classProvider, child) {
        final scheduledClasses = _getScheduledClassesForDate(_selectedDate);

        return Column(
          children: [
            // Date navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(
                          const Duration(days: 1),
                        );
                      });
                    },
                  ),

                  Expanded(
                    child: Text(
                      _formatSelectedDate(_selectedDate),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.add(
                          const Duration(days: 1),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.profileDivider),

            // Scheduled classes
            Expanded(
              child: classProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : classProvider.errorMessage != null
                  ? Center(child: Text(classProvider.errorMessage!))
                  : scheduledClasses.isEmpty
                  ? const Center(
                      child: Text(
                        'No classes scheduled for this date.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.authIcon,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: scheduledClasses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final session = scheduledClasses[index];

                        final classItem = session.classItem;
                        final slot = session.slot;

                        final teacherName = classItem.teachers.isNotEmpty
                            ? classItem.teachers.first.name
                            : 'No teacher assigned';

                        return Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.profileDivider,
                              ),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE3E7FF),
                                child: Icon(
                                  Icons.access_time,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                classItem.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  '${_formatClassTime(slot.startTime)}'
                                  ' – ${_formatClassTime(slot.endTime)}'
                                  ' · ${slot.hallName}'
                                  ' · $teacherName'
                                  ' · ${classItem.enrolledCount} enrolled',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.authIcon,
                                  ),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: AppColors.authIcon,
                              ),
                              onTap: () {
                                final attendanceProvider = context
                                    .read<AttendanceProvider>();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider<
                                          AttendanceProvider
                                        >.value(
                                          value: attendanceProvider,
                                          child: SessionRosterScreen(
                                            classItem: classItem,
                                            slot: slot,
                                            sessionDate: _selectedDate,
                                          ),
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
