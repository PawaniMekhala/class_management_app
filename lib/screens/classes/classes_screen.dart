import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/class_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/selected_institute_provider.dart';
import '../../widgets/buttons/register_fab.dart';
import 'class_details_screen.dart';
import 'class_form_screen.dart';
import 'class_timetable_tab.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int? _loadedInstituteId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final id = context.watch<SelectedInstituteProvider>().selectedInstituteId;

    if (_loadedInstituteId != id) {
      _loadedInstituteId = id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ClassProvider>().loadClasses(id);
      });
    }
  }

  void _openDetails(InstituteClass item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<ClassProvider>.value(
          value: context.read<ClassProvider>(),
          child: ClassDetailsScreen(item: item),
        ),
      ),
    );
  }

  void _newClass() {
    final id = context.read<SelectedInstituteProvider>().selectedInstituteId;
    final provider = context.read<ClassProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<ClassProvider>.value(
          value: provider,
          child: ClassFormScreen(instituteId: id),
        ),
      ),
    );
  }

  String _time(String value) {
    final parts = value.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    return '${hour % 12 == 0 ? 12 : hour % 12}:$minute '
        '${hour >= 12 ? 'PM' : 'AM'}';
  }

  String _schedule(InstituteClass item) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (item.slots.isEmpty) return 'No weekly schedule';

    return item.slots
        .map((slot) {
          return '${days[slot.weekday - 1]} '
              '${_time(slot.startTime)} – ${_time(slot.endTime)}';
        })
        .join(', ');
  }

  Widget _classesTab() {
    return Consumer<ClassProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              child: TextField(
                onChanged: provider.searchClasses,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.authHeading,
                ),
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: 'Search class, code, subject',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.authIcon,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 19),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage != null
                  ? Center(child: Text(provider.errorMessage!))
                  : provider.classes.isEmpty
                  ? const Center(child: Text('No classes found'))
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 95),
                      itemCount: provider.classes.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: AppColors.profileDivider,
                      ),
                      itemBuilder: (context, index) {
                        final item = provider.classes[index];
                        return InkWell(
                          onTap: () => _openDetails(item),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 11,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 19,
                                  backgroundColor:
                                      AppColors.moduleIconBackground,
                                  child: Text(
                                    item.subject.isEmpty
                                        ? 'C'
                                        : item.subject[0],
                                    style: const TextStyle(
                                      color: AppColors.authHeading,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.authHeading,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${item.code} · ${item.grade} · '
                                        '${item.teachers.isEmpty ? 'Unassigned' : item.teachers.first.name}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.authIcon,
                                        ),
                                      ),
                                      Text(
                                        _schedule(item),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.authHeading,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${item.enrolledCount}/${item.maxStudents}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.authIcon,
                                  ),
                                ),
                              ],
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

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        title: const Text(
          'Classes',
          style: TextStyle(
            color: AppColors.authHeading,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Filters',
            onPressed: () {
              // TO DO: Add advanced class filters.
            },
            icon: const Icon(Icons.filter_list, color: AppColors.authHeading),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.authIcon,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Classes'),
              Tab(text: 'Timetable'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [_classesTab(), const ClassTimetableTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabs.index == 0
          ? RegisterFab(label: 'New class', onPressed: _newClass)
          : null,
    );
  }
}
