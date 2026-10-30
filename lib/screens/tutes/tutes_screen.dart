import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

import 'package:provider/provider.dart';

import '../../models/tute_model.dart';
import '../../providers/tute_provider.dart';
import '../../models/class_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/enrollment_provider.dart';
import 'bulk_tute_distribution_screen.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';
import 'new_tute_screen.dart';
import 'distribute_tab.dart';

// import '../../widgets/buttons/register_fab.dart';

class TutesScreen extends StatefulWidget {
  const TutesScreen({super.key});

  @override
  State<TutesScreen> createState() => _TutesScreenState();
}

class _TutesScreenState extends State<TutesScreen> {
  int _selectedTab = 0;
  bool _showActive = true;

  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = [
    'Tutes',
    'Distribute',
    'History',
    'Pending',
    'Reissue',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      const instituteId = 1; // Temporary dummy institute ID

      context.read<TuteProvider>().loadTutes(instituteId);
      context.read<ClassProvider>().loadClasses(instituteId);
      context.read<EnrollmentProvider>().load(instituteId);
      context.read<StudentProvider>().loadStudents(instituteId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  InstituteClass? _getClassForTute(
    TuteModel tute,
    List<InstituteClass> classes,
  ) {
    for (final classItem in classes) {
      if (classItem.id == tute.classId &&
          classItem.instituteId == tute.instituteId) {
        return classItem;
      }
    }

    return null;
  }

  String _formatReleaseDate(DateTime date) {
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
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        elevation: 0,
        title: const Text(
          'Tutes & Materials',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
      ),
      body: Column(
        children: [
          // Five navigation tabs
          _buildTabs(),

          const Divider(height: 1, color: AppColors.profileDivider),

          Expanded(
            child: _selectedTab == 0
                ? _buildTutesTab()
                : _selectedTab == 1
                ? const DistributeTab()
                : _buildPlaceholderTab(),
          ),
        ],
      ),

      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                final classProvider = context.read<ClassProvider>();
                final tuteProvider = context.read<TuteProvider>();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider<ClassProvider>.value(
                          value: classProvider,
                        ),
                        ChangeNotifierProvider<TuteProvider>.value(
                          value: tuteProvider,
                        ),
                      ],
                      child: const NewTuteScreen(),
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'New tute',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  // --------------------------------------------------
  // MAIN NAVIGATION TABS
  // --------------------------------------------------

  Widget _buildTabs() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTab == index;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedTab = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.authIcon,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    height: 2,
                    width: 30,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // TUTES TAB
  // --------------------------------------------------

  Widget _buildTutesTab() {
    return Column(
      children: [
        const SizedBox(height: 12),

        // Active / Archived filter
        _buildStatusFilter(),

        const SizedBox(height: 14),

        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search tute, unit or class',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.authHint,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.authIcon,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.profileDivider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Tute list placeholder
        Expanded(
          child: Consumer3<TuteProvider, ClassProvider, EnrollmentProvider>(
            builder:
                (
                  context,
                  tuteProvider,
                  classProvider,
                  enrollmentProvider,
                  child,
                ) {
                  if (tuteProvider.isLoading ||
                      classProvider.isLoading ||
                      enrollmentProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (tuteProvider.errorMessage != null) {
                    return Center(child: Text(tuteProvider.errorMessage!));
                  }

                  if (classProvider.errorMessage != null) {
                    return Center(child: Text(classProvider.errorMessage!));
                  }

                  final query = _searchController.text.trim().toLowerCase();

                  final filteredTutes = tuteProvider.tutes.where((tute) {
                    final classItem = _getClassForTute(
                      tute,
                      classProvider.allClasses,
                    );

                    final className = classItem?.name.toLowerCase() ?? '';

                    final matchesStatus = _showActive
                        ? tute.status == TuteStatus.active
                        : tute.status == TuteStatus.archived;

                    final matchesSearch =
                        tute.name.toLowerCase().contains(query) ||
                        tute.unitName.toLowerCase().contains(query) ||
                        className.contains(query);

                    return matchesStatus && matchesSearch;
                  }).toList();

                  // Newest tutes first.
                  filteredTutes.sort(
                    (a, b) => b.releaseDate.compareTo(a.releaseDate),
                  );

                  if (filteredTutes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matching tutes found.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.authIcon,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredTutes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tute = filteredTutes[index];

                      final classItem = _getClassForTute(
                        tute,
                        classProvider.allClasses,
                      );

                      // Get all enrolled students for this class.
                      final enrolledStudentIds = enrollmentProvider.enrollments
                          .where(
                            (enrollment) =>
                                enrollment.instituteId == tute.instituteId &&
                                enrollment.classId == tute.classId &&
                                enrollment.status == 'enrolled',
                          )
                          .map((enrollment) => enrollment.studentId)
                          .toSet()
                          .toList();

                      final received = tuteProvider.receivedCount(
                        tuteId: tute.id,
                        enrolledStudentIds: enrolledStudentIds,
                      );

                      final pending = tuteProvider.pendingCount(
                        tuteId: tute.id,
                        enrolledStudentIds: enrolledStudentIds,
                      );

                      return Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Bulk Distribution navigation
                            if (classItem == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Associated class not found.'),
                                ),
                              );
                              return;
                            }

                            // Get the existing provider instances.
                            final tuteProvider = context.read<TuteProvider>();
                            final enrollmentProvider = context
                                .read<EnrollmentProvider>();
                            final attendanceProvider = context
                                .read<AttendanceProvider>();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider<TuteProvider>.value(
                                      value: tuteProvider,
                                    ),
                                    ChangeNotifierProvider<
                                      EnrollmentProvider
                                    >.value(value: enrollmentProvider),
                                    ChangeNotifierProvider<
                                      AttendanceProvider
                                    >.value(value: attendanceProvider),
                                  ],
                                  child: BulkTuteDistributionScreen(
                                    tute: tute,
                                    instituteClass: classItem,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 19,
                                  backgroundColor: Color(0xFFE8ECFF),
                                  child: Icon(
                                    Icons.menu_book,
                                    color: AppColors.primary,
                                    size: 19,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tute.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.authHeading,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        classItem?.name ?? 'Class not found',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.authIcon,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        'Released ${_formatReleaseDate(tute.releaseDate)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.authIcon,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$received/${enrolledStudentIds.length}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.authHeading,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    // Text(
                                    //   '$pending pending',
                                    //   style: TextStyle(
                                    //     fontSize: 10,
                                    //     color: pending > 0
                                    //         ? Colors.red
                                    //         : Colors.green,
                                    //   ),
                                    // ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (pending == 0 &&
                                            enrolledStudentIds.isNotEmpty)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 13,
                                          ),

                                        if (pending == 0 &&
                                            enrolledStudentIds.isNotEmpty)
                                          const SizedBox(width: 4),

                                        Text(
                                          enrolledStudentIds.isEmpty
                                              ? 'No students'
                                              : pending == 0
                                              ? 'Fully Distributed'
                                              : '$pending pending',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: enrolledStudentIds.isEmpty
                                                ? Colors.grey
                                                : pending == 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // ACTIVE / ARCHIVED FILTER
  // --------------------------------------------------

  Widget _buildStatusFilter() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.profileDivider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterButton(
              title: 'Active',
              isSelected: _showActive,
              onTap: () {
                setState(() {
                  _showActive = true;
                });
              },
            ),
            _buildFilterButton(
              title: 'Archived',
              isSelected: !_showActive,
              onTap: () {
                setState(() {
                  _showActive = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.authIcon,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // OTHER TABS (TEMPORARY)
  // --------------------------------------------------

  Widget _buildPlaceholderTab() {
    return Center(
      child: Text(
        '${_tabs[_selectedTab]} screen will be implemented next.',
        style: const TextStyle(fontSize: 13, color: AppColors.authIcon),
      ),
    );
  }
}
