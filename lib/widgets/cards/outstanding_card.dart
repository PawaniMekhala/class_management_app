import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/outstanding_model.dart';

class OutstandingCard extends StatelessWidget {
  final OutstandingModel outstanding;
  final VoidCallback? onTap;

  const OutstandingCard({super.key, required this.outstanding, this.onTap});

  String _money(double amount) {
    return amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2);
  }

  @override
  Widget build(BuildContext context) {
    final charge = outstanding.charge;
    final student = outstanding.student;

    return Material(
      color: AppColors.profileBackground,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authHeading,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${charge.className} — '
                      '${charge.description} · '
                      '${outstanding.isOverdue ? '${outstanding.daysOverdue} days overdue' : 'Not overdue'}'
                      '${student.mobile == null ? '' : ' · ${student.mobile}'}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.authIcon,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Rs. ${_money(outstanding.balance)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
