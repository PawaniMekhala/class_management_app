import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/student_service.dart';
import '../../models/student_model.dart';
import '../../widgets/common/student_search_field.dart';
import 'student_payment_details_screen.dart';
import '../../providers/payment_provider.dart';
import 'receipts_tab.dart';
import 'outstanding_tab.dart';
import 'refunds_tab.dart';

class PaymentsScreen extends StatefulWidget {
  final int instituteId;

  const PaymentsScreen({super.key, required this.instituteId});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _receiptsRefreshKey = 0;
  int _outstandingRefreshKey = 0;

  List<StudentModel> _students = [];
  List<StudentModel> _searchResults = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);

    // Refresh receipts when the Receipts tab is selected.
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      if (_tabController.index == 1) {
        setState(() {
          _receiptsRefreshKey++;
        });
      }

      if (_tabController.index == 2) {
        setState(() {
          _outstandingRefreshKey++;
        });
      }
    });

    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final students = await StudentService().getStudents(widget.instituteId);

      if (!mounted) return;

      setState(() {
        _students = students;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _collectTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: StudentSearchField(
            students: _students,
            onResultsChanged: (results) {
              setState(() {
                _searchResults = results;
              });
            },
          ),
        ),

        Expanded(
          child: _searchResults.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.point_of_sale,
                        size: 60,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Find the student',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.authHeading,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'A barcode / QR scanner types straight '
                          'into the search box.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.authIcon,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final student = _searchResults[index];

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_outline),
                      ),
                      title: Text(student.name),
                      subtitle: Text(
                        '${student.studentCode} · ${student.grade}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      // Navigate to StudentPaymentDetailsScreen.
                      onTap: () {
                        final paymentProvider = context.read<PaymentProvider>();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChangeNotifierProvider<PaymentProvider>.value(
                                  value: paymentProvider,
                                  child: StudentPaymentDetailsScreen(
                                    instituteId: widget.instituteId,
                                    student: student,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        title: const Text(
          'Payments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.authIcon,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontSize: 11),
          tabs: const [
            Tab(text: 'Collect'),
            Tab(text: 'Receipts'),
            Tab(text: 'Outstanding'),
            Tab(text: 'Refunds'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _collectTab(),
                ReceiptsTab(
                  key: ValueKey('${widget.instituteId}-$_receiptsRefreshKey'),
                  instituteId: widget.instituteId,
                ),
                OutstandingTab(
                  key: ValueKey(
                    '${widget.instituteId}-$_outstandingRefreshKey',
                  ),
                  instituteId: widget.instituteId,
                ),
                RefundsTab(instituteId: widget.instituteId),
              ],
            ),
    );
  }
}
