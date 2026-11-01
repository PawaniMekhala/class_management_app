import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/institute_settings_provider.dart';
import '../../widgets/common/settings_detail_row.dart';
import 'edit_institute_profile_screen.dart';
import '../../core/services/location_service.dart';
import '../../models/district_model.dart';
import '../../models/city_model.dart';

class InstituteProfileTab extends StatefulWidget {
  const InstituteProfileTab({super.key});

  @override
  State<InstituteProfileTab> createState() => _InstituteProfileTabState();
}

class _InstituteProfileTabState extends State<InstituteProfileTab> {
  final LocationService _locationService = LocationService();

  String? _districtName;
  String? _cityName;

  String? _loadedDistrictId;
  String? _loadedCityId;

  bool _isLoadingLocation = false;
  String? _locationError;

  int _locationRequestId = 0;

  Future<void> _loadLocationNames(String districtId, String cityId) async {
    final requestId = ++_locationRequestId;

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
      _districtName = null;
      _cityName = null;
    });

    try {
      final List<DistrictModel> districts = await _locationService
          .getDistricts();

      if (!mounted || requestId != _locationRequestId) return;

      String? districtName;

      for (final district in districts) {
        if (district.id == districtId) {
          districtName = district.name;
          break;
        }
      }

      String? cityName;

      if (districtId.isNotEmpty) {
        final List<CityModel> cities = await _locationService.getCities(
          districtId,
        );

        if (!mounted || requestId != _locationRequestId) return;

        for (final city in cities) {
          if (city.id == cityId) {
            cityName = city.name;
            break;
          }
        }
      }

      if (!mounted || requestId != _locationRequestId) return;

      setState(() {
        _districtName = districtName;
        _cityName = cityName;
        _isLoadingLocation = false;
      });
    } catch (error) {
      if (!mounted || requestId != _locationRequestId) return;

      setState(() {
        _locationError = 'Unable to load location names';
        _isLoadingLocation = false;
      });
    }
  }

  @override
  void dispose() {
    _locationRequestId++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InstituteSettingsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.institute == null) {
          return Center(
            child: Text(provider.errorMessage ?? 'Institute not found.'),
          );
        }

        final institute = provider.institute!;

        if (_loadedDistrictId != institute.districtId ||
            _loadedCityId != institute.cityId) {
          _loadedDistrictId = institute.districtId;
          _loadedCityId = institute.cityId;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            _loadLocationNames(institute.districtId, institute.cityId);
          });
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                institute.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.authHeading,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Code: ${institute.code}',
                style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
              ),
              const SizedBox(height: 14),

              SettingsDetailRow(
                icon: Icons.business_outlined,
                label: 'Organization',
                value: institute.organization,
              ),
              SettingsDetailRow(
                icon: Icons.mail_outline,
                label: 'Email',
                value: institute.email,
              ),
              SettingsDetailRow(
                icon: Icons.phone_outlined,
                label: 'Contact',
                value: institute.contact,
              ),
              SettingsDetailRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: institute.address,
              ),
              SettingsDetailRow(
                icon: Icons.markunread_mailbox_outlined,
                label: 'Postal code',
                value: institute.postalCode,
              ),
              SettingsDetailRow(
                icon: Icons.event_outlined,
                label: 'Established Date',
                value: institute.establishedDate != null
                    ? DateFormat('d MMMM yyyy')
                          .format(institute.establishedDate!)
                    : 'Not available',
              ),
              SettingsDetailRow(
                icon: Icons.map_outlined,
                label: 'District',
                value: _isLoadingLocation
                    ? 'Loading...'
                    : _districtName ?? 'Not available',
              ),
              SettingsDetailRow(
                icon: Icons.location_city_outlined,
                label: 'City',
                value: _isLoadingLocation
                    ? 'Loading...'
                    : _cityName ?? 'Not available',
              ),
              if (_locationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _locationError!,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 38,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChangeNotifierProvider<
                              InstituteSettingsProvider
                            >.value(
                              value: provider,
                              child: EditInstituteProfileScreen(
                                institute: institute,
                              ),
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text(
                    'Edit profile',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.profileDivider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
