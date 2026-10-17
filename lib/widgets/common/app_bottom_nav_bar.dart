// import 'package:flutter/material.dart';

// import '../../core/theme/app_colors.dart';

// class AppBottomNavBar extends StatelessWidget {
//   final int selectedIndex;
//   final ValueChanged<int> onTabSelected;

//   const AppBottomNavBar({
//     super.key,
//     required this.selectedIndex,
//     required this.onTabSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return NavigationBar(
//       height: 70,
//       backgroundColor: AppColors.surface,
//       elevation: 0,

//       // Controls which tab is selected.
//       selectedIndex: selectedIndex,

//       // Light blue background behind selected icon.
//       indicatorColor: AppColors.moduleIconBackground,

//       // Selected and unselected icon colors.
//       labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

//       onDestinationSelected: onTabSelected,

//       destinations: [
//         NavigationDestination(
//           icon: Icon(Icons.dashboard_outlined, color: AppColors.textSecondary),
//           selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
//           label: 'Dashboard',
//         ),

//         NavigationDestination(
//           icon: Icon(Icons.grid_view_outlined, color: AppColors.textSecondary),
//           selectedIcon: Icon(
//             Icons.grid_view,
//             // color: Color(0xFF3D5AFE)
//             color: AppColors.primary,
//           ),
//           label: 'Modules',
//         ),
//         NavigationDestination(
//           icon: Icon(Icons.person_outline, color: AppColors.textSecondary),
//           selectedIcon: Icon(Icons.person, color: AppColors.primary),
//           label: 'Profile',
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'profile_avatar.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  // Optional profile picture for the Profile tab
  final String? profilePhotoUrl;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.profilePhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(color: AppColors.surface),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard,
              label: 'Dashboard',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.grid_view_outlined,
              selectedIcon: Icons.grid_view,
              label: 'Modules',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Profile',

              // Show profile picture if available.
              // Otherwise show the default person icon.
              customIcon: profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty
                  ? ProfileAvatar(photoUrl: profilePhotoUrl, radius: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,

    // Optional custom widget, such as a profile photo
    Widget? customIcon,
  }) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Blue pill-shaped background for selected icon
            Container(
              width: 48,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  customIcon ??
                  Icon(
                    isSelected ? selectedIcon : icon,
                    color: isSelected ? AppColors.surface : AppColors.authIcon,
                    size: 20,
                  ),
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.authIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
