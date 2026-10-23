import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/student_model.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';

class StudentPaymentDetailsScreen extends StatefulWidget {
  final int instituteId;
  final StudentModel student;

  const StudentPaymentDetailsScreen({
    super.key,
    required this.instituteId,
    required this.student,
  });

  @override
  State<StudentPaymentDetailsScreen> createState() =>
      _StudentPaymentDetailsScreenState();
}

class _StudentPaymentDetailsScreenState
    extends State<StudentPaymentDetailsScreen> {
  final Set<int> _selectedIds = {};
  final Map<int, double> _amounts = {};
  final TextEditingController _cashController = TextEditingController();

  String _method = 'cash';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaymentProvider>().loadStudentCharges(
        widget.instituteId,
        widget.student.id,
      );
    });
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  String _money(double amount) =>
      amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2);

  String _date(DateTime date) => '${date.day}/${date.month}/${date.year}';

  double _amountFor(PaymentCharge charge) =>
      _amounts[charge.id] ?? charge.balance;

  double _total(List<PaymentCharge> charges) {
    return charges
        .where((charge) => _selectedIds.contains(charge.id))
        .fold(0.0, (sum, charge) => sum + _amountFor(charge));
  }

  void _toggleCharge(PaymentCharge charge, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(charge.id);
        _amounts[charge.id] = charge.balance;
      } else {
        _selectedIds.remove(charge.id);
        _amounts.remove(charge.id);
      }
    });
  }

  void _selectAll(List<PaymentCharge> charges) {
    final allSelected = charges.every(
      (charge) => _selectedIds.contains(charge.id),
    );

    setState(() {
      if (allSelected) {
        _selectedIds.clear();
        _amounts.clear();
      } else {
        for (final charge in charges) {
          _selectedIds.add(charge.id);
          _amounts[charge.id] = charge.balance;
        }
      }
    });
  }

  Future<void> _editAmount(PaymentCharge charge) async {
    final controller = TextEditingController(text: _money(_amountFor(charge)));

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Partial payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available balance: Rs. ${_money(charge.balance)}'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Amount to collect',
                prefixText: 'Rs. ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());

              if (value == null ||
                  !value.isFinite ||
                  value <= 0 ||
                  value > charge.balance ||
                  (value * 100).roundToDouble() != value * 100) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Enter an amount from Rs. 0.01 to '
                      'Rs. ${_money(charge.balance)} '
                      'with at most 2 decimal places.',
                    ),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, value);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (amount != null && mounted) {
      setState(() {
        _selectedIds.add(charge.id);
        _amounts[charge.id] = amount;
      });
    }
  }

  Future<void> _collect(List<PaymentCharge> charges) async {
    if (_submitting) return;

    final selected = charges
        .where((charge) => _selectedIds.contains(charge.id))
        .toList();

    if (selected.isEmpty) return;

    final total = _total(charges);

    if (_method == 'cash' && _cashController.text.trim().isNotEmpty) {
      final received = double.tryParse(_cashController.text.trim());

      if (received == null || !received.isFinite || received < total) {
        _showMessage('Cash received must cover the total.');
        return;
      }
    }

    // Card, bank transfer and online payments require
    // real payment confirmation when the backend is added.
    if (_method != 'cash') {
      _showMessage(
        'Only demo cash collection is enabled. '
        'Other methods need payment confirmation.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm payment'),
        content: Text(
          'Collect Rs. ${_money(total)} from '
          '${widget.student.name} by cash?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);

    try {
      final payment = await context.read<PaymentProvider>().collect(
        instituteId: widget.instituteId,
        studentId: widget.student.id,
        method: _method,
        allocations: selected
            .map(
              (charge) => PaymentAllocation(
                chargeId: charge.id,
                amount: _amountFor(charge),
              ),
            )
            .toList(),
      );

      if (!mounted) return;

      setState(() {
        _selectedIds.clear();
        _amounts.clear();
        _cashController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Demo payment saved. Receipt: '
            '${payment.receiptNumber}',
          ),
        ),
      );
    } catch (error) {
      if (mounted) _showMessage('Payment failed: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _summaryBox(String title, double amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
            ),
            const SizedBox(height: 5),
            Text(
              'Rs. ${_money(amount)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chargeCard(PaymentCharge charge) {
    final selected = _selectedIds.contains(charge.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? AppColors.moduleIconBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  charge.className,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authHeading,
                  ),
                ),
              ),
              Checkbox(
                value: selected,
                activeColor: AppColors.primary,
                onChanged: (value) => _toggleCharge(charge, value ?? false),
              ),
            ],
          ),
          Text(
            charge.description,
            style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
          ),
          const SizedBox(height: 5),
          Text(
            'Charged: Rs. ${_money(charge.originalAmount)}'
            ' · Paid: Rs. ${_money(charge.paidAmount)}'
            ' · Balance: Rs. ${_money(charge.balance)}',
            style: const TextStyle(fontSize: 11, color: Colors.redAccent),
          ),
          if (charge.discountAmount > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${charge.discountDescription ?? 'Discount'}: '
              '- Rs. ${_money(charge.discountAmount)}',
              style: const TextStyle(fontSize: 11, color: Colors.teal),
            ),
          ],
          if (charge.tuteDescription != null) ...[
            const SizedBox(height: 5),
            Text(
              'Tutes to collect: ${charge.tuteDescription}',
              style: const TextStyle(fontSize: 11, color: Colors.orange),
            ),
          ],
          if (charge.isOverdue) ...[
            const SizedBox(height: 5),
            Text(
              'Overdue since ${_date(charge.dueDate)}',
              style: const TextStyle(fontSize: 11, color: Colors.redAccent),
            ),
          ],
          if (selected) ...[
            const Divider(),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Amount to collect',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                TextButton(
                  onPressed: () => _editAmount(charge),
                  child: Text('Rs. ${_money(_amountFor(charge))} · Edit'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _paymentMethodSelector() {
    const methods = [
      ('cash', 'Cash'),
      ('card', 'Card'),
      ('bank_transfer', 'Bank transfer'),
      ('online', 'Online'),
    ];

    return Row(
      children: methods.map((entry) {
        final selected = _method == entry.$1;

        return Expanded(
          child: InkWell(
            onTap: () => setState(() => _method = entry.$1),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                border: Border.all(color: AppColors.profileDivider),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                entry.$2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: selected ? Colors.white : AppColors.authHeading,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        final unpaid = provider.unpaidCharges;
        final total = _total(unpaid);
        final validSelection = unpaid.any(
          (charge) => _selectedIds.contains(charge.id),
        );

        return Scaffold(
          backgroundColor: AppColors.profileBackground,
          appBar: AppBar(
            backgroundColor: AppColors.profileBackground,
            foregroundColor: AppColors.authHeading,
            title: Text(
              widget.student.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.student.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${widget.student.studentCode}'
                                  ' · ${widget.student.grade}'
                                  '${widget.student.mobile == null ? '' : ' · ${widget.student.mobile}'}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.authIcon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _summaryBox('Total due', provider.totalDue),
                              const SizedBox(width: 5),
                              _summaryBox('Overdue', provider.overdue),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Classes and charges',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (provider.charges.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No charges are available '
                                'for this student.',
                              ),
                            ),
                          ...provider.charges.map(_chargeCard),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Unpaid charges',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton(
                                onPressed: unpaid.isEmpty
                                    ? null
                                    : () => _selectAll(unpaid),
                                child: const Text('Select all due'),
                              ),
                            ],
                          ),
                          if (unpaid.isEmpty)
                            const Text(
                              'No outstanding charges.',
                              style: TextStyle(color: AppColors.authIcon),
                            ),
                          ...unpaid.map((charge) {
                            final selected = _selectedIds.contains(charge.id);

                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.primary,
                              value: selected,
                              onChanged: (value) =>
                                  _toggleCharge(charge, value ?? false),
                              title: Text(
                                charge.className,
                                style: const TextStyle(fontSize: 12),
                              ),
                              subtitle: Text(
                                '${charge.description}\n'
                                'Rs. ${_money(charge.balance)}'
                                '${selected ? ' · Collect Rs. ${_money(_amountFor(charge))}' : ''}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              secondary: selected
                                  ? IconButton(
                                      tooltip: 'Partial payment',
                                      onPressed: () => _editAmount(charge),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                      ),
                                    )
                                  : null,
                            );
                          }),
                          if (validSelection) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: AppColors.moduleIconBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected (${_selectedIds.length})',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  ...unpaid
                                      .where(
                                        (charge) =>
                                            _selectedIds.contains(charge.id),
                                      )
                                      .map(
                                        (charge) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  charge.className,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Rs. ${_money(_amountFor(charge))}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total to collect',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Rs. ${_money(total)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                        color: AppColors.profileBackground,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _paymentMethodSelector(),
                            const SizedBox(height: 9),
                            if (_method == 'cash')
                              TextField(
                                controller: _cashController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  hintText: 'Cash received (optional)',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Payment confirmation integration '
                                  'is required for this method.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.authIcon,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 9),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed:
                                    !validSelection ||
                                        _submitting ||
                                        provider.isCollecting ||
                                        _method != 'cash'
                                    ? null
                                    : () => _collect(unpaid),
                                icon: const Icon(
                                  Icons.payments_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  _submitting
                                      ? 'Processing...'
                                      : validSelection
                                      ? 'Collect Rs. ${_money(total)}'
                                      : 'Select charges to collect',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      AppColors.profileDivider,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
