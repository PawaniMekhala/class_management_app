import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../models/class_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/enrollment_provider.dart';

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
    return const Center(
      child: Text(
        'Classes attendance will be implemented next.',
        style: TextStyle(fontSize: 13, color: AppColors.authIcon),
      ),
    );
  }
}
