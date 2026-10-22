import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/student_service.dart';
import '../../core/services/class_service.dart';
import '../../models/student_model.dart';
import '../../models/class_model.dart';
import '../../providers/enrollment_provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/common/qr_scan_button.dart';
import '../../core/services/payment_plan_service.dart';
import '../../models/payment_plan_model.dart';
import '../../widgets/common/payment_plan_dropdown.dart';

class EnrollStudentScreen extends StatefulWidget {
  final int instituteId;

  const EnrollStudentScreen({super.key, required this.instituteId});

  @override
  State<EnrollStudentScreen> createState() => _EnrollStudentScreenState();
}

class _EnrollStudentScreenState extends State<EnrollStudentScreen> {
  StudentModel? _student;
  InstituteClass? _selectedClass;
  PaymentPlanModel? _selectedPaymentPlan;
  List<PaymentPlanModel> _availablePaymentPlans = [];

  List<StudentModel> _students = [];
  List<InstituteClass> _classes = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final students = await StudentService().getStudents(widget.instituteId);
      final classes = await ClassService().getClasses(widget.instituteId);
      final paymentPlans = await PaymentPlanService().getPlans(
        widget.instituteId,
      );

      if (!mounted) return;

      setState(() {
        _students = students;
        _classes = classes;
        _availablePaymentPlans = paymentPlans;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load enrollment options')),
      );
    }
  }

  Future<void> _chooseStudent() async {
    final searchController = TextEditingController();
    String query = '';

    final chosen = await showModalBottomSheet<StudentModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, updateSheet) {
          final filtered = _students.where((student) {
            final q = query.toLowerCase();

            return student.name.toLowerCase().contains(q) ||
                student.studentCode.toLowerCase().contains(q) ||
                (student.mobile?.contains(q) ?? false) ||
                (student.nic?.toLowerCase().contains(q) ?? false) ||
                (student.qrCode?.toLowerCase().contains(q) ?? false);
          }).toList();

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(14),
                      child: Text(
                        'Choose student',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          updateSheet(() => query = value);
                        },
                        style: const TextStyle(
                          color: AppColors.authHeading,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search name, phone, QR or student no.',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: QrScanButton(
                            scannerTitle: 'Scan student QR',
                            onScanned: (code) {
                              searchController.text = code;
                              updateSheet(() => query = code);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final student = filtered[index];

                          return ListTile(
                            title: Text(student.name),
                            subtitle: Text(
                              '${student.studentCode} · ${student.grade}',
                            ),
                            onTap: () {
                              Navigator.pop(sheetContext, student);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    searchController.dispose();

    if (chosen != null && mounted) {
      setState(() => _student = chosen);
    }
  }

  Future<void> _chooseClass() async {
    final chosen = await showModalBottomSheet<InstituteClass>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choose class',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              for (final item in _classes)
                ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.code} · ${item.grade} · '
                    '${item.enrolledCount}/${item.maxStudents} students',
                  ),
                  onTap: () => Navigator.pop(sheetContext, item),
                ),
            ],
          ),
        ),
      ),
    );

    if (chosen != null && mounted) {
      PaymentPlanModel? defaultPlan;

      for (final plan in _availablePaymentPlans) {
        if (plan.name == chosen.paymentPlanName) {
          defaultPlan = plan;
          break;
        }
      }

      setState(() {
        _selectedClass = chosen;
        _selectedPaymentPlan = defaultPlan;
      });
    }
  }

  Widget _selectionTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 3),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.moduleIconBackground,
          child: Icon(icon, color: AppColors.authHeading, size: 19),
        ),
        title: Text(
          value,
          style: const TextStyle(fontSize: 13, color: AppColors.authHeading),
        ),
        subtitle: Text(title, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
      ),
    );
  }

  Future<void> _enroll() async {
    if (_student == null ||
        _selectedClass == null ||
        _selectedPaymentPlan == null) {
      return;
    }

    try {
      await context.read<EnrollmentProvider>().enroll(
        instituteId: widget.instituteId,
        studentId: _student!.id,
        studentName: _student!.name,
        studentCode: _student!.studentCode,
        studentPhone: _student!.mobile,
        studentGrade: _student!.grade,
        selectedClass: _selectedClass!,
        paymentPlan: _selectedPaymentPlan!.name,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student enrolled successfully')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to enroll: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final seatsLeft = _selectedClass == null
        ? 0
        : _selectedClass!.maxStudents - _selectedClass!.enrolledCount;

    final gradeMismatch =
        _student != null &&
        _selectedClass != null &&
        _student!.grade.trim().toLowerCase() !=
            _selectedClass!.grade.trim().toLowerCase();

    final alreadyEnrolled =
        _student != null &&
        _selectedClass != null &&
        _selectedClass!.students.any((s) => s.id == _student!.id);

    final canEnroll =
        _student != null &&
        _selectedClass != null &&
        seatsLeft > 0 &&
        !alreadyEnrolled &&
        _selectedPaymentPlan != null;

    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        title: const Text('Enroll student'),
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<EnrollmentProvider>(
              builder: (context, provider, _) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _selectionTile(
                      title: 'Student',
                      value: _student?.name ?? 'Choose student',
                      icon: Icons.person_outline,
                      onTap: _chooseStudent,
                    ),
                    _selectionTile(
                      title: 'Class',
                      value: _selectedClass?.name ?? 'Choose class',
                      icon: Icons.groups_outlined,
                      onTap: _chooseClass,
                    ),

                    if (_student != null && _selectedClass != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.moduleIconBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seatsLeft > 0
                                  ? 'Can enroll · $seatsLeft seats left'
                                  : 'Class is full',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.authHeading,
                              ),
                            ),
                            if (alreadyEnrolled)
                              const Text(
                                'This student is already in the class.',
                                style: TextStyle(fontSize: 11),
                              ),
                            if (gradeMismatch)
                              Text(
                                'Grade warning: The class is for '
                                '${_selectedClass!.grade}; the student '
                                'is in ${_student!.grade}.',
                                style: const TextStyle(fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // DropdownButtonFormField<String>(
                      //   key: ValueKey(_selectedClass!.id),
                      //   initialValue: _paymentPlan,
                      //   isExpanded: true,
                      //   decoration: InputDecoration(
                      //     labelText: 'Payment plan',
                      //     filled: true,
                      //     fillColor: AppColors.surface,
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   ),
                      //   items:
                      //       {
                      //         _selectedClass!.paymentPlanName,
                      //         'Scholarship free card',
                      //         'None',
                      //       }.map((plan) {
                      //         return DropdownMenuItem(
                      //           value: plan,
                      //           child: Text(
                      //             plan,
                      //             overflow: TextOverflow.ellipsis,
                      //           ),
                      //         );
                      //       }).toList(),
                      //   onChanged: (value) {
                      //     setState(() => _paymentPlan = value);
                      //   },
                      // ),

                      PaymentPlanDropdown(
                        plans: _availablePaymentPlans,
                        selectedPlan: _selectedPaymentPlan,
                        onChanged: (plan) {
                          setState(() {
                            _selectedPaymentPlan = plan;
                          });
                        },
                      ),

                      const SizedBox(height: 5),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'The class payment plan is selected by default. '
                          'You can choose another available plan.',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.authIcon,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      PrimaryButton(
                        text: 'Enroll Student',
                        icon: Icons.how_to_reg,
                        isLoading: provider.isSaving,
                        onPressed: canEnroll && !provider.isSaving
                            ? _enroll
                            : null,
                      ),
                    ],
                  ],
                );
              },
            ),
    );
  }
}
