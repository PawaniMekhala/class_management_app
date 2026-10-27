import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/hall_model.dart';
import '../../providers/hall_provider.dart';
import '../../providers/selected_institute_provider.dart';
import '../../widgets/cards/hall_list_tile.dart';
import '../../widgets/buttons/register_fab.dart';
import 'hall_form_screen.dart';

class HallsScreen extends StatefulWidget {
  const HallsScreen({super.key});

  @override
  State<HallsScreen> createState() => _HallsScreenState();
}

class _HallsScreenState extends State<HallsScreen> {
  final _searchController = TextEditingController();
  int? _loadedInstituteId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final instituteId = context
        .watch<SelectedInstituteProvider>()
        .selectedInstituteId;

    if (_loadedInstituteId != instituteId) {
      _loadedInstituteId = instituteId;
      _searchController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<HallProvider>().loadHalls(instituteId);
      });
    }
  }

  Future<void> _changeStatus(HallModel hall, String status) async {
    try {
      await context.read<HallProvider>().changeStatus(hall, status);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Hall status updated.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update status: $error')),
      );
    }
  }

  void _openAddHall() {
    final instituteId = context
        .read<SelectedInstituteProvider>()
        .selectedInstituteId;

    final hallProvider = context.read<HallProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<HallProvider>.value(
          value: hallProvider,
          child: HallFormScreen(instituteId: instituteId),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        elevation: 0,
        // automaticallyImplyLeading: false,
        title: const Text(
          'Halls',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
      ),
      body: Consumer<HallProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.searchHalls,
                  textInputAction: TextInputAction.search,
                  cursorColor: AppColors.primary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.authHeading,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search name, number, building',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.authIcon,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.authIcon,
                      size: 19,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.profileDivider,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.errorMessage != null
                    ? Center(child: Text(provider.errorMessage!))
                    : provider.halls.isEmpty
                    ? const Center(child: Text('No halls found'))
                    : RefreshIndicator(
                        onRefresh: () {
                          final instituteId = context
                              .read<SelectedInstituteProvider>()
                              .selectedInstituteId;

                          return provider.loadHalls(instituteId);
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: provider.halls.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: AppColors.profileDivider,
                          ),
                          itemBuilder: (context, index) {
                            final hall = provider.halls[index];

                            return HallListTile(
                              hall: hall,
                              isUpdating: provider.isUpdating(hall.id),
                              onStatusChanged: (status) {
                                _changeStatus(hall, status);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: RegisterFab(
        label: 'Add hall',
        onPressed: _openAddHall,
      ),
    );
  }
}
