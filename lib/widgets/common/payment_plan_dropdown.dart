import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/payment_plan_model.dart';

class PaymentPlanDropdown extends StatelessWidget {
  final List<PaymentPlanModel> plans;
  final PaymentPlanModel? selectedPlan;
  final ValueChanged<PaymentPlanModel?> onChanged;
  final bool enabled;

  const PaymentPlanDropdown({
    super.key,
    required this.plans,
    required this.selectedPlan,
    required this.onChanged,
    this.enabled = true,
  });

  String _getPlanLabel(PaymentPlanModel plan) {
    final amount = plan.amount.toStringAsFixed(0);

    switch (plan.type) {
      case 'time_based':
        return '${plan.name} · Rs. $amount / ${plan.period ?? 'period'}';

      case 'one_time':
        return '${plan.name} · Rs. $amount / one time';

      case 'attendance_based':
        return '${plan.name} · Rs. $amount / '
            '${plan.sessionCount ?? 0} sessions';

      case 'installments':
        return '${plan.name} · Rs. $amount / '
            '${plan.installmentCount ?? 0} installments';

      case 'free_card':
        return '${plan.name} · Free';

      default:
        return '${plan.name} · Rs. $amount';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      key: ValueKey(selectedPlan?.id),
      initialValue: selectedPlan?.id,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Payment plan',
        labelStyle: const TextStyle(color: AppColors.authIcon, fontSize: 12),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.profileDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.profileDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      items: plans.map((plan) {
        return DropdownMenuItem<int>(
          value: plan.id,
          child: Text(
            _getPlanLabel(plan),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.authHeading, fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: enabled
          ? (id) {
              if (id == null) {
                onChanged(null);
                return;
              }

              final selected = plans.firstWhere((plan) => plan.id == id);

              onChanged(selected);
            }
          : null,
    );
  }
}
