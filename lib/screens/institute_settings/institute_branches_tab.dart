import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/institute_branch_provider.dart';
import '../../providers/selected_institute_provider.dart';
import '../../models/institute_model.dart';
import '../../widgets/cards/institute_card.dart';

class InstituteBranchesTab extends StatefulWidget {
  final Future<bool?> Function() onAddBranch;

  const InstituteBranchesTab({super.key, required this.onAddBranch});

  @override
  State<InstituteBranchesTab> createState() => _InstituteBranchesTabState();
}

class _InstituteBranchesTabState extends State<InstituteBranchesTab> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InstituteBranchProvider>().loadBranches();
    });
  }

  Future<void> _addBranch() async {
    final success = await widget.onAddBranch();

    if (!mounted) return;

    if (success == true) {
      await context.read<InstituteBranchProvider>().loadBranches();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedInstituteId = context
        .watch<SelectedInstituteProvider>()
        .selectedInstituteId;

    return Consumer<InstituteBranchProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.errorMessage != null)
              Center(child: Text(provider.errorMessage!))
            else if (provider.branches.isEmpty)
              const Center(child: Text('No institutes found.'))
            else
              ListView.separated(
                padding: const EdgeInsets.only(top: 4, bottom: 95),
                itemCount: provider.branches.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.profileDivider),
                itemBuilder: (context, index) {
                  final branch = provider.branches[index];

                  return InstituteCard(
                    institute: InstituteModel(
                      id: branch.id,
                      name: branch.name,
                      company: '',
                      role: '',
                    ),
                    isBranch: true,
                    isCurrent: branch.id == selectedInstituteId,
                    subtitle:
                        '${branch.code} · ${branch.city}, ${branch.district}',
                  );
                },
              ),

            Positioned(
              right: 18,
              bottom: 18,
              child: FloatingActionButton.extended(
                heroTag: 'addInstituteBranch',
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_business_outlined, size: 19),
                label: const Text('Add branch', style: TextStyle(fontSize: 12)),
                onPressed: _addBranch,
              ),
            ),
          ],
        );
      },
    );
  }
}
