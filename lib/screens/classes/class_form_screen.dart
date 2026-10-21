import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/hall_service.dart';
import '../../models/class_model.dart';
import '../../models/hall_model.dart';
import '../../providers/class_provider.dart';
import '../../widgets/buttons/primary_button.dart';

class ClassFormScreen extends StatefulWidget {
  final int instituteId;

  const ClassFormScreen({super.key, required this.instituteId});

  @override
  State<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _capacity = TextEditingController(text: '50');
  final _description = TextEditingController();

  String _level = 'Advanced Level';
  String _grade = 'Grade 12';
  String? _subject;
  String? _teacher;
  String _paymentPlan = 'None';

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  List<HallModel> _halls = [];
  final List<ClassSlot> _slots = [];

  bool _saving = false;
  bool _loadingHalls = true;

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadHalls();
  }

  Future<void> _loadHalls() async {
    try {
      final halls = await HallService().getHalls(widget.instituteId);
      if (!mounted) return;
      setState(() {
        _halls = halls;
        _loadingHalls = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingHalls = false);
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.authIcon),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.profileDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool numeric = false,
    bool requiredField = true,
    int lines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13, color: AppColors.authHeading),
      decoration: _decoration(label),
      validator: (value) {
        if (requiredField && (value == null || value.trim().isEmpty)) {
          return 'Please enter $label';
        }
        if (numeric && (int.tryParse(value ?? '') ?? 0) <= 0) {
          return 'Enter a number greater than zero';
        }
        return null;
      },
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: _decoration(label),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: label == 'Subject' && value == null
          ? (_) => 'Select a subject'
          : null,
    );
  }

  Future<void> _chooseDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startDate = date;
      } else {
        _endDate = date;
      }
    });
  }

  Future<void> _addSlot() async {
    if (_halls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an active hall first.')),
      );
      return;
    }

    int weekday = 1;
    int? hallId = _halls.first.id;
    TimeOfDay start = const TimeOfDay(hour: 16, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 18, minute: 0);

    final slot = await showDialog<ClassSlot>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) {
          return AlertDialog(
            title: const Text('Add weekly slot'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: weekday,
                    decoration: const InputDecoration(labelText: 'Day'),
                    items: List.generate(
                      7,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(_weekdays[i]),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) update(() => weekday = value);
                    },
                  ),
                  DropdownButtonFormField<int>(
                    initialValue: hallId,
                    decoration: const InputDecoration(labelText: 'Hall'),
                    items: _halls
                        .where((hall) => hall.status == 'active')
                        .map(
                          (hall) => DropdownMenuItem(
                            value: hall.id,
                            child: Text(hall.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => update(() => hallId = value),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: dialogContext,
                        initialTime: start,
                      );
                      if (picked != null) update(() => start = picked);
                    },
                    child: Text('Starts: ${start.format(context)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: dialogContext,
                        initialTime: end,
                      );
                      if (picked != null) update(() => end = picked);
                    },
                    child: Text('Ends: ${end.format(context)}'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (hallId == null) return;

                  final startMinutes = start.hour * 60 + start.minute;
                  final endMinutes = end.hour * 60 + end.minute;
                  if (endMinutes <= startMinutes) return;

                  final hall = _halls.firstWhere((h) => h.id == hallId);

                  String format(TimeOfDay time) {
                    return '${time.hour.toString().padLeft(2, '0')}:'
                        '${time.minute.toString().padLeft(2, '0')}';
                  }

                  Navigator.pop(
                    dialogContext,
                    ClassSlot(
                      weekday: weekday,
                      startTime: format(start),
                      endTime: format(end),
                      hallId: hall.id,
                      hallName: hall.name,
                    ),
                  );
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );

    if (slot != null && mounted) {
      setState(() => _slots.add(slot));
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    if (_slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one weekly slot.')),
      );
      return;
    }

    if (_endDate != null && _endDate!.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date.')),
      );
      return;
    }

    final item = InstituteClass(
      id: 0,
      instituteId: widget.instituteId,
      code: 'DEMO-${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      level: _level,
      grade: _grade,
      subject: _subject!,
      maxStudents: int.parse(_capacity.text),
      startDate: _startDate,
      endDate: _endDate,
      description: _description.text.trim(),
      paymentPlanName: _paymentPlan,
      teachers: _teacher == null || _teacher == 'Not assigned yet'
          ? []
          : [ClassTeacher(id: 0, name: _teacher!)],
      slots: List.of(_slots),
    );

    setState(() => _saving = true);

    try {
      await context.read<ClassProvider>().addClass(item);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save class: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _capacity.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        title: const Text('New class'),
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
          children: [
            _field('Class name', _name),
            const SizedBox(height: 12),
            _dropdown(
              'Level',
              _level,
              ['Primary', 'Secondary', 'Advanced Level', 'Diploma'],
              (value) {
                if (value != null) setState(() => _level = value);
              },
            ),
            const SizedBox(height: 12),
            _dropdown(
              'Grade',
              _grade,
              [
                'Grade 6',
                'Grade 7',
                'Grade 8',
                'Grade 9',
                'Grade 10',
                'Grade 11',
                'Grade 12',
                'Grade 13',
              ],
              (value) {
                if (value != null) setState(() => _grade = value);
              },
            ),
            const SizedBox(height: 12),
            _dropdown('Subject', _subject, [
              'Combined Mathematics',
              'Physics',
              'Chemistry',
              'Biology',
              'Accounting',
              'ICT',
              'English Language',
            ], (value) => setState(() => _subject = value)),
            const SizedBox(height: 12),
            _dropdown('Teacher', _teacher ?? 'Not assigned yet', [
              'Not assigned yet',
              'Prasad Wijesinghe',
              'Anoma Herath',
              'Lahiru Gamage',
            ], (value) => setState(() => _teacher = value)),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 5, bottom: 12),
              child: Text(
                'Teacher availability will be checked across institutes.',
                style: TextStyle(fontSize: 10, color: AppColors.authIcon),
              ),
            ),
            _dropdown(
              'Payment plan',
              _paymentPlan,
              [
                'None',
                'A/L monthly fee',
                'O/L monthly fee',
                'Seminar — one time',
                '10-session pack',
              ],
              (value) {
                if (value != null) setState(() => _paymentPlan = value);
              },
            ),
            const SizedBox(height: 12),
            _field('Maximum students', _capacity, numeric: true),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 5),
              child: Text(
                'Assigned halls must have enough seating capacity.',
                style: TextStyle(fontSize: 10, color: AppColors.authIcon),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _chooseDate(isStart: true),
                    child: Text(
                      'Starts: ${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => _chooseDate(isStart: false),
                    child: Text(
                      _endDate == null
                          ? 'Ends: Open-ended'
                          : 'Ends: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _field(
              'Description (optional)',
              _description,
              requiredField: false,
              lines: 2,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Weekly schedule',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.authHeading,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _loadingHalls ? null : _addSlot,
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('Add slot'),
                ),
              ],
            ),
            const Text(
              'Add the day, time and hall of each weekly class.',
              style: TextStyle(fontSize: 11, color: AppColors.authIcon),
            ),
            for (var i = 0; i < _slots.length; i++)
              ListTile(
                title: Text(
                  '${_weekdays[_slots[i].weekday - 1]} · '
                  '${_slots[i].startTime} – ${_slots[i].endTime}',
                  style: const TextStyle(fontSize: 12),
                ),
                subtitle: Text(_slots[i].hallName),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.primary),
                  onPressed: () => setState(() => _slots.removeAt(i)),
                ),
              ),
            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Save class',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
