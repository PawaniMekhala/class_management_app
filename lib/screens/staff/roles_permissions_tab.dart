import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/staff_role_model.dart';
import '../../providers/selected_institute_provider.dart';
import '../../providers/staff_provider.dart';
import '../../providers/staff_role_provider.dart';
import '../../widgets/cards/staff_role_card.dart';
import '../../widgets/buttons/register_fab.dart';

import 'new_role_screen.dart';

class RolesPermissionsTab extends StatefulWidget {
  const RolesPermissionsTab({super.key});

  @override
  State<RolesPermissionsTab> createState() => _RolesPermissionsTabState();
}

class _RolesPermissionsTabState extends State<RolesPermissionsTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final instituteId = context
          .read<SelectedInstituteProvider>()
          .selectedInstituteId;

      context.read<StaffRoleProvider>().loadRoles(instituteId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getStaffCount(StaffRoleModel role) {
    final staffProvider = context.read<StaffProvider>();

    // Count all staff, not just the currently searched results.
    return staffProvider.allStaff.where((member) {
      return member.instituteId == role.instituteId &&
          member.role.trim().toLowerCase() == role.name.trim().toLowerCase();
    }).length;
  }

  Future<void> _openNewRoleScreen() async {
    final roleProvider = context.read<StaffRoleProvider>();

    final instituteProvider = context.read<SelectedInstituteProvider>();

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<StaffRoleProvider>.value(
              value: roleProvider,
            ),
            ChangeNotifierProvider<SelectedInstituteProvider>.value(
              value: instituteProvider,
            ),
          ],
          child: const NewRoleScreen(),
        ),
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      _searchController.clear();
      roleProvider.clearSearch();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Role created successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _openRoleDetails(StaffRoleModel role) {
    // TO DO: Implement the Role Details & Permissions screen.
    // This screen will display the selected role's module
    // permissions and allow authorized changes.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${role.name} permissions screen will be implemented next.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search roles.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              context.read<StaffRoleProvider>().searchRoles(value);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search roles',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.authIcon,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.authIcon,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<StaffRoleProvider>().clearSearch();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Role list.
        Expanded(
          child: Consumer2<StaffRoleProvider, StaffProvider>(
            builder: (context, roleProvider, staffProvider, child) {
              if (roleProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (roleProvider.errorMessage != null) {
                return Center(child: Text(roleProvider.errorMessage!));
              }

              final roles = roleProvider.roles;

              if (roles.isEmpty) {
                return const Center(
                  child: Text(
                    'No roles found.',
                    style: TextStyle(color: AppColors.authIcon),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: roles.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final role = roles[index];

                  return StaffRoleCard(
                    role: role,
                    staffCount: _getStaffCount(role),
                    onTap: () => _openRoleDetails(role),
                  );
                },
              );
            },
          ),
        ),

        // New role button.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: RegisterFab(
              label: 'New role',
              onPressed: _openNewRoleScreen,
            ),
          ),
        ),
      ],
    );
  }
}
