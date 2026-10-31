class PermissionConstants {
  static const List<String> actions = [
    'View',
    'Create',
    'Edit',
    'Delete',
    'Approve',
  ];

  static const List<String> modules = [
    'Dashboard',
    'Institute',
    'Staff',
    'Roles & permissions',
    'Students',
    'Teachers',
    'Academic',
    'Halls',
    'Classes',
    'Enrollment',
    'Attendance',
    'Payments',
    'Tutes & materials',
    'Notices',
    'Reports',
    'Settings',
  ];

  static Map<String, Map<String, bool>> emptyPermissions() {
    return {
      for (final module in modules)
        module: {for (final action in actions) action: false},
    };
  }

  static Map<String, Map<String, bool>> copyPermissions(
    Map<String, Map<String, bool>> source,
  ) {
    return {
      for (final module in modules)
        module: {
          for (final action in actions)
            action: source[module]?[action] ?? false,
        },
    };
  }

  static Map<String, Map<String, bool>> createPermissions({
    required Map<String, List<String>> allowed,
  }) {
    final permissions = emptyPermissions();

    for (final entry in allowed.entries) {
      if (!permissions.containsKey(entry.key)) continue;

      for (final action in entry.value) {
        if (permissions[entry.key]!.containsKey(action)) {
          permissions[entry.key]![action] = true;
        }
      }
    }

    return permissions;
  }
}
