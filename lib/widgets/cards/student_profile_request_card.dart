import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/student_profile_request_model.dart';

class StudentProfileRequestCard extends StatelessWidget {
  final StudentProfileRequestModel request;
  final bool isProcessing;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const StudentProfileRequestCard({
    super.key,
    required this.request,
    this.isProcessing = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == ProfileRequestStatus.pending;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${request.studentName} (${request.studentCode})',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.authHeading,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            'Requested ${DateFormat('MMM d, yyyy, h:mm a').format(request.requestedAt)}',
            style: const TextStyle(fontSize: 10, color: AppColors.authIcon),
          ),

          const SizedBox(height: 12),

          ...request.changes.map(
            (change) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                '${change.fieldName}: '
                '${change.oldValue} → ${change.newValue}',
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: AppColors.authHeading,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (isPending)
            Row(
              children: [
                TextButton(
                  onPressed: isProcessing ? null : onReject,
                  child: const Text('Reject', style: TextStyle(fontSize: 11)),
                ),

                const Spacer(),

                if (isProcessing)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  TextButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text(
                      'Approve',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  request.status == ProfileRequestStatus.approved
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 16,
                  color: request.status == ProfileRequestStatus.approved
                      ? const Color(0xFF2E9D59)
                      : AppColors.authIcon,
                ),

                const SizedBox(width: 6),

                Text(
                  request.status == ProfileRequestStatus.approved
                      ? 'Approved'
                      : 'Rejected',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.authHeading,
                  ),
                ),

                if (request.reviewedAt != null) ...[
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, yyyy').format(request.reviewedAt!),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.authIcon,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
