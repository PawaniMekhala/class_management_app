import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/outstanding_model.dart';
import '../../providers/outstanding_provider.dart';
import '../../widgets/cards/outstanding_card.dart';

class OutstandingTab extends StatefulWidget {
  final int instituteId;

  const OutstandingTab({super.key, required this.instituteId});

  @override
  State<OutstandingTab> createState() => _OutstandingTabState();
}

class _OutstandingTabState extends State<OutstandingTab> {
  final TextEditingController _searchController = TextEditingController();

  int? _selectedClassId;

  bool _overdueOnly = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<OutstandingProvider>().loadOutstanding(widget.instituteId);
    });
  }

  @override
  void didUpdateWidget(covariant OutstandingTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.instituteId != widget.instituteId) {
      _selectedClassId = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        context.read<OutstandingProvider>().loadOutstanding(widget.instituteId);
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

  List<OutstandingModel> _filterRecords(List<OutstandingModel> records) {
    final query = _searchController.text.trim().toLowerCase();

    return records.where((item) {
      final matchesClass =
          _selectedClassId == null || item.charge.classId == _selectedClassId;

      final matchesOverdue = !_overdueOnly || item.isOverdue;

      final matchesSearch =
          query.isEmpty ||
          item.student.name.toLowerCase().contains(query) ||
          item.student.studentCode.toLowerCase().contains(query) ||
          item.charge.className.toLowerCase().contains(query) ||
          (item.student.mobile?.contains(query) ?? false);

      return matchesClass && matchesOverdue && matchesSearch;
    }).toList();
  }

  Widget _classDropdown(List<OutstandingModel> records) {
    final classMap = <int, String>{};

    for (final item in records) {
      classMap[item.charge.classId] = item.charge.className;
    }

    final classes = classMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return DropdownButtonFormField<int?>(
      key: ValueKey(_selectedClassId),
      initialValue: _selectedClassId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Class',
        labelStyle: const TextStyle(fontSize: 11),
        prefixIcon: const Icon(
          Icons.groups_outlined,
          size: 19,
          color: AppColors.authIcon,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('All classes', style: TextStyle(fontSize: 12)),
        ),
        ...classes.map(
          (entry) => DropdownMenuItem<int?>(
            value: entry.key,
            child: Text(
              entry.value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedClassId = value;
        });
      },
    );
  }

  Widget _summaryCard(List<OutstandingModel> records) {
    final total = records.fold<double>(0, (sum, item) => sum + item.balance);

    final studentCount = records.map((item) => item.student.id).toSet().length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.moduleIconBackground,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _overdueOnly ? 'Total overdue' : 'Total outstanding',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.authIcon,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${records.length} charges · '
                  '$studentCount students',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.authIcon,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rs. ${_money(total)}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.authHeading,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OutstandingProvider>(
      builder: (context, provider, _) {
        final records = _filterRecords(provider.outstanding);

        return RefreshIndicator(
          onRefresh: () => provider.loadOutstanding(widget.instituteId),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Class filter
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: _classDropdown(provider.outstanding),
              ),

              // Overdue only
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Overdue only',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.authHeading,
                        ),
                      ),
                    ),
                    Switch(
                      value: _overdueOnly,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _overdueOnly = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _summaryCard(records),
              ),

              const SizedBox(height: 10),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Student, number or class',
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

              const SizedBox(height: 10),

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
                      const Text('Unable to load outstanding payments'),
                      TextButton(
                        onPressed: () =>
                            provider.loadOutstanding(widget.instituteId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (records.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                        size: 45,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No outstanding payments found',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ...records.map(
                  (item) => Column(
                    children: [
                      OutstandingCard(outstanding: item),
                      const Divider(height: 1, indent: 16),
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
