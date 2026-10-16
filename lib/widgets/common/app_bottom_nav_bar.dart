import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 70,
      backgroundColor: AppColors.surface,
      elevation: 0,

      // Controls which tab is selected.
      selectedIndex: selectedIndex,

      // Light blue background behind selected icon.
      indicatorColor: AppColors.moduleIconBackground,

      // Selected and unselected icon colors.
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

      onDestinationSelected: onTabSelected,

      destinations: [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined, color: AppColors.textSecondary),
          selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
          label: 'Dashboard',
        ),

        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined, color: AppColors.textSecondary),
          selectedIcon: Icon(
            Icons.grid_view,
            // color: Color(0xFF3D5AFE)
            color: AppColors.primary,
          ),
          label: 'Modules',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: AppColors.textSecondary),
          selectedIcon: Icon(Icons.person, color: AppColors.primary),
          label: 'Profile',
        ),
      ],
    );
  }
}
