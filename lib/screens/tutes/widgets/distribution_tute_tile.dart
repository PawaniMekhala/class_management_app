import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/tute_model.dart';

class DistributionTuteTile extends StatelessWidget {
  final TuteModel tute;
  final DateTime? receivedAt;
  final String? issuedByName;
  final bool isIssuing;
  final VoidCallback? onTap;
  final VoidCallback? onReissue;

  const DistributionTuteTile({
    super.key,
    required this.tute,
    required this.receivedAt,
    required this.isIssuing,
    required this.onTap,
    this.issuedByName,
    this.onReissue,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final received = receivedAt != null;

    final available =
        !received &&
        tute.status == TuteStatus.active &&
        !tute.releaseDate.isAfter(DateTime.now());

    String statusText;

    if (received) {
      statusText = 'Received: ${_formatDate(receivedAt!)}';
    } else if (tute.status == TuteStatus.archived) {
      statusText = 'Archived — unavailable';
    } else if (tute.releaseDate.isAfter(DateTime.now())) {
      statusText = 'Not yet released';
    } else {
      statusText = 'Available — tap to issue';
    }

    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              received ? Icons.check_circle : Icons.radio_button_unchecked,
              color: received
                  ? Colors.green
                  : available
                  ? AppColors.primary
                  : Colors.grey,
              size: 22,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: InkWell(
                onTap: isIssuing || !available ? null : onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tute.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authHeading,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.authIcon,
                      ),
                    ),

                    if (received) ...[
                      const SizedBox(height: 4),

                      Text(
                        'Issued by: '
                        '${issuedByName?.trim().isNotEmpty == true ? issuedByName : 'Not recorded'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.authIcon,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (isIssuing)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),

            if (received && onReissue != null)
              IconButton(
                tooltip: 'Reissue tute',
                onPressed: onReissue,
                icon: const Icon(Icons.refresh, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
