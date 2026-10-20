import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/academic_course_provider.dart';
import '../../widgets/cards/academic_course_tile.dart';
import 'course_details_screen.dart';

class CoursesTab extends StatefulWidget {
  final int instituteId;

  const CoursesTab({super.key, required this.instituteId});

  @override
  State<CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<CoursesTab> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scheduleLoad();
  }

  @override
  void didUpdateWidget(covariant CoursesTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.instituteId != widget.instituteId) {
      _searchController.clear();
      _scheduleLoad();
    }
  }

  void _scheduleLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AcademicCourseProvider>().loadCourses(widget.instituteId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AcademicCourseProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: provider.searchCourses,
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.authHeading,
                ),
                decoration: InputDecoration(
                  hintText: 'Search courses',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.authIcon,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.authIcon,
                    size: 19,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.profileDivider,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage != null
                  ? Center(child: Text(provider.errorMessage!))
                  : provider.courses.isEmpty
                  ? const Center(child: Text('No courses found'))
                  : RefreshIndicator(
                      onRefresh: () => provider.loadCourses(widget.instituteId),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: provider.courses.length,
                        itemBuilder: (context, index) {
                          final course = provider.courses[index];

                          return AcademicCourseTile(
                            course: course,
                            onTap: () {
                              final courseProvider = context
                                  .read<AcademicCourseProvider>();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider.value(
                                    value: courseProvider,
                                    child: CourseDetailsScreen(
                                      instituteId: widget.instituteId,
                                      courseId: course.id,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
