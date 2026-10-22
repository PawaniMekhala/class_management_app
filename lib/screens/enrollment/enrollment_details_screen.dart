import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/class_service.dart';
import '../../models/class_model.dart';
import '../../providers/enrollment_provider.dart';

class EnrollmentDetailsScreen extends StatefulWidget {
  final int enrollmentId;

  const EnrollmentDetailsScreen({super.key, required this.enrollmentId});

  @override
  State<EnrollmentDetailsScreen> createState() =>
      _EnrollmentDetailsScreenState();
}

class _EnrollmentDetailsScreenState extends State<EnrollmentDetailsScreen> {
  InstituteClass? _classItem;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final record = context.read<EnrollmentProvider>().getById(
      widget.enrollmentId,
    );

    if (record != null && _classItem == null) {
      ClassService()
          .getClass(record.instituteId, record.classId)
          .then((item) {
            if (mounted) setState(() => _classItem = item);
          })
          .catchError((_) {});
    }
  }

  Future<void> _changeStatus(String status) async {
    final provider = context.read<EnrollmentProvider>();
    final record = provider.getById(widget.enrollmentId);
    if (record == null) return;

    try {
      await provider.changeStatus(record, status);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enrollment status updated')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update enrollment')),
      );
    }
  }

  String _date(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _time(String value) {
    final parts = value.split(':');
    final hour = int.parse(parts[0]);
    return '${hour % 12 == 0 ? 12 : hour % 12}:${parts[1]} '
        '${hour >= 12 ? 'PM' : 'AM'}';
  }

  Widget _amount(String title, double? value, {bool red = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              value == null ? '—' : 'Rs. ${value.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: red ? Colors.redAccent : AppColors.authHeading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = context.watch<EnrollmentProvider>().getById(
      widget.enrollmentId,
    );

    if (record == null) {
      return const Scaffold(body: Center(child: Text('Enrollment not found')));
    }

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        title: Text(record.studentName, style: const TextStyle(fontSize: 16)),
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Manage enrollment',
            onSelected: _changeStatus,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'enrolled', child: Text('Set enrolled')),
              PopupMenuItem(value: 'suspended', child: Text('Suspend')),
              PopupMenuItem(value: 'dropped', child: Text('Drop')),
              PopupMenuItem(value: 'completed', child: Text('Complete')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.className,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: AppColors.authHeading,
                        ),
                      ),
                    ),
                    Chip(label: Text(record.status)),
                  ],
                ),
                Text(
                  '${record.classCode} · ${record.subject} · '
                  '${record.teacherName}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.authIcon,
                  ),
                ),
                const Divider(height: 24),
                Text(
                  '${record.studentName} · ${record.studentCode}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Enrolled ${_date(record.enrolledAt)}',
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  'Plan: ${record.paymentPlan}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _amount('Charged', record.charged),
              const SizedBox(width: 3),
              _amount('Paid', record.paid),
              const SizedBox(width: 3),
              _amount('Balance', record.balance, red: true),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Weekly schedule',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.authHeading,
            ),
          ),
          const SizedBox(height: 8),
          if (_classItem == null)
            const Text(
              'No schedule available',
              style: TextStyle(color: AppColors.authIcon),
            ),
          for (final slot in _classItem?.slots ?? <ClassSlot>[])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.moduleIconBackground,
                child: Text(
                  days[slot.weekday - 1],
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              title: Text(
                '${_time(slot.startTime)} – ${_time(slot.endTime)}',
                style: const TextStyle(fontSize: 12),
              ),
              subtitle: Text(
                slot.hallName,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Charges',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.authHeading,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Charge history will appear here when the payment '
            'backend is connected.',
            style: TextStyle(fontSize: 11, color: AppColors.authIcon),
          ),
        ],
      ),
    );
  }
}
