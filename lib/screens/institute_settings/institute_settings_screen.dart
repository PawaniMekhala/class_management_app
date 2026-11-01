import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/institute_settings_provider.dart';
import '../../providers/selected_institute_provider.dart';
import 'institute_profile_tab.dart';
import '../../providers/institute_branch_provider.dart';
import 'institute_branches_tab.dart';
import '../../providers/profile_provider.dart';
import '../auth/register_institute_screen.dart';

class InstituteSettingsScreen extends StatelessWidget {
  const InstituteSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InstituteSettingsProvider()),
        ChangeNotifierProvider(create: (_) => InstituteBranchProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..loadProfile()),
      ],
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

  Future<bool?> _openRegisterInstitute() async {
    final profileProvider = context.read<ProfileProvider>();

    if (profileProvider.profile == null) {
      await profileProvider.loadProfile();
    }

    if (!mounted) return false;

    final profile = profileProvider.profile;

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load admin details.')),
      );
      return false;
    }

    debugPrint('========== ADD BRANCH DEBUG ==========');
    debugPrint('Profile name: ${profile.name}');
    debugPrint('Profile role: ${profile.role}');
    debugPrint('Profile email: ${profile.email}');
    debugPrint('======================================');

    // TO DO: Replace this check with backend role/permission
    // validation when authentication is integrated.
    final normalizedRole = profile.role.trim().toLowerCase().replaceAll(
      RegExp(r'[\s_-]'),
      '',
    );

    final isAdmin =
        normalizedRole == 'admin' ||
        normalizedRole == 'instituteadmin' ||
        normalizedRole == 'instituteowner';

    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can add branches.')),
      );
      return false;
    }

    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterInstituteScreen(
          isAddingBranch: true,
          ownerName: profile.name,
          ownerEmail: profile.email,
          ownerMobile: profile.mobile,
          ownerNic: null,
        ),
      ),
    );
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
        body: TabBarView(
          children: [
            const InstituteProfileTab(),
            InstituteBranchesTab(onAddBranch: _openRegisterInstitute),
            const Center(child: Text('Rules — coming next')),
          ],
        ),
      ),
    );
  }
}
