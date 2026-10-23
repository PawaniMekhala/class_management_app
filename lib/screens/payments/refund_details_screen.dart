import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/refund_model.dart';

class RefundDetailsScreen extends StatelessWidget {
  final RefundModel refund;

  const RefundDetailsScreen({super.key, required this.refund});

  String _money(double amount) {
    return amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2);
  }

  String _date(DateTime date) {
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
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
          refund.refundNumber,
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
                const Icon(
                  Icons.currency_exchange_outlined,
                  color: AppColors.primary,
                  size: 35,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Refund Details',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authHeading,
                  ),
                ),

                const SizedBox(height: 15),
                const Divider(),

                _detailRow('Refund number', refund.refundNumber),

                _detailRow('Original receipt', refund.receiptNumber),

                _detailRow('Student', refund.studentName),

                _detailRow('Student number', refund.studentCode),

                const Divider(),

                _detailRow('Refund amount', 'Rs. ${_money(refund.amount)}'),

                _detailRow('Reason', refund.reason),

                _detailRow('Refund method', _methodLabel(refund.method)),

                _detailRow('Status', refund.status.toUpperCase()),

                const Divider(),

                _detailRow('Requested at', _date(refund.requestedAt)),

                if (refund.processedAt != null)
                  _detailRow('Processed at', _date(refund.processedAt!)),

                if (refund.processedBy != null)
                  _detailRow('Processed by', refund.processedBy!),

                if (refund.referenceNumber != null)
                  _detailRow('Reference number', refund.referenceNumber!),

                if (refund.notes != null) ...[
                  const Divider(),
                  _detailRow('Notes', refund.notes!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
