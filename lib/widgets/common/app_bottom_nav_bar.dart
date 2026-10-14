import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      elevation: 0,
      selectedIndex: selectedIndex,
      indicatorColor: const Color(0xFFE6EBFF),

      onDestinationSelected: onTabSelected,

      destinations: [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: Color(0xFF3D5AFE)),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(
            Icons.grid_view,
            // color: Color(0xFF3D5AFE)
            color: Theme.of(context).colorScheme.onSurface,
          ),
          label: 'Modules',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: Color(0xFF3D5AFE)),
          label: 'Profile',
        ),
      ],
    );
  }
}
