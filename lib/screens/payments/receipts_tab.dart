import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/payment_service.dart';
import '../../core/services/student_service.dart';
import '../../models/payment_model.dart';
import '../../models/student_model.dart';
import '../../widgets/cards/receipt_card.dart';

import 'receipt_details_screen.dart';

class ReceiptsTab extends StatefulWidget {
  final int instituteId;

  const ReceiptsTab({super.key, required this.instituteId});

  @override
  State<ReceiptsTab> createState() => _ReceiptsTabState();
}

class _ReceiptsTabState extends State<ReceiptsTab> {
  final PaymentService _paymentService = PaymentService();
  final StudentService _studentService = StudentService();

  final TextEditingController _searchController = TextEditingController();

  List<StudentPayment> _payments = [];
  List<StudentModel> _students = [];

  DateTimeRange? _selectedDateRange;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  @override
  void didUpdateWidget(covariant ReceiptsTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.instituteId != widget.instituteId) {
      _payments = [];
      _students = [];
      _loadReceipts();
    }
  }

  Future<void> _loadReceipts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final payments = await _paymentService.getPayments(widget.instituteId);

      final students = await _studentService.getStudents(widget.instituteId);

      payments.sort((a, b) => b.paidAt.compareTo(a.paidAt));

      if (!mounted) return;

      setState(() {
        _payments = payments;
        _students = students;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  String _studentName(int studentId) {
    for (final student in _students) {
      if (student.id == studentId) {
        return student.name;
      }
    }

    return 'Student #$studentId';
  }

  StudentModel? _findStudent(int studentId) {
    for (final student in _students) {
      if (student.id == studentId) {
        return student;
      }
    }

    return null;
  }

  List<StudentPayment> get _filteredPayments {
    final query = _searchController.text.trim().toLowerCase();

    return _payments.where((payment) {
      final studentName = _studentName(payment.studentId).toLowerCase();

      final student = _findStudent(payment.studentId);

      final matchesSearch =
          query.isEmpty ||
          payment.receiptNumber.toLowerCase().contains(query) ||
          studentName.contains(query) ||
          (payment.referenceNumber?.toLowerCase().contains(query) ?? false) ||
          (student?.studentCode.toLowerCase().contains(query) ?? false);

      bool matchesDate = true;

      if (_selectedDateRange != null) {
        final date = DateUtils.dateOnly(payment.paidAt);

        final start = DateUtils.dateOnly(_selectedDateRange!.start);

        final end = DateUtils.dateOnly(_selectedDateRange!.end);

        matchesDate = !date.isBefore(start) && !date.isAfter(end);
      }

      return matchesSearch && matchesDate;
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedDateRange,
      helpText: 'Filter receipts by date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (range != null && mounted) {
      setState(() {
        _selectedDateRange = range;
      });
    }
  }

  void _openReceipt(StudentPayment payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptDetailsScreen(
          payment: payment,
          student: _findStudent(payment.studentId),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPayments;

    return RefreshIndicator(
      onRefresh: _loadReceipts,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Date filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                  size: 19,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    _selectedDateRange == null
                        ? 'All dates'
                        : '${_formatDate(_selectedDateRange!.start)}'
                              ' - '
                              '${_formatDate(_selectedDateRange!.end)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.authHeading,
                    ),
                  ),
                ),

                if (_selectedDateRange != null)
                  IconButton(
                    tooltip: 'Clear date filter',
                    onPressed: () {
                      setState(() {
                        _selectedDateRange = null;
                      });
                    },
                    icon: const Icon(Icons.close, size: 18),
                  ),

                IconButton(
                  tooltip: 'Select date range',
                  onPressed: _selectDateRange,
                  icon: const Icon(
                    Icons.edit_calendar_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Receipt no., student, reference',
                hintStyle: const TextStyle(
                  fontSize: 11,
                  color: AppColors.authIcon,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 19,
                  color: AppColors.authIcon,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text('Unable to load receipts'),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _loadReceipts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(50),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 50,
                    color: AppColors.authIcon,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No receipts found',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.authHeading,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Collected payments will appear here.',
                    style: TextStyle(fontSize: 11, color: AppColors.authIcon),
                  ),
                ],
              ),
            )
          else
            ...filtered.map(
              (payment) => Column(
                children: [
                  ReceiptCard(
                    payment: payment,
                    studentName: _studentName(payment.studentId),
                    onTap: () => _openReceipt(payment),
                  ),
                  const Divider(height: 1, indent: 65),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
