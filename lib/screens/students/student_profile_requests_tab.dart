import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/student_profile_request_model.dart';
import '../../providers/student_profile_request_provider.dart';
import '../../widgets/cards/student_profile_request_card.dart';

class StudentProfileRequestsTab extends StatefulWidget {
  const StudentProfileRequestsTab({super.key});

  @override
  State<StudentProfileRequestsTab> createState() =>
      _StudentProfileRequestsTabState();
}

class _StudentProfileRequestsTabState extends State<StudentProfileRequestsTab> {
  bool _showHistory = false;

  Future<void> _review(StudentProfileRequestModel request, bool approve) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(approve ? 'Approve request?' : 'Reject request?'),
        content: Text(
          approve
              ? 'Approve the requested changes for ${request.studentName}?'
              : 'Reject the requested changes for ${request.studentName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await context
        .read<StudentProfileRequestProvider>()
        .reviewRequest(requestId: request.id, approve: approve);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? approve
                    ? 'Demo request approved and moved to history.'
                    : 'Demo request rejected and moved to history.'
              : 'Unable to review request.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProfileRequestProvider>(
      builder: (context, provider, child) {
        final requests = _showHistory
            ? provider.historyRequests
            : provider.pendingRequests;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: TextField(
                onChanged: provider.search,
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  color: AppColors.authHeading,
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  hintText: 'Search student',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.authIcon,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 19,
                    color: AppColors.authIcon,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.profileDivider,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.profileDivider,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),

            // Pending and request history
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() => _showHistory = false);
                    },
                    child: Text(
                      'Pending (${provider.pendingRequests.length})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: !_showHistory
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: !_showHistory
                            ? AppColors.primary
                            : AppColors.authIcon,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _showHistory = true);
                    },
                    child: Text(
                      'Request history',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: _showHistory
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _showHistory
                            ? AppColors.primary
                            : AppColors.authIcon,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage != null
                  ? Center(child: Text(provider.errorMessage!))
                  : requests.isEmpty
                  ? Center(
                      child: Text(
                        _showHistory
                            ? 'No request history'
                            : 'No pending profile requests',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.authIcon,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        // Refresh is wired in StudentsScreen
                        // through the provider's selected institute.
                        await provider.refresh();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: requests.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final request = requests[index];

                          return StudentProfileRequestCard(
                            request: request,
                            isProcessing: provider.isProcessing(request.id),
                            onApprove: () => _review(request, true),
                            onReject: () => _review(request, false),
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
