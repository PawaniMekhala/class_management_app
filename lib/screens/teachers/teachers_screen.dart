import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/selected_institute_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../widgets/buttons/register_fab.dart';
import '../../widgets/cards/teacher_list_tile.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  int? _loadedInstituteId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final instituteId = context
        .watch<SelectedInstituteProvider>()
        .selectedInstituteId;

    if (_loadedInstituteId != instituteId) {
      _loadedInstituteId = instituteId;

      _searchController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        context.read<TeacherProvider>().loadTeachers(instituteId);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleTeacherMenu(String action, int teacherId) {
    switch (action) {
      case 'view':
        // TODO: Navigate to Teacher Details screen.
        break;

      case 'edit':
        // TODO: Navigate to Edit Teacher screen.
        break;

      case 'classes':
        // TODO: Navigate to Teacher Classes screen.
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Teacher action "$action" will be added next.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,

      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Teachers',
          style: TextStyle(
            color: AppColors.authHeading,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Consumer<TeacherProvider>(
              builder: (context, provider, child) {
                return TextField(
                  controller: _searchController,
                  onChanged: provider.searchTeachers,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.authHeading,
                  ),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Search name, code, mobile, NIC',
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
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.profileDivider,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.profileDivider,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                );
              },
            ),
          ),

          // Teacher list
          Expanded(
            child: Consumer<TeacherProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(child: Text(provider.errorMessage!));
                }

                if (provider.teachers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No teachers found',
                      style: TextStyle(color: AppColors.authIcon, fontSize: 12),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () {
                    final instituteId = context
                        .read<SelectedInstituteProvider>()
                        .selectedInstituteId;

                    return provider.loadTeachers(instituteId);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 95),
                    itemCount: provider.teachers.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: 63,
                      color: AppColors.profileDivider,
                    ),
                    itemBuilder: (context, index) {
                      final teacher = provider.teachers[index];

                      return TeacherListTile(
                        teacher: teacher,
                        onTap: () {
                          // TODO: Open Teacher Details screen.
                          // Pass teacher.id and selected institute ID.
                        },
                        onMenuSelected: (action) {
                          _handleTeacherMenu(action, teacher.id);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: RegisterFab(
        label: 'Register teacher',
        onPressed: () {
          // TODO: Open Find/Register Teacher screen
          // after its UI is developed.

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Teacher registration screen will be added next.'),
            ),
          );
        },
      ),
    );
  }
}
