import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/enrollment_model.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/selected_institute_provider.dart';
import '../../widgets/buttons/register_fab.dart';
import 'enrollment_details_screen.dart';
import 'enroll_student_screen.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  int? _loadedInstituteId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final id = context.watch<SelectedInstituteProvider>().selectedInstituteId;

    if (_loadedInstituteId != id) {
      _loadedInstituteId = id;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<EnrollmentProvider>().load(id);
      });
    }
  }

  void _openDetails(EnrollmentModel record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<EnrollmentProvider>.value(
          value: context.read<EnrollmentProvider>(),
          child: EnrollmentDetailsScreen(enrollmentId: record.id),
        ),
      ),
    );
  }

  void _openEnroll() {
    final provider = context.read<EnrollmentProvider>();
    final instituteId = context
        .read<SelectedInstituteProvider>()
        .selectedInstituteId;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<EnrollmentProvider>.value(
          value: provider,
          child: EnrollStudentScreen(instituteId: instituteId),
        ),
      ),
    );
  }

  String _date(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Widget _recordTile(EnrollmentModel record) {
    final balance = record.balance;

    return InkWell(
      onTap: () => _openDetails(record),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.moduleIconBackground,
              child: Text(
                record.studentName.isEmpty ? '?' : record.studentName[0],
                style: const TextStyle(color: AppColors.authHeading),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.studentName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.authHeading,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${record.classCode} ${record.className} · '
                    '${record.paymentPlan} · since ${_date(record.enrolledAt)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.authIcon,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (balance != null && balance > 0)
              Text(
                'Rs. ${balance.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.profileBackground,
        title: const Text(
          'Enrollment',
          style: TextStyle(
            color: AppColors.authHeading,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<EnrollmentProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final status in [
                      'enrolled',
                      'suspended',
                      'dropped',
                      'completed',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: provider.selectedStatus == status,
                          selectedColor: AppColors.moduleIconBackground,
                          label: Text(
                            '${status[0].toUpperCase()}${status.substring(1)}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onSelected: (_) => provider.setStatus(status),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                child: TextField(
                  onChanged: provider.search,
                  cursorColor: AppColors.primary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.authHeading,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search student, class, number, phone',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.authIcon,
                    ),
                    prefixIcon: const Icon(Icons.search),
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
                    : provider.enrollments.isEmpty
                    ? const Center(child: Text('No enrollments found'))
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 95),
                        itemCount: provider.enrollments.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          color: AppColors.profileDivider,
                        ),
                        itemBuilder: (context, index) {
                          return _recordTile(provider.enrollments[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: RegisterFab(
        label: 'Enroll student',
        onPressed: _openEnroll,
      ),
    );
  }
}
