import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/payment_model.dart';
import '../../models/student_model.dart';

class ReceiptDetailsScreen extends StatelessWidget {
  final StudentPayment payment;
  final StudentModel? student;

  const ReceiptDetailsScreen({super.key, required this.payment, this.student});

  String _money(double amount) {
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

  Widget _detailRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: AppColors.authHeading,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: AppColors.authHeading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,

      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        title: Text(
          payment.receiptNumber,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),

            child: Column(
              children: [
                // Institute heading
                const Text(
                  'Payment Receipt',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authHeading,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Institute ID: ${payment.instituteId}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.authIcon,
                  ),
                ),

                const SizedBox(height: 18),
                const Divider(),

                _detailRow('Receipt', payment.receiptNumber),

                _detailRow('Date', _formatDate(payment.paidAt)),

                _detailRow(
                  'Student',
                  student?.name ?? 'Student #${payment.studentId}',
                ),

                if (student != null)
                  _detailRow('Student No.', student!.studentCode),

                const SizedBox(height: 12),
                const Divider(),

                // Payment allocations
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payment breakdown',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.authHeading,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                ...payment.allocations.map(
                  (allocation) => _detailRow(
                    'Charge #${allocation.chargeId}',
                    'Rs. ${_money(allocation.amount)}',
                  ),
                ),

                const Divider(),

                _detailRow(
                  'TOTAL',
                  'Rs. ${_money(payment.amount)}',
                  bold: true,
                ),

                const SizedBox(height: 8),

                _detailRow('Paid by', _methodLabel(payment.method)),

                // Payment reference number
                if (payment.referenceNumber != null &&
                    payment.referenceNumber!.isNotEmpty)
                  _detailRow('Reference', payment.referenceNumber!),

                const SizedBox(height: 12),

                const Text(
                  'Thank you for your payment.',
                  style: TextStyle(fontSize: 11, color: AppColors.authIcon),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
