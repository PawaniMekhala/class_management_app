import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/student_provider.dart';
import '../../providers/selected_institute_provider.dart';
import '../../widgets/cards/student_list_tile.dart';
import '../../widgets/common/qr_scan_button.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int? _loadedInstituteId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final instituteId = context
        .watch<SelectedInstituteProvider>()
        .selectedInstituteId;

    if (_loadedInstituteId != instituteId) {
      _loadedInstituteId = instituteId;

      // Load students after the current frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        context.read<StudentProvider>().loadStudents(instituteId);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildStudentsTab() {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: TextField(
                // Connect the controller to the search field.
                controller: _searchController,

                // Search while typing
                onChanged: provider.searchStudents,

                // Search when the keyboard search button is pressed.
                onSubmitted: provider.searchStudents,

                textInputAction: TextInputAction.search,

                // FIX: Make typed text clearly visible
                style: const TextStyle(
                  color: AppColors.authHeading,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),

                // FIX: Make the cursor visible
                cursorColor: AppColors.primary,

                decoration: InputDecoration(
                  hintText: 'Search name, QRcode, student no., mobile',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.authIcon,
                  ),

                  // LEFT: Search icon
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.authIcon,
                    size: 19,
                  ),

                  // Reusable QR scanner button
                  suffixIcon: QrScanButton(
                    scannerTitle: 'Scan Student QR',

                    onScanned: (code) {
                      // Display scanned code inside the search field.
                      _searchController.text = code;

                      // Move cursor to the end of the text.
                      _searchController.selection = TextSelection.collapsed(
                        offset: code.length,
                      );

                      // Search for the student using the scanned code.
                      provider.searchStudents(code);
                    },
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
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
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
                  : provider.students.isEmpty
                  ? const Center(child: Text('No students found'))
                  : RefreshIndicator(
                      onRefresh: () {
                        final instituteId = context
                            .read<SelectedInstituteProvider>()
                            .selectedInstituteId;

                        return provider.loadStudents(instituteId);
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: provider.students.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 55,
                          color: AppColors.profileDivider,
                        ),
                        itemBuilder: (context, index) {
                          final student = provider.students[index];

                          return StudentListTile(
                            student: student,
                            onTap: () {
                              // TODO: Open Student Details screen.
                              // Pass student.id and the selected
                              // institute ID to the details screen.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,

      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Students',
          style: TextStyle(
            color: AppColors.authHeading,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.authIcon,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Students'),
              Tab(text: 'Profile requests'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStudentsTab(),

                // We'll build this after you provide its UI.
                const Center(
                  child: Text(
                    'Student profile requests will appear here',
                    style: TextStyle(color: AppColors.authIcon, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          if (_tabController.index != 0) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            elevation: 4,
            icon: const Icon(Icons.add, size: 19),
            label: const Text(
              'Register student',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              // TODO: Navigate to RegisterStudentScreen
              // when we build it from your screenshot.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Register Student screen will be added next.'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
