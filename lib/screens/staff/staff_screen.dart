import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/staff_provider.dart';
import '../../providers/selected_institute_provider.dart';
import '../../models/staff_model.dart';
import '../../widgets/cards/staff_card.dart';
import 'staff_form_screen.dart';
import '../../widgets/buttons/register_fab.dart';

import 'roles_permissions_tab.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedTab = 0;

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
        _openStaffForm(staff: staff);
        break;

      case 'edit':
        _openStaffForm(staff: staff);
        break;

      case 'status':
        _showComingSoon('Manage staff status');
        break;
    }
  }

  Future<void> _openStaffForm({StaffModel? staff}) async {
    final staffProvider = context.read<StaffProvider>();

    final instituteProvider = context.read<SelectedInstituteProvider>();

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<StaffProvider>.value(value: staffProvider),
            ChangeNotifierProvider<SelectedInstituteProvider>.value(
              value: instituteProvider,
            ),
          ],
          child: StaffFormScreen(staff: staff),
        ),
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      // Clear the search so the updated/new staff is visible.
      _searchController.clear();
      staffProvider.clearSearch();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            staff == null
                ? 'Staff registered successfully.'
                : 'Staff updated successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildStaffTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              context.read<StaffProvider>().searchStaff(value);
              setState(() {});
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
                      _openStaffForm(staff: staff);
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
    );
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
          // Staff and Roles & Permissions tabs.
          Container(
            color: AppColors.authBackground,
            child: Row(
              children: [
                _buildTab('Staff', 0),
                _buildTab('Roles & Permissions', 1),
              ],
            ),
          ),

          Expanded(
            child: _selectedTab == 0
                ? _buildStaffTab()
                : const RolesPermissionsTab(),
          ),
        ],
      ),

      // Register button only appears on Staff tab.
      floatingActionButton: _selectedTab == 0
          ? RegisterFab(
              label: 'Register staff',
              onPressed: () {
                _openStaffForm();
              },
            )
          : null,
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.authIcon,
            ),
          ),
        ),
      ),
    );
  }
}
