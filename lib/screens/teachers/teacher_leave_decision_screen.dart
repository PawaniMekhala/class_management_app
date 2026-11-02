import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/teacher_leave_model.dart';
import '../../providers/teacher_leave_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/hall_provider.dart';

class TeacherLeaveDecisionScreen extends StatefulWidget {
  final int leaveId;

  const TeacherLeaveDecisionScreen({super.key, required this.leaveId});

  @override
  State<TeacherLeaveDecisionScreen> createState() =>
      _TeacherLeaveDecisionScreenState();
}

class _TeacherLeaveDecisionScreenState
    extends State<TeacherLeaveDecisionScreen> {
  final Map<int, LeaveAffectedClassModel> _arrangements = {};

  @override
  void initState() {
    super.initState();

    final leave = context.read<TeacherLeaveProvider>().getRequest(
      widget.leaveId,
    );

    if (leave != null) {
      for (final affectedClass in leave.affectedClasses) {
        _arrangements[affectedClass.id] = affectedClass;
      }
    }
  }

  String _date(DateTime date) {
    return DateFormat('EEE d MMM yyyy').format(date);
  }

  String _statusText(TeacherLeaveStatus status) {
    switch (status) {
      case TeacherLeaveStatus.pending:
        return 'Pending';
      case TeacherLeaveStatus.approved:
        return 'Approved';
      case TeacherLeaveStatus.rejected:
        return 'Rejected';
    }
  }

  Color _statusColor(TeacherLeaveStatus status) {
    switch (status) {
      case TeacherLeaveStatus.pending:
        return Colors.orange;
      case TeacherLeaveStatus.approved:
        return Colors.green;
      case TeacherLeaveStatus.rejected:
        return Colors.red;
    }
  }

  String _actionText(LeaveClassAction action) {
    switch (action) {
      case LeaveClassAction.cancel:
        return 'Cancel';
      case LeaveClassAction.substitute:
        return 'Substitute';
      case LeaveClassAction.move:
        return 'Move';
    }
  }

  void _changeAction(LeaveAffectedClassModel item, LeaveClassAction action) {
    setState(() {
      _arrangements[item.id] = item.copyWith(
        action: action,
        clearArrangement: true,
      );
    });
  }

  void _updateArrangement(LeaveAffectedClassModel item) {
    setState(() {
      _arrangements[item.id] = item;
    });
  }

  Future<void> _selectMovedDate(LeaveAffectedClassModel item) async {
    final date = await showDatePicker(
      context: context,
      initialDate: item.movedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (!mounted || date == null) return;

    _updateArrangement(item.copyWith(movedDate: date));
  }

  Future<void> _selectTime(
    LeaveAffectedClassModel item, {
    required bool start,
  }) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (!mounted || selected == null) return;

    final formatted = selected.format(context);

    _updateArrangement(
      start
          ? item.copyWith(movedStartTime: formatted)
          : item.copyWith(movedEndTime: formatted),
    );
  }

  Future<void> _submitDecision(
    TeacherLeaveModel leave,
    TeacherLeaveStatus status,
  ) async {
    final arrangements = leave.affectedClasses.map((item) {
      return _arrangements[item.id] ?? item;
    }).toList();

    String? comment;

    if (status == TeacherLeaveStatus.rejected) {
      final controller = TextEditingController();

      try {
        comment = await showDialog<String>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Reject leave request'),
              content: TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for rejection',
                  hintText: 'Enter a reason',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final reason = controller.text.trim();

                    if (reason.isNotEmpty) {
                      Navigator.pop(dialogContext, reason);
                    }
                  },
                  child: const Text('Reject'),
                ),
              ],
            );
          },
        );
      } finally {
        controller.dispose();
      }

      if (!mounted || comment == null) return;
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Approve leave request?'),
          content: const Text(
            'Confirm the class arrangements before approving.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Approve'),
            ),
          ],
        ),
      );

      if (!mounted || confirmed != true) return;
    }

    final provider = context.read<TeacherLeaveProvider>();

    final success = await provider.decideLeave(
      leaveId: leave.id,
      status: status,
      affectedClasses: arrangements,
      decisionComment: comment,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == TeacherLeaveStatus.approved
                ? 'Leave approved successfully.'
                : 'Leave rejected successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Unable to save decision.'),
        ),
      );
    }
  }

  Widget _actionButton(LeaveAffectedClassModel item, LeaveClassAction action) {
    final selected = item.action == action;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: OutlinedButton(
          onPressed: () => _changeAction(item, action),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            backgroundColor: selected ? AppColors.primary : Colors.white,
            foregroundColor: selected ? Colors.white : AppColors.authHeading,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.profileDivider,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          child: Text(
            _actionText(action),
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }

  Widget _arrangementFields(
    LeaveAffectedClassModel item,
    TeacherLeaveModel leave,
    bool editable,
  ) {
    if (item.action == LeaveClassAction.cancel) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Class will be cancelled. Notifications will be handled after backend integration.',
          style: TextStyle(fontSize: 11, color: AppColors.authIcon),
        ),
      );
    }

    if (item.action == LeaveClassAction.substitute) {
      final teachers = context
          .watch<TeacherProvider>()
          .allTeachers
          .where(
            (teacher) =>
                teacher.id != leave.teacherId &&
                teacher.instituteId == leave.instituteId,
          )
          .toList();

      final selectedId =
          teachers.any((teacher) => teacher.id == item.substituteTeacherId)
          ? item.substituteTeacherId
          : null;

      if (!editable) {
        final matches = teachers.where(
          (teacher) => teacher.id == item.substituteTeacherId,
        );
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            matches.isEmpty
                ? 'Substitute teacher ID: ${item.substituteTeacherId ?? "Not assigned"}'
                : 'Substitute: ${matches.first.name}',
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: DropdownButtonFormField<int>(
          key: ValueKey('sub_${item.id}_${selectedId ?? 0}'),
          initialValue: selectedId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Substitute teacher',
            border: OutlineInputBorder(),
          ),
          items: teachers.map((teacher) {
            return DropdownMenuItem(
              value: teacher.id,
              child: Text(teacher.name),
            );
          }).toList(),
          onChanged: (teacherId) {
            _updateArrangement(item.copyWith(substituteTeacherId: teacherId));
          },
        ),
      );
    }

    final halls = context
        .watch<HallProvider>()
        .allHalls
        .where(
          (hall) =>
              hall.instituteId == leave.instituteId &&
              hall.status.toLowerCase() == 'active',
        )
        .toList();

    if (!editable) {
      final matches = halls.where((hall) => hall.id == item.movedHallId);

      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Moved to: ${item.movedDate == null ? "Not set" : _date(item.movedDate!)}\n'
          '${item.movedStartTime ?? "-"} - ${item.movedEndTime ?? "-"}\n'
          'Hall: ${matches.isEmpty ? item.movedHallId ?? "Not set" : matches.first.name}',
          style: const TextStyle(fontSize: 11),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: () => _selectMovedDate(item),
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(
              item.movedDate == null
                  ? 'Select new date'
                  : _date(item.movedDate!),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _selectTime(item, start: true),
                  child: Text(
                    item.movedStartTime ?? 'Start time',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _selectTime(item, start: false),
                  child: Text(
                    item.movedEndTime ?? 'End time',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            key: ValueKey('hall_${item.id}_${item.movedHallId}'),
            initialValue: halls.any((hall) => hall.id == item.movedHallId)
                ? item.movedHallId
                : null,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select hall',
              border: OutlineInputBorder(),
            ),
            items: halls.map((hall) {
              return DropdownMenuItem(
                value: hall.id,
                child: Text('${hall.name} (${hall.number})'),
              );
            }).toList(),
            onChanged: (hallId) {
              _updateArrangement(item.copyWith(movedHallId: hallId));
            },
          ),
          const SizedBox(height: 6),
          const Text(
            'Hall and timetable availability will be verified after API integration.',
            style: TextStyle(fontSize: 10, color: AppColors.authIcon),
          ),
        ],
      ),
    );
  }

  Widget _classCard(
    LeaveAffectedClassModel original,
    TeacherLeaveModel leave,
    bool editable,
  ) {
    final item = _arrangements[original.id] ?? original;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.profileDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.className,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.authHeading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_date(item.classDate)} · ${item.startTime} - ${item.endTime}',
            style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
          ),
          Text(
            '${item.hallName} · ${item.studentCount} student(s)',
            style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
          ),
          const SizedBox(height: 12),

          if (editable)
            Row(
              children: [
                _actionButton(item, LeaveClassAction.cancel),
                _actionButton(item, LeaveClassAction.substitute),
                _actionButton(item, LeaveClassAction.move),
              ],
            )
          else
            Text(
              'Arrangement: ${_actionText(item.action)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),

          _arrangementFields(item, leave, editable),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherLeaveProvider>(
      builder: (context, provider, _) {
        final leave = provider.getRequest(widget.leaveId);

        if (leave == null) {
          return const Scaffold(
            body: Center(child: Text('Leave request not found.')),
          );
        }

        final editable = leave.status == TeacherLeaveStatus.pending;

        return Scaffold(
          backgroundColor: AppColors.profileBackground,
          appBar: AppBar(
            backgroundColor: AppColors.profileBackground,
            foregroundColor: AppColors.authHeading,
            title: Text(
              leave.teacherName,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_date(leave.startDate)} - ${_date(leave.endDate)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(leave.reason, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 10),
                    Text(
                      _statusText(leave.status),
                      style: TextStyle(
                        color: _statusColor(leave.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (leave.decisionComment != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Decision note: ${leave.decisionComment}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Classes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.authHeading,
                ),
              ),
              const SizedBox(height: 12),

              ...leave.affectedClasses.map(
                (item) => _classCard(item, leave, editable),
              ),

              if (editable) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: provider.isSaving
                            ? null
                            : () => _submitDecision(
                                leave,
                                TeacherLeaveStatus.rejected,
                              ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.isSaving
                            ? null
                            : () => _submitDecision(
                                leave,
                                TeacherLeaveStatus.approved,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: provider.isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
