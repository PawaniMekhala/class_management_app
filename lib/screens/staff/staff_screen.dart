import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/staff_provider.dart';
import '../../providers/selected_institute_provider.dart';
import '../../models/staff_model.dart';
import '../../widgets/cards/staff_card.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final instituteId = context
          .read<SelectedInstituteProvider>()
          .selectedInstituteId;

      context.read<StaffProvider>().loadStaff(instituteId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature will be implemented next.')),
    );
  }

  void _handleStaffAction(String action, StaffModel staff) {
    switch (action) {
      case 'view':
        _showComingSoon('View staff details');
        break;

      case 'edit':
        _showComingSoon('Edit staff');
        break;

      case 'status':
        _showComingSoon('Manage staff status');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,

      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        elevation: 0,
        title: const Text(
          'Staff',
          style: TextStyle(
            color: AppColors.authHeading,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<StaffProvider>().searchStaff(value);
              },
              decoration: InputDecoration(
                hintText: 'Search name, username, mobile',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.authIcon,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.authIcon,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<StaffProvider>().clearSearch();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Staff list
          Expanded(
            child: Consumer<StaffProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(child: Text(provider.errorMessage!));
                }

                final staffList = provider.staff;

                if (staffList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No staff members found.',
                      style: TextStyle(color: AppColors.authIcon),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: staffList.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final staff = staffList[index];

                    return StaffCard(
                      staff: staff,
                      onTap: () {
                        _showComingSoon('Staff details');
                      },
                      onActionSelected: (action) {
                        _handleStaffAction(action, staff);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Register staff button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          _showComingSoon('Register staff');
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Register staff',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
