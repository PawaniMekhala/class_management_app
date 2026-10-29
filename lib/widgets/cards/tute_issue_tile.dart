import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// One tute row on the Distribute tab.
///
///  - issued:     green tick + "Issued 4 Oct 2026 by ..." + re-issue button
///  - available:  blue icon + "available – tap to issue" (whole row is tappable)
class TuteIssueTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isIssued;

  /// Shows a spinner while the issue request is running.
  final bool isBusy;

  /// Called when an AVAILABLE tute is tapped.
  final VoidCallback? onIssue;

  /// Called when the re-issue icon of an ISSUED tute is tapped.
  final VoidCallback? onReissue;

  const TuteIssueTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isIssued,
    this.isBusy = false,
    this.onIssue,
    this.onReissue,
  });

  Widget _leading() {
    if (isBusy) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: Padding(
          padding: EdgeInsets.all(2),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (isIssued) {
      return const Icon(Icons.check_circle, color: Color(0xFF40B76A), size: 24);
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.moduleIconBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.upload_file, color: AppColors.primary, size: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Issued tutes are not tappable; they only have the re-issue button.
      onTap: isIssued || isBusy ? null : onIssue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _leading(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.authHeading,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.35,
                      color: AppColors.authIcon,
                    ),
                  ),
                ],
              ),
            ),
            if (isIssued)
              IconButton(
                tooltip: 'Reissue',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.replay,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: onReissue,
              ),
          ],
        ),
      ),
    );
  }
}
