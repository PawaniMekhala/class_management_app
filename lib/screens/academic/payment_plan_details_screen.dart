import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/payment_plan_service.dart';
import '../../models/payment_plan_model.dart';
import '../../providers/payment_plan_provider.dart';
import '../../widgets/buttons/primary_button.dart';

class PaymentPlanDetailsScreen extends StatefulWidget {
  final int instituteId;
  final int? planId;

  const PaymentPlanDetailsScreen({
    super.key,
    required this.instituteId,
    this.planId,
  });

  @override
  State<PaymentPlanDetailsScreen> createState() =>
      _PaymentPlanDetailsScreenState();
}

class _PaymentPlanDetailsScreenState extends State<PaymentPlanDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = PaymentPlanService();

  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _reason = TextEditingController();
  final _sessions = TextEditingController();
  final _installments = TextEditingController();
  final _customPeriod = TextEditingController();
  final _teacherShare = TextEditingController(text: '70');
  final _instituteShare = TextEditingController(text: '30');

  final List<PaymentDiscount> _discounts = [];
  final List<TextEditingController> _installmentAmountControllers = [];
  final List<DateTime?> _installmentDueDates = [];

  PaymentPlanModel? _original;
  String _type = 'one_time';
  String _period = 'Monthly';
  String _paymentDue = 'First week of the month';
  DateTime? _dueDate;
  DateTime? _creditExpiry;
  bool _equalInstallments = true;
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isNew => widget.planId == null;
  bool get _typeLocked => (_original?.classCount ?? 0) > 0;

  static const _types = {
    'one_time': 'One-time',
    'time_based': 'Time based',
    'attendance_based': 'Attendance based',
    'installments': 'Installments',
    'other': 'Other payments',
    'free_card': 'Free card',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      if (!_isNew) {
        final plans = await _service.getPlans(widget.instituteId);
        PaymentPlanModel? found;

        for (final plan in plans) {
          if (plan.id == widget.planId) {
            found = plan;
            break;
          }
        }

        if (found == null) throw Exception('Plan not found');

        _original = found;
        _name.text = found.name;
        _amount.text = found.amount.toStringAsFixed(0);
        _description.text = found.description;
        _reason.text = found.reason ?? '';
        _sessions.text = found.sessionCount?.toString() ?? '';
        _installments.text = found.installmentCount?.toString() ?? '';
        _teacherShare.text = found.teacherPercentage.toStringAsFixed(0);
        _instituteShare.text = found.institutePercentage.toStringAsFixed(0);

        _type = found.type;
        _period = found.period ?? 'Monthly';
        _paymentDue = found.paymentDue ?? 'First week of the month';
        _dueDate = found.dueDate;
        _creditExpiry = found.creditExpiry;
        _discounts.addAll(found.discounts);

        _equalInstallments =
            found.installmentAmounts.isEmpty ||
            found.installmentAmounts.every(
              (amount) => amount == found!.installmentAmounts.first,
            );

        if (!_equalInstallments) {
          for (final amount in found.installmentAmounts) {
            _installmentAmountControllers.add(
              TextEditingController(text: amount.toStringAsFixed(2)),
            );
            _installmentDueDates.add(null);
          }
        }
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load payment plan.')),
      );
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.authIcon),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.profileDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool requiredField = false,
    bool numeric = false,
    int lines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      cursorColor: AppColors.primary,
      style: const TextStyle(color: AppColors.authHeading, fontSize: 13),
      decoration: _decoration(label),
      validator: (value) {
        if (requiredField && (value == null || value.trim().isEmpty)) {
          return 'Required field';
        }
        if (numeric && requiredField) {
          final number = double.tryParse(value ?? '');
          if (number == null || number <= 0) {
            return 'Enter a value greater than zero';
          }
        }
        return null;
      },
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged, {
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: _decoration(label),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(
            option,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  Future<DateTime?> _pickDate(DateTime? initial) async {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
  }

  Widget _dateField(
    String label,
    DateTime? date,
    ValueChanged<DateTime?> onSelected,
  ) {
    return OutlinedButton.icon(
      onPressed: () async {
        final selected = await _pickDate(date);
        if (selected != null && mounted) {
          setState(() => onSelected(selected));
        }
      },
      icon: const Icon(Icons.calendar_today_outlined, size: 17),
      label: Text(
        date == null ? label : '$label: ${date.day}/${date.month}/${date.year}',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.authHeading,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(15),
      ),
    );
  }

  void _syncInstallmentFields(int count) {
    while (_installmentAmountControllers.length < count) {
      _installmentAmountControllers.add(TextEditingController());
      _installmentDueDates.add(null);
    }

    while (_installmentAmountControllers.length > count) {
      _installmentAmountControllers.removeLast().dispose();
      _installmentDueDates.removeLast();
    }
  }

  Widget _typeFields() {
    switch (_type) {
      case 'one_time':
        return Column(
          children: [
            _field(
              'Class fee (Rs.)',
              _amount,
              requiredField: true,
              numeric: true,
            ),
            const SizedBox(height: 12),
            _dateField(
              'Due date (optional)',
              _dueDate,
              (date) => _dueDate = date,
            ),
          ],
        );

      case 'time_based':
        return Column(
          children: [
            _field(
              'Fee per period (Rs.)',
              _amount,
              requiredField: true,
              numeric: true,
            ),
            const SizedBox(height: 12),
            _dropdown('Period', _period, [
              'Daily',
              'Weekly',
              'Monthly',
              'Quarterly',
              'Yearly',
              'Custom',
            ], (value) => setState(() => _period = value!)),
            if (_period == 'Custom') ...[
              const SizedBox(height: 12),
              _field('Custom period', _customPeriod, requiredField: true),
            ],
            const SizedBox(height: 12),
            _dropdown('Payment due', _paymentDue, [
              'Before class',
              'First week of the month',
              'Specific date',
            ], (value) => setState(() => _paymentDue = value!)),
            if (_paymentDue == 'Specific date') ...[
              const SizedBox(height: 12),
              _dateField(
                'Select due date',
                _dueDate,
                (date) => _dueDate = date,
              ),
            ],
          ],
        );

      case 'attendance_based':
        return Column(
          children: [
            _field(
              'Number of sessions',
              _sessions,
              requiredField: true,
              numeric: true,
            ),
            const SizedBox(height: 12),
            _field('Fee (Rs.)', _amount, requiredField: true, numeric: true),
            const SizedBox(height: 12),
            _dateField(
              'Credit expiry (optional)',
              _creditExpiry,
              (date) => _creditExpiry = date,
            ),
          ],
        );

      case 'installments':
        final count = int.tryParse(_installments.text) ?? 0;
        final safeCount = count.clamp(0, 36);
        if (!_equalInstallments) {
          _syncInstallmentFields(safeCount);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(
              'Total course fee (Rs.)',
              _amount,
              requiredField: true,
              numeric: true,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Equal installments',
                style: TextStyle(fontSize: 13),
              ),
              value: _equalInstallments,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _equalInstallments = value),
            ),
            TextFormField(
              controller: _installments,
              keyboardType: TextInputType.number,
              decoration: _decoration('Number of installments'),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                final number = int.tryParse(value ?? '');
                if (number == null || number < 1 || number > 36) {
                  return 'Enter 1–36 installments';
                }
                return null;
              },
            ),
            if (_equalInstallments && count > 0) ...[
              const SizedBox(height: 10),
              Text(
                'Each installment: Rs. '
                '${((double.tryParse(_amount.text) ?? 0) / count).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
              ),
            ],
            if (!_equalInstallments)
              for (var i = 0; i < safeCount; i++) ...[
                const SizedBox(height: 12),
                _field(
                  'Installment ${i + 1} amount (Rs.)',
                  _installmentAmountControllers[i],
                  requiredField: true,
                  numeric: true,
                ),
                const SizedBox(height: 6),
                _dateField(
                  'Installment ${i + 1} due date (optional)',
                  _installmentDueDates[i],
                  (date) => _installmentDueDates[i] = date,
                ),
              ],
          ],
        );

      case 'other':
        return Column(
          children: [
            _field(
              'Payment amount (Rs.)',
              _amount,
              requiredField: true,
              numeric: true,
            ),
            const SizedBox(height: 12),
            _field('Reason', _reason, requiredField: true),
            const SizedBox(height: 12),
            _dateField(
              'Due date (optional)',
              _dueDate,
              (date) => _dueDate = date,
            ),
          ],
        );

      case 'free_card':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No payment is collected for this plan.',
              style: TextStyle(fontSize: 12, color: AppColors.authIcon),
            ),
            const SizedBox(height: 12),
            _field('Reason / eligibility', _reason),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _addDiscount() async {
    final name = TextEditingController();
    final value = TextEditingController();
    String type = 'percentage';

    final result = await showDialog<PaymentDiscount>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: const Text('Add discount'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Discount name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(
                      value: 'percentage',
                      child: Text('Percentage'),
                    ),
                    DropdownMenuItem(
                      value: 'fixed',
                      child: Text('Fixed amount'),
                    ),
                  ],
                  onChanged: (v) => updateDialog(() => type = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: type == 'percentage'
                        ? 'Percentage (%)'
                        : 'Amount (Rs.)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(value.text);
                if (name.text.trim().isEmpty ||
                    amount == null ||
                    amount <= 0 ||
                    (type == 'percentage' && amount > 100)) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  PaymentDiscount(
                    name: name.text.trim(),
                    type: type,
                    value: amount,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    name.dispose();
    value.dispose();

    if (result != null && mounted) {
      setState(() => _discounts.add(result));
    }
  }

  Widget _discountSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Discounts',
              style: TextStyle(fontSize: 13, color: AppColors.authHeading),
            ),
            TextButton.icon(
              onPressed: _addDiscount,
              icon: const Icon(Icons.add, size: 17),
              label: const Text('Add discount'),
            ),
          ],
        ),
        for (var i = 0; i < _discounts.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.primary,
            ),
            title: Text(
              _discounts[i].name,
              style: const TextStyle(fontSize: 12),
            ),
            subtitle: Text(
              _discounts[i].type == 'percentage'
                  ? 'Percentage · ${_discounts[i].value}%'
                  : 'Fixed amount · Rs. ${_discounts[i].value}',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: AppColors.primary),
              onPressed: () => setState(() => _discounts.removeAt(i)),
            ),
          ),
      ],
    );
  }

  Widget _contributionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contribution rules',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Divide the collected payment between the teacher '
          'and the institute.',
          style: TextStyle(fontSize: 11, color: AppColors.authIcon),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _teacherShare,
                keyboardType: TextInputType.number,
                decoration: _decoration('Teacher %'),
                validator: _percentageValidator,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _instituteShare,
                keyboardType: TextInputType.number,
                decoration: _decoration('Institute %'),
                validator: _percentageValidator,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Both percentages must add up to 100%.',
          style: TextStyle(fontSize: 11, color: AppColors.authIcon),
        ),
      ],
    );
  }

  String? _percentageValidator(String? value) {
    final number = double.tryParse(value ?? '');
    if (number == null || number < 0 || number > 100) {
      return 'Enter 0–100';
    }
    return null;
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final teacher = double.tryParse(_teacherShare.text) ?? 0;
    final institute = double.tryParse(_instituteShare.text) ?? 0;

    if ((teacher + institute - 100).abs() > 0.001) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teacher and institute shares must total 100%.'),
        ),
      );
      return;
    }

    if (_type == 'time_based' &&
        _paymentDue == 'Specific date' &&
        _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a payment due date.')),
      );
      return;
    }

    final amount = _type == 'free_card'
        ? 0.0
        : double.parse(_amount.text.trim());

    final count = _type == 'installments'
        ? int.parse(_installments.text.trim())
        : null;

    List<double> installmentAmounts = [];

    if (_type == 'installments') {
      if (_equalInstallments) {
        // Rounded to cents, with any remainder in the last installment.
        final cents = (amount * 100).round();
        final baseCents = cents ~/ count!;
        final remainder = cents - baseCents * count;
        installmentAmounts = List.generate(
          count,
          (i) => (baseCents + (i == count - 1 ? remainder : 0)) / 100,
        );
      } else {
        installmentAmounts = _installmentAmountControllers
            .map((c) => double.parse(c.text.trim()))
            .toList();

        final total = installmentAmounts.fold<double>(
          0,
          (sum, value) => sum + value,
        );

        if ((total - amount).abs() > 0.01) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Installment amounts must equal the total course fee.',
              ),
            ),
          );
          return;
        }
      }
    }

    final plan = PaymentPlanModel(
      id: _original?.id ?? 0,
      instituteId: widget.instituteId,
      name: _name.text.trim(),
      type: _type,
      amount: amount,
      period: _type == 'time_based'
          ? (_period == 'Custom' ? _customPeriod.text.trim() : _period)
          : null,
      paymentDue: _type == 'time_based' ? _paymentDue : null,
      dueDate: _dueDate,
      sessionCount: _type == 'attendance_based'
          ? int.tryParse(_sessions.text)
          : null,
      creditExpiry: _creditExpiry,
      installmentCount: count,
      installmentAmounts: installmentAmounts,
      description: _description.text.trim(),
      reason: _reason.text.trim(),
      discounts: List.of(_discounts),
      teacherPercentage: teacher,
      institutePercentage: institute,
      classCount: _original?.classCount ?? 0,
    );

    setState(() => _isSaving = true);

    try {
      await context.read<PaymentPlanProvider>().savePlan(plan);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Demo payment plan saved.')));
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to save: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    if (_original == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete payment plan?'),
        content: const Text(
          'Plans already assigned to classes cannot be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<PaymentPlanProvider>().deletePlan(
        widget.instituteId,
        _original!.id,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _amount,
      _description,
      _reason,
      _sessions,
      _installments,
      _customPeriod,
      _teacherShare,
      _instituteShare,
      ..._installmentAmountControllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        title: Text(
          _isNew ? 'New payment plan' : (_original?.name ?? 'Payment plan'),
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_isNew && _original != null)
            IconButton(
              tooltip: 'Delete payment plan',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (!_isNew && _original == null)
          ? const Center(child: Text('Payment plan not found'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 35),
                children: [
                  _field('Plan name', _name, requiredField: true),
                  const SizedBox(height: 12),

                  _dropdown(
                    'Plan type',
                    _type,
                    _types.keys.toList(),
                    (value) => setState(() => _type = value!),
                    enabled: !_typeLocked,
                  ),

                  if (_typeLocked)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 0, 12),
                      child: Text(
                        'In use by ${_original!.classCount} classes '
                        '— the type cannot change',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.authIcon,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),
                  _typeFields(),
                  const SizedBox(height: 15),

                  _field('Description (optional)', _description, lines: 2),

                  const SizedBox(height: 18),
                  _discountSection(),

                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 14),
                  _contributionSection(),

                  const SizedBox(height: 26),
                  PrimaryButton(
                    text: 'Save payment plan',
                    isLoading: _isSaving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
