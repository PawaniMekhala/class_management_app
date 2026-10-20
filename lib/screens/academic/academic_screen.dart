import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/academic_subject_provider.dart';
import '../../providers/selected_institute_provider.dart';
import '../../widgets/buttons/register_fab.dart';
import '../../widgets/cards/academic_subject_tile.dart';
import 'subject_details_screen.dart';

class AcademicScreen extends StatefulWidget {
  const AcademicScreen({super.key});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  int? _loadedInstituteId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

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
        context.read<AcademicSubjectProvider>().loadSubjects(instituteId);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openSubject({required int instituteId, int? subjectId}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<AcademicSubjectProvider>.value(
          value: context.read<AcademicSubjectProvider>(),
          child: SubjectDetailsScreen(
            instituteId: instituteId,
            subjectId: subjectId,
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      _searchController.clear();
      await context.read<AcademicSubjectProvider>().loadSubjects(instituteId);
    }
  }

  Widget _buildSubjectsTab() {
    return Consumer<AcademicSubjectProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: provider.searchSubjects,
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.authHeading,
                ),
                decoration: InputDecoration(
                  hintText: 'Search subjects',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.authIcon,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 19,
                    color: AppColors.authIcon,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage != null
                  ? Center(child: Text(provider.errorMessage!))
                  : provider.subjects.isEmpty
                  ? const Center(child: Text('No subjects found'))
                  : RefreshIndicator(
                      onRefresh: () {
                        final instituteId = context
                            .read<SelectedInstituteProvider>()
                            .selectedInstituteId;
                        return provider.loadSubjects(instituteId);
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: provider.subjects.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 64,
                          color: AppColors.profileDivider,
                        ),
                        itemBuilder: (context, index) {
                          final subject = provider.subjects[index];

                          return AcademicSubjectTile(
                            subject: subject,
                            onTap: () => _openSubject(
                              instituteId: subject.instituteId,
                              subjectId: subject.id,
                            ),
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
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.profileBackground,
        elevation: 0,
        title: const Text(
          'Academic',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.authIcon,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Subjects & modules'),
              Tab(text: 'Courses'),
              Tab(text: 'Payment plans'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSubjectsTab(),
                const Center(child: Text('Courses will be added next')),
                const Center(child: Text('Payment plans will be added next')),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? RegisterFab(
              label: 'New subject',
              onPressed: () {
                final instituteId = context
                    .read<SelectedInstituteProvider>()
                    .selectedInstituteId;

                _openSubject(instituteId: instituteId);
              },
            )
          : null,
    );
  }
}
