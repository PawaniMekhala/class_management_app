import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/dashboard_provider.dart';
import '../dashboard/institute_dashboard_screen.dart';
import '../../providers/notification_provider.dart';
import '../../providers/selected_institute_provider.dart';

import '../../models/institute_model.dart';
import '../../widgets/cards/institute_card.dart';

class SelectInstituteScreen extends StatelessWidget {
  final String userName;

  const SelectInstituteScreen({super.key, required this.userName});

  // Temporary data until the backend is ready
  static const List<InstituteModel> institutes = [
    InstituteModel(
      id: 1,
      name: 'Sipsala Institute - Gampaha',
      role: 'Institute Admin',
      company: 'Sipsala Education (Pvt) Ltd',
    ),
    InstituteModel(
      id: 2,
      name: 'Sipsala Institute - Kandy',
      role: 'Institute Admin',
      company: 'Sipsala Education (Pvt) Ltd',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5FC),
        elevation: 0,
        automaticallyImplyLeading: false,

        title: const Text(
          'Select institute',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF293B78),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Color(0xFF293B78)),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logged-in user's name
              Text(
                'Hi $userName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF293B78),
                ),
              ),

              const SizedBox(height: 2),

              const Text(
                'Choose where to continue',
                style: TextStyle(fontSize: 12, color: Color(0xFF536184)),
              ),

              const SizedBox(height: 16),

              // Institute list
              Expanded(
                child: ListView.separated(
                  itemCount: institutes.length,

                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 8);
                  },

                  itemBuilder: (context, index) {
                    final institute = institutes[index];

                    return InstituteCard(
                      institute: institute,
                      onTap: () {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text('Selected ${institute.name}')),
                        // );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider(
                                  create: (_) => SelectedInstituteProvider(
                                    institutes: institutes,
                                    selectedInstitute: institute,
                                  ),
                                ),
                                ChangeNotifierProvider(
                                  create: (_) =>
                                      DashboardProvider()
                                        ..loadDashboard(institute.id),
                                ),
                                ChangeNotifierProvider(
                                  create: (_) =>
                                      NotificationProvider()
                                        ..loadNotifications(institute.id),
                                ),
                              ],
                              child: InstituteDashboardScreen(
                                institute: institute,
                                userName: userName,
                                // builder: (context) => ChangeNotifierProvider(
                                //   create: (_) =>
                                //       DashboardProvider()
                                //         ..loadDashboard(institute.id),
                                //   child: InstituteDashboardScreen(
                                //     institute: institute,
                                //     userName: userName,
                              ),
                            ),
                          ),
                        );

                        // Next:
                        // Save selected institute ID
                        // Navigate to Institute Dashboard
                      },
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
