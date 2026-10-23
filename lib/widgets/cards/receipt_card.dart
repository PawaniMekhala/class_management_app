import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/payment_model.dart';

class ReceiptCard extends StatelessWidget {
  final StudentPayment payment;
  final String studentName;
  final VoidCallback onTap;

  const ReceiptCard({
    super.key,
    required this.payment,
    required this.studentName,
    required this.onTap,
  });

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2);
  }

  String _formatDate(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day}/${date.month}/${date.year}, '
        '$hour:$minute $period';
  }

  String _methodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'bank_transfer':
        return 'Bank transfer';
      case 'online':
        return 'Online';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.moduleIconBackground,
                child: const Icon(
                  Icons.receipt_long_outlined,
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
                      '${payment.receiptNumber} · $studentName',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.authHeading,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${_formatDate(payment.paidAt)} · '
                      '${_methodLabel(payment.method)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.authIcon,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Text(
                'Rs. ${_formatAmount(payment.amount)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.authHeading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
