import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/teacher_leave_model.dart';
import '../../providers/teacher_leave_provider.dart';
import 'teacher_leave_decision_screen.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/hall_provider.dart';

class TeacherLeaveTab extends StatelessWidget {
  const TeacherLeaveTab({super.key});

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

  Widget _filterButton(
    BuildContext context,
    String label,
    TeacherLeaveStatus? status,
    TeacherLeaveProvider provider,
  ) {
    final selected = provider.selectedFilter == status;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: OutlinedButton(
          onPressed: () => provider.setFilter(status),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
            backgroundColor: selected ? AppColors.primary : AppColors.surface,
            foregroundColor: selected ? Colors.white : AppColors.authHeading,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.profileDivider,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(label, style: const TextStyle(fontSize: 11)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherLeaveProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
              child: Row(
                children: [
                  _filterButton(
                    context,
                    'Pending',
                    TeacherLeaveStatus.pending,
                    provider,
                  ),
                  _filterButton(
                    context,
                    'Approved',
                    TeacherLeaveStatus.approved,
                    provider,
                  ),
                  _filterButton(
                    context,
                    'Rejected',
                    TeacherLeaveStatus.rejected,
                    provider,
                  ),
                  _filterButton(context, 'All', null, provider),
                ],
              ),
            ),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage != null &&
                      provider.requests.isEmpty) {
                    return Center(child: Text(provider.errorMessage!));
                  }

                  final requests = provider.requests;

                  if (requests.isEmpty) {
                    return const Center(
                      child: Text(
                        'No leave requests found',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.authIcon,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: requests.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final leave = requests[index];
                      final color = _statusColor(leave.status);

                      final start = DateFormat('d MMM yyyy')
                          .format(leave.startDate);
                      final end = DateFormat('d MMM yyyy')
                          .format(leave.endDate);

                      final dateText =
                          DateUtils.isSameDay(leave.startDate, leave.endDate)
                          ? start
                          : '$start - $end';

                      return Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            final leaveProvider = context
                                .read<TeacherLeaveProvider>();
                            final teacherProvider = context
                                .read<TeacherProvider>();
                            final hallProvider = context.read<HallProvider>();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider<
                                      TeacherLeaveProvider
                                    >.value(value: leaveProvider),
                                    ChangeNotifierProvider<
                                      TeacherProvider
                                    >.value(value: teacherProvider),
                                    ChangeNotifierProvider<HallProvider>.value(
                                      value: hallProvider,
                                    ),
                                  ],
                                  child: TeacherLeaveDecisionScreen(
                                    leaveId: leave.id,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.profileDivider,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  color: color,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        leave.teacherName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.authHeading,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        dateText,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.authIcon,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        leave.reason,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.authIcon,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${leave.affectedClassCount} affected class(es)',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.authIcon,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _statusText(leave.status),
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
      },
    );
  }
}
