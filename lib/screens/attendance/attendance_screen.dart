import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../models/class_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/enrollment_provider.dart';
import 'session_roster_screen.dart';
import '../../providers/attendance_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: AppBar(
        backgroundColor: AppColors.authBackground,
        elevation: 0,
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

  List<InstituteClass> _getEnrolledClasses() {
    if (_selectedStudent == null) return [];

    final classProvider = context.read<ClassProvider>();
    final enrollmentProvider = context.read<EnrollmentProvider>();

    final studentEnrollments = enrollmentProvider.enrollments.where(
      (enrollment) =>
          enrollment.studentId == _selectedStudent!.id &&
          enrollment.status == 'enrolled',
    );

    final enrolledClassIds = studentEnrollments
        .map((enrollment) => enrollment.classId)
        .toSet();

    return classProvider.allClasses.where((classItem) {
      final isEnrolled = enrolledClassIds.contains(classItem.id);

      final isEligible = _isClassEligible(classItem);

      return isEnrolled && isEligible;
    }).toList();
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

  bool _isClassEligible(InstituteClass classItem) {
    final now = DateTime.now();

    for (final slot in classItem.slots) {
      // Check whether the class is scheduled for today.
      if (slot.weekday != now.weekday) {
        continue;
      }

      final parts = slot.startTime.split(':');

      if (parts.length != 2) {
        continue;
      }

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) {
        continue;
      }

      final classStart = DateTime(now.year, now.month, now.day, hour, minute);

      final allowedStart = classStart.subtract(const Duration(hours: 1));

      final allowedEnd = classStart.add(const Duration(hours: 1));

      if (!now.isBefore(allowedStart) && !now.isAfter(allowedEnd)) {
        return true;
      }
    }

    return false;
  }

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
                            setState(() {
                              _isEntry = true;
                              _qrController.clear();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildGateModeButton(
                          title: 'Exit',
                          icon: Icons.logout,
                          isSelected: !_isEntry,
                          onTap: () {
                            setState(() {
                              _isEntry = false;
                              _qrController.clear();
                            });
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
                children: [
                  const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedStudent!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(_selectedStudent!.studentCode),
                        Text(_selectedStudent!.grade),
                        const SizedBox(height: 6),
                        const Text(
                          'Attendance: Inactive',
                          style: TextStyle(color: AppColors.authIcon),
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

            if (_getEnrolledClasses().isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No classes available for attendance at this time.',
                  style: TextStyle(fontSize: 13, color: AppColors.authIcon),
                ),
              )
            else
              ..._getEnrolledClasses().map(
                (classItem) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    // title: Text(classItem.name),
                    // subtitle: Text('${classItem.subject} • ${classItem.grade}'),
                    // trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      setState(() {
                        _selectedClass = classItem;
                      });
                    },
                    title: Text(classItem.name),
                    subtitle: Text('${classItem.subject} • ${classItem.grade}'),
                    trailing: Icon(
                      _selectedClass?.id == classItem.id
                          ? Icons.check_circle
                          : Icons.chevron_right,
                      color: _selectedClass?.id == classItem.id
                          ? AppColors.primary
                          : AppColors.authIcon,
                    ),
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
