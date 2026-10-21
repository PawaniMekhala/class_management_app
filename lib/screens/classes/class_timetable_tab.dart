import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/class_service.dart';
import '../../core/services/hall_service.dart';
import '../../models/class_model.dart';
import '../../models/hall_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/selected_institute_provider.dart';

class ClassTimetableTab extends StatefulWidget {
  const ClassTimetableTab({super.key});

  @override
  State<ClassTimetableTab> createState() => _ClassTimetableTabState();
}

class _ClassTimetableTabState extends State<ClassTimetableTab> {
  late DateTime _weekStart;
  List<HallModel> _halls = [];
  int? _selectedHallId;
  int? _loadedInstituteId;

  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _months = [
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

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    _weekStart = normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final instituteId = context
        .watch<SelectedInstituteProvider>()
        .selectedInstituteId;

    if (_loadedInstituteId != instituteId) {
      _loadedInstituteId = instituteId;
      _selectedHallId = null;
      _halls = [];

      HallService().getHalls(instituteId).then((halls) {
        if (!mounted || _loadedInstituteId != instituteId) return;
        setState(() => _halls = halls);
      });
    }
  }

  String _date(DateTime date) => '${date.day} ${_months[date.month - 1]}';

  String _time(String value) {
    final parts = value.split(':');
    final hour = int.parse(parts[0]);
    return '${hour % 12 == 0 ? 12 : hour % 12}:${parts[1]} '
        '${hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<ClassProvider>().allClasses;
    final end = _weekStart.add(const Duration(days: 6));
    final service = ClassService();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _weekStart = _weekStart.subtract(const Duration(days: 7));
                  });
                },
                icon: const Icon(Icons.chevron_left, color: AppColors.primary),
              ),
              Expanded(
                child: Text(
                  '${_date(_weekStart)} – ${_date(end)} ${end.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.authHeading,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _weekStart = _weekStart.add(const Duration(days: 7));
                  });
                },
                icon: const Icon(Icons.chevron_right, color: AppColors.primary),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 43,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              _hallChip('All halls', null),
              for (final hall in _halls) _hallChip(hall.name, hall.id),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            children: [
              for (var offset = 0; offset < 7; offset++)
                _buildDay(
                  _weekStart.add(Duration(days: offset)),
                  classes,
                  service,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hallChip(String label, int? hallId) {
    final selected = _selectedHallId == hallId;

    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: selected,
        selectedColor: AppColors.moduleIconBackground,
        onSelected: (_) => setState(() => _selectedHallId = hallId),
      ),
    );
  }

  Widget _buildDay(
    DateTime date,
    List<InstituteClass> classes,
    ClassService service,
  ) {
    final entries = <({InstituteClass item, ClassSession session})>[];

    for (final item in classes) {
      final sessions = service.generateSessions(item, date, date);

      for (final session in sessions) {
        final matchingSlot = item.slots.any(
          (slot) =>
              slot.weekday == date.weekday &&
              slot.startTime == session.startTime &&
              slot.endTime == session.endTime &&
              (_selectedHallId == null || slot.hallId == _selectedHallId),
        );

        if (matchingSlot) {
          entries.add((item: item, session: session));
        }
      }
    }

    entries.sort((a, b) => a.session.startTime.compareTo(b.session.startTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${_days[date.weekday - 1]}, ${_date(date)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        for (final entry in entries)
          Container(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                right: BorderSide(color: AppColors.primary, width: 3),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    '${_time(entry.session.startTime)}\n'
                    '${_time(entry.session.endTime)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.authHeading,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.item.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.authHeading,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${entry.session.hallName} · '
                        '${entry.item.teachers.isEmpty ? 'Unassigned' : entry.item.teachers.first.name}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.authIcon,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
