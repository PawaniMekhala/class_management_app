import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/permission_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/staff_role_model.dart';
import '../../providers/staff_role_provider.dart';
import '../../providers/staff_provider.dart';

class RoleEditorScreen extends StatefulWidget {
  final StaffRoleModel role;

  const RoleEditorScreen({super.key, required this.role});

  @override
  State<RoleEditorScreen> createState() => _RoleEditorScreenState();
}

class _RoleEditorScreenState extends State<RoleEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late Map<String, Map<String, bool>> _permissions;

  bool _hasChanges = false;

  // prevents editing all system roles.
  // bool get _isEditable => !widget.role.isSystemRole;
  // Owner and Institute Admin have full permissions.
  // Other roles can have their permissions customized.
  bool get _isEditable => !widget.role.isProtected;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.role.name);

    _descriptionController = TextEditingController(
      text: widget.role.description,
    );

    _permissions = PermissionConstants.copyPermissions(widget.role.permissions);

    _nameController.addListener(_checkChanges);
    _descriptionController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    if (!_isEditable) return;

    final nameChanged = _nameController.text.trim() != widget.role.name;

    final descriptionChanged =
        _descriptionController.text.trim() != widget.role.description;

    bool permissionsChanged = false;

    for (final module in PermissionConstants.modules) {
      for (final action in PermissionConstants.actions) {
        if (_permissions[module]?[action] !=
            (widget.role.permissions[module]?[action] ?? false)) {
          permissionsChanged = true;
          break;
        }
      }

      if (permissionsChanged) break;
    }

    if (mounted) {
      setState(() {
        _hasChanges = nameChanged || descriptionChanged || permissionsChanged;
      });
    }
  }

  void _togglePermission(String module, String action, bool value) {
    if (!_isEditable) return;

    setState(() {
      _permissions[module]![action] = value;
    });

    _checkChanges();
  }

  Future<void> _saveRole() async {
    if (!_isEditable) return;

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<StaffRoleProvider>();

    if (provider.isSaving) return;

    final updatedRole = widget.role.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      permissions: PermissionConstants.copyPermissions(_permissions),
    );

    final success = await provider.updateRole(updatedRole);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Unable to save role.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasChanges) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved permission changes. '
            'Are you sure you want to leave?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Continue editing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );

    return discard ?? false;
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
            ),
          ),

          TextFormField(
            controller: controller,
            readOnly: !_isEditable,
            style: const TextStyle(fontSize: 12, color: AppColors.authHeading),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            validator: isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Role name is required';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTable() {
    const moduleWidth = 130.0;
    const actionWidth = 64.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 45,
        dataRowMinHeight: 42,
        dataRowMaxHeight: 42,
        horizontalMargin: 8,
        columnSpacing: 0,
        headingTextStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.authHeading,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 11,
          color: AppColors.authHeading,
        ),
        columns: [
          DataColumn(
            label: SizedBox(width: moduleWidth, child: const Text('Module')),
          ),

          ...PermissionConstants.actions.map(
            (action) => DataColumn(
              label: SizedBox(
                width: actionWidth,
                child: Text(action, textAlign: TextAlign.center),
              ),
            ),
          ),
        ],
        rows: PermissionConstants.modules.map((module) {
          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: moduleWidth,
                  child: Text(
                    module,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              ...PermissionConstants.actions.map((action) {
                final checked = _permissions[module]?[action] ?? false;

                return DataCell(
                  SizedBox(
                    width: actionWidth,
                    child: Center(
                      child: Checkbox(
                        value: checked,
                        activeColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.authIcon,
                          width: 1.4,
                        ),
                        onChanged: _isEditable
                            ? (value) {
                                _togglePermission(
                                  module,
                                  action,
                                  value ?? false,
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _deleteRole() async {
    if (widget.role.isProtected) return;

    final staffProvider = context.read<StaffProvider>();
    final roleProvider = context.read<StaffRoleProvider>();

    final assignedStaff = staffProvider.allStaff.where((staff) {
      return staff.instituteId == widget.role.instituteId &&
          staff.role.trim().toLowerCase() ==
              widget.role.name.trim().toLowerCase();
    }).toList();

    if (assignedStaff.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete ${widget.role.name}. '
            '${assignedStaff.length} staff member(s) are assigned '
            'to this role. Reassign them first.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete role?'),
          content: Text(
            'Are you sure you want to delete '
            '"${widget.role.name}"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    final success = await roleProvider.deleteRole(
      instituteId: widget.role.instituteId,
      roleId: widget.role.id,
      hasAssignedStaff: assignedStaff.isNotEmpty,
    );

    if (!mounted) return;

    if (success) {
      // The role was deleted successfully.
      // Clear unsaved-change tracking before leaving.
      setState(() {
        _hasChanges = false;
      });

      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(roleProvider.errorMessage ?? 'Unable to delete role.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldDiscard = await _confirmDiscardChanges();

        if (!shouldDiscard || !mounted) return;

        setState(() {
          _hasChanges = false;
        });

        Navigator.of(this.context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.authBackground,

        appBar: AppBar(
          backgroundColor: AppColors.authBackground,
          foregroundColor: AppColors.authHeading,
          elevation: 0,
          title: Text(
            widget.role.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          actions: [
            if (_isEditable)
              Consumer<StaffRoleProvider>(
                builder: (context, provider, child) {
                  return IconButton(
                    tooltip: 'Delete role',
                    onPressed: provider.isSaving ? null : _deleteRole,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  );
                },
              ),
          ],
        ),

        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'Role name',
                        controller: _nameController,
                        isRequired: true,
                      ),

                      _buildTextField(
                        label: 'Description (optional)',
                        controller: _descriptionController,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Permissions',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.authHeading,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (!_isEditable)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'This role has full access and its permissions cannot be modified.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.authIcon,
                            ),
                          ),
                        ),

                      _buildPermissionTable(),
                    ],
                  ),
                ),
              ),

              if (_isEditable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Consumer<StaffRoleProvider>(
                    builder: (context, provider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: provider.isSaving || !_hasChanges
                              ? null
                              : _saveRole,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: provider.isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
