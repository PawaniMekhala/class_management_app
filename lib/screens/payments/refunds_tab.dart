import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/refund_model.dart';
import '../../providers/refund_provider.dart';

import 'refund_details_screen.dart';

class RefundsTab extends StatefulWidget {
  final int instituteId;

  const RefundsTab({super.key, required this.instituteId});

  @override
  State<RefundsTab> createState() => _RefundsTabState();
}

class _RefundsTabState extends State<RefundsTab> {
  final TextEditingController _searchController = TextEditingController();

  DateTimeRange? _dateRange;

  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<RefundProvider>().loadRefunds(widget.instituteId);
    });
  }

  @override
  void didUpdateWidget(covariant RefundsTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.instituteId != widget.instituteId) {
      _selectedStatus = 'all';
      _dateRange = null;
      _searchController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        context.read<RefundProvider>().loadRefunds(widget.instituteId);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _money(double amount) {
    return amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2);
  }

  String _date(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'approved':
        return AppColors.primary;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.redAccent;
      default:
        return AppColors.authIcon;
    }
  }

  List<RefundModel> _filtered(List<RefundModel> refunds) {
    final query = _searchController.text.trim().toLowerCase();

    final results = refunds.where((refund) {
      final matchesSearch =
          query.isEmpty ||
          refund.studentName.toLowerCase().contains(query) ||
          refund.studentCode.toLowerCase().contains(query) ||
          refund.refundNumber.toLowerCase().contains(query) ||
          refund.receiptNumber.toLowerCase().contains(query) ||
          (refund.referenceNumber?.toLowerCase().contains(query) ?? false);

      final matchesStatus =
          _selectedStatus == 'all' || refund.status == _selectedStatus;

      bool matchesDate = true;

      if (_dateRange != null) {
        final date = DateUtils.dateOnly(refund.requestedAt);

        final start = DateUtils.dateOnly(_dateRange!.start);
        final end = DateUtils.dateOnly(_dateRange!.end);

        matchesDate = !date.isBefore(start) && !date.isAfter(end);
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    results.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

    return results;
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();

    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange,
      helpText: 'Filter refunds by date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _dateRange = selected);
    }
  }

  Widget _statusChip(RefundModel refund) {
    final color = _statusColor(refund.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(refund.status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _refundCard(RefundModel refund) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RefundDetailsScreen(refund: refund),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.moduleIconBackground,
                child: const Icon(
                  Icons.currency_exchange_outlined,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${refund.refundNumber} · ${refund.studentName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authHeading,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${_date(refund.requestedAt)} · '
                      '${refund.reason}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.authIcon,
                      ),
                    ),

                    const SizedBox(height: 6),

                    _statusChip(refund),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Text(
                'Rs. ${_money(refund.amount)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefundProvider>(
      builder: (context, provider, _) {
        final refunds = _filtered(provider.refunds);

        return RefreshIndicator(
          onRefresh: () => provider.loadRefunds(widget.instituteId),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              // Date filter
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
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
                        _dateRange == null
                            ? 'All dates'
                            : '${_date(_dateRange!.start)} - '
                                  '${_date(_dateRange!.end)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.authHeading,
                        ),
                      ),
                    ),

                    if (_dateRange != null)
                      IconButton(
                        tooltip: 'Clear date filter',
                        onPressed: () {
                          setState(() => _dateRange = null);
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

              // Status filter
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Refund status',
                    labelStyle: const TextStyle(fontSize: 11),
                    prefixIcon: const Icon(
                      Icons.filter_list,
                      color: AppColors.authIcon,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All statuses')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'approved',
                      child: Text('Approved'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Text('Rejected'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Student, refund no., receipt or reference',
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
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close, size: 18),
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

              const SizedBox(height: 8),

              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const Text('Unable to load refunds'),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () =>
                            provider.loadRefunds(widget.instituteId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (refunds.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.currency_exchange_outlined,
                        size: 48,
                        color: AppColors.authIcon,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No refunds found',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.authHeading,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...refunds.map(
                  (refund) => Column(
                    children: [
                      _refundCard(refund),
                      const Divider(height: 1, indent: 65),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
