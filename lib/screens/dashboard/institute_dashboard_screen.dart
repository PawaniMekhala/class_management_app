import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/institute_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/cards/notice_card.dart';
import '../../widgets/common/dashboard_section.dart';

class InstituteDashboardScreen extends StatelessWidget {
  final InstituteModel institute;
  final String userName;

  const InstituteDashboardScreen({
    super.key,
    required this.institute,
    required this.userName,
  });

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final today = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FC),

      // Fixed top bar
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5FC),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Text(
          institute.name,
          style: const TextStyle(
            color: Color(0xFF293B78),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  // Notifications screen will be added later.
                },
                icon: const Icon(
                  Icons.notifications_none,
                  color: Color(0xFF293B78),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Scrollable dashboard
      body: dashboard.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboard.errorMessage != null
          ? Center(child: Text(dashboard.errorMessage!))
          : RefreshIndicator(
              onRefresh: () => dashboard.loadDashboard(institute.id),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  // Greeting
                  Text(
                    '${getGreeting()}, $userName',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF293B78),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${institute.role} · $today',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF75809C),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Approval notices
                  ...dashboard.notices.map(
                    (notice) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: NoticeCard(
                        key: ValueKey(notice.id),
                        notice: notice,
                        onTap: () {
                          // Navigate to approval screens later.
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Totals
                  DashboardSection(
                    title: 'Totals',
                    stats: dashboard.stats['Totals'] ?? [],
                  ),

                  const SizedBox(height: 24),

                  // Today
                  DashboardSection(
                    title: 'Today',
                    stats: dashboard.stats['Today'] ?? [],
                  ),

                  const SizedBox(height: 24),

                  // Attendance
                  DashboardSection(
                    title: 'Attendance',
                    stats: dashboard.stats['Attendance'] ?? [],
                  ),

                  const SizedBox(height: 24),

                  // Money
                  DashboardSection(
                    title: 'Money',
                    stats: dashboard.stats['Money'] ?? [],
                  ),

                  const SizedBox(height: 20),

                  // Tutes
                  DashboardSection(
                    title: 'Tutes',
                    stats: dashboard.stats['Tutes'] ?? [],
                  ),
                ],
              ),
            ),

      // Fixed bottom navigation
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: 0,
        indicatorColor: const Color(0xFFE6EBFF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            label: 'Modules',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: (index) {
          //connect these tabs when their screens are ready.
        },
      ),
    );
  }
}
