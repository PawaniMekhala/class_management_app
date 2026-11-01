import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/institute_settings_provider.dart';
import '../../providers/selected_institute_provider.dart';
import 'institute_profile_tab.dart';

class InstituteSettingsScreen extends StatelessWidget {
  const InstituteSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InstituteSettingsProvider(),
      child: const _InstituteSettingsView(),
    );
  }
}

class _InstituteSettingsView extends StatefulWidget {
  const _InstituteSettingsView();

  @override
  State<_InstituteSettingsView> createState() => _InstituteSettingsViewState();
}

class _InstituteSettingsViewState extends State<_InstituteSettingsView> {
  int? _loadedInstituteId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final instituteId = context
        .watch<SelectedInstituteProvider>()
        .selectedInstituteId;

    if (_loadedInstituteId == instituteId) return;

    _loadedInstituteId = instituteId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<InstituteSettingsProvider>().loadInstitute(instituteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.profileBackground,
        appBar: AppBar(
          title: const Text(
            'Institute settings',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.profileBackground,
          foregroundColor: AppColors.authHeading,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.authIcon,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Branches'),
              Tab(text: 'Rules'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            InstituteProfileTab(),
            Center(child: Text('Branches — coming next')),
            Center(child: Text('Rules — coming next')),
          ],
        ),
      ),
    );
  }
}
