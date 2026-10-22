import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/payment_plan_model.dart';
import '../../providers/payment_plan_provider.dart';
import 'payment_plan_details_screen.dart';

class PaymentPlansTab extends StatefulWidget {
  final int instituteId;

  const PaymentPlansTab({super.key, required this.instituteId});

  @override
  State<PaymentPlansTab> createState() => _PaymentPlansTabState();
}

class _PaymentPlansTabState extends State<PaymentPlansTab> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PaymentPlansTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.instituteId != widget.instituteId) {
      _searchController.clear();
      _load();
    }
  }

  void _load() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaymentPlanProvider>().loadPlans(widget.instituteId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _money(double value) {
    return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2);
  }

  String _subtitle(PaymentPlanModel plan) {
    String details;

    switch (plan.type) {
      case 'one_time':
        details = 'One-time · Rs. ${_money(plan.amount)} once';
        break;
      case 'time_based':
        details =
            'Time based · Rs. ${_money(plan.amount)} / '
            '${(plan.period ?? 'period').toLowerCase()}';
        break;
      case 'attendance_based':
        details =
            'Attendance based · Rs. ${_money(plan.amount)} '
            'for ${plan.sessionCount ?? 0} sessions';
        break;
      case 'installments':
        details =
            'Installments · Rs. ${_money(plan.amount)} '
            'in ${plan.installmentCount ?? 0} installments';
        break;
      case 'free_card':
        details =
            'Free card · Free'
            '${plan.reason == null ? '' : ' · ${plan.reason}'}';
        break;
      default:
        details = 'Other payment · Rs. ${_money(plan.amount)}';
    }

    if (plan.discounts.isNotEmpty) {
      details += ' · ${plan.discounts.length} discounts';
    }

    if (plan.classCount > 0) {
      details += ' · ${plan.classCount} classes';
    }

    return details;
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'one_time':
        return Icons.receipt_long_outlined;
      case 'time_based':
        return Icons.calendar_month_outlined;
      case 'attendance_based':
        return Icons.confirmation_number_outlined;
      case 'installments':
        return Icons.view_column_outlined;
      case 'free_card':
        return Icons.card_giftcard_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentPlanProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: provider.searchPlans,
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.authHeading,
                ),
                decoration: InputDecoration(
                  hintText: 'Search payment plans',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.authIcon,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.authIcon,
                    size: 19,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.profileDivider,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage != null
                  ? Center(child: Text(provider.errorMessage!))
                  : provider.plans.isEmpty
                  ? const Center(child: Text('No payment plans found'))
                  : RefreshIndicator(
                      onRefresh: () => provider.loadPlans(widget.instituteId),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: provider.plans.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          color: AppColors.profileDivider,
                        ),
                        itemBuilder: (context, index) {
                          final plan = provider.plans[index];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.moduleIconBackground,
                              child: Icon(
                                _iconFor(plan.type),
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.authHeading,
                              ),
                            ),
                            subtitle: Text(
                              _subtitle(plan),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.authIcon,
                              ),
                            ),
                            // onTap: () {
                            //   final paymentProvider = context
                            //       .read<PaymentPlanProvider>();

                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (_) => ChangeNotifierProvider.value(
                            //         value: paymentProvider,
                            //         child: PaymentPlanDetailsScreen(
                            //           instituteId: widget.instituteId,
                            //           planId: plan.id,
                            //         ),
                            //       ),
                            //     ),
                            //   );
                            // },
                            onTap: () async {
                              final paymentProvider = context
                                  .read<PaymentPlanProvider>();

                              final changed = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider.value(
                                    value: paymentProvider,
                                    child: PaymentPlanDetailsScreen(
                                      instituteId: widget.instituteId,
                                      planId: plan.id,
                                    ),
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              if (changed == true) {
                                await paymentProvider.loadPlans(
                                  widget.instituteId,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
