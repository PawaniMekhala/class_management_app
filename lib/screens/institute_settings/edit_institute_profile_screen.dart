import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/institute_settings_model.dart';
import '../../providers/institute_settings_provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../core/services/location_service.dart';
import '../../models/district_model.dart';
import '../../models/city_model.dart';

class EditInstituteProfileScreen extends StatefulWidget {
  final InstituteSettingsModel institute;

  const EditInstituteProfileScreen({super.key, required this.institute});

  @override
  State<EditInstituteProfileScreen> createState() =>
      _EditInstituteProfileScreenState();
}

class _EditInstituteProfileScreenState
    extends State<EditInstituteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _organizationController;
  late final TextEditingController _emailController;
  late final TextEditingController _contactController;
  late final TextEditingController _addressController;
  late final TextEditingController _postalCodeController;

  DateTime? _establishedDate;

  final LocationService _locationService = LocationService();

  List<DistrictModel> _districts = [];
  List<CityModel> _cities = [];

  String? _selectedDistrictId;
  String? _selectedCityId;

  bool _isLoadingDistricts = false;
  bool _isLoadingCities = false;

  String? _locationError;

  @override
  void initState() {
    super.initState();

    final institute = widget.institute;

    _nameController = TextEditingController(text: institute.name);
    _organizationController = TextEditingController(
      text: institute.organization,
    );
    _emailController = TextEditingController(text: institute.email);
    _contactController = TextEditingController(text: institute.contact);
    _addressController = TextEditingController(text: institute.address);
    _postalCodeController = TextEditingController(
      text: widget.institute.postalCode,
    );
    _establishedDate = institute.establishedDate;

    _selectedDistrictId = widget.institute.districtId.isEmpty
        ? null
        : widget.institute.districtId;

    _selectedCityId = widget.institute.cityId.isEmpty
        ? null
        : widget.institute.cityId;

    _loadDistricts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadDistricts() async {
    setState(() {
      _isLoadingDistricts = true;
      _locationError = null;
    });

    try {
      final districts = await _locationService.getDistricts();

      if (!mounted) return;

      setState(() {
        _districts = districts;

        if (!_districts.any((district) => district.id == _selectedDistrictId)) {
          _selectedDistrictId = null;
          _selectedCityId = null;
        }
      });

      if (_selectedDistrictId != null) {
        await _loadCities(_selectedDistrictId!);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _locationError = 'Unable to load districts.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingDistricts = false);
      }
    }
  }

  Future<void> _loadCities(String districtId) async {
    setState(() {
      _isLoadingCities = true;
      _locationError = null;
    });

    try {
      final cities = await _locationService.getCities(districtId);

      if (!mounted || _selectedDistrictId != districtId) return;

      setState(() {
        _cities = cities;

        if (!_cities.any((city) => city.id == _selectedCityId)) {
          _selectedCityId = null;
        }
      });
    } catch (error) {
      if (!mounted || _selectedDistrictId != districtId) return;

      setState(() {
        _locationError = 'Unable to load cities.';
      });
    } finally {
      if (mounted && _selectedDistrictId == districtId) {
        setState(() => _isLoadingCities = false);
      }
    }
  }

  void _onDistrictChanged(String? districtId) {
    setState(() {
      _selectedDistrictId = districtId;
      _selectedCityId = null;
      _cities = [];
      _isLoadingCities = false;
      _locationError = null;
    });

    if (districtId != null) {
      _loadCities(districtId);
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool requiredField = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13, color: AppColors.authHeading),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (requiredField && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _establishedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selected != null && mounted) {
      setState(() => _establishedDate = selected);
    }
  }

  void _clearDate() {
    setState(() => _establishedDate = null);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Check location selection before using the IDs.
    if (_selectedDistrictId == null || _selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a district and city.')),
      );
      return;
    }

    final updated = widget.institute.copyWith(
      name: _nameController.text.trim(),
      organization: _organizationController.text.trim(),
      email: _emailController.text.trim(),
      contact: _contactController.text.trim(),
      address: _addressController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      establishedDate: _establishedDate,
      clearEstablishedDate: _establishedDate == null,
      districtId: _selectedDistrictId!,
      cityId: _selectedCityId!,
    );

    final success = await context
        .read<InstituteSettingsProvider>()
        .updateInstitute(updated);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update institute profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        title: const Text('Edit institute profile'),
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
      ),
      body: Consumer<InstituteSettingsProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _field(label: 'Institute name', controller: _nameController),
                _field(
                  label: 'Organization',
                  controller: _organizationController,
                ),
                _field(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                _field(
                  label: 'Contact',
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                ),
                _field(
                  label: 'Address',
                  controller: _addressController,
                  maxLines: 3,
                ),
                _field(
                  label: 'Postal code',
                  controller: _postalCodeController,
                  keyboardType: TextInputType.number,
                  requiredField: false,
                ),

                const SizedBox(height: 5),

                ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  leading: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primary,
                  ),

                  title: const Text(
                    'Established date',
                    style: TextStyle(fontSize: 12),
                  ),

                  subtitle: Text(
                    _establishedDate == null
                        ? 'Select established date'
                        : DateFormat('d MMM yyyy').format(_establishedDate!),
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.primary),
                    onPressed: _establishedDate == null ? null : _clearDate,
                  ),

                  onTap: _chooseDate,
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  key: ValueKey(
                    'district_${_selectedDistrictId}_${_districts.length}',
                  ),
                  initialValue:
                      _districts.any(
                        (district) => district.id == _selectedDistrictId,
                      )
                      ? _selectedDistrictId
                      : null,
                  decoration: InputDecoration(
                    labelText: 'District',
                    prefixIcon: const Icon(Icons.map_outlined),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: Text(
                    _isLoadingDistricts
                        ? 'Loading districts...'
                        : 'Select district',
                  ),
                  items: _districts.map((district) {
                    return DropdownMenuItem<String>(
                      value: district.id,
                      child: Text(district.name),
                    );
                  }).toList(),
                  onChanged: _isLoadingDistricts ? null : _onDistrictChanged,
                  validator: (value) =>
                      value == null ? 'Please select a district' : null,
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  key: ValueKey(
                    'city_${_selectedDistrictId}_${_selectedCityId}_${_cities.length}',
                  ),
                  initialValue:
                      _cities.any((city) => city.id == _selectedCityId)
                      ? _selectedCityId
                      : null,
                  decoration: InputDecoration(
                    labelText: 'City / Town',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: Text(
                    _isLoadingCities
                        ? 'Loading cities...'
                        : 'Select city / town',
                  ),
                  items: _cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city.id,
                      child: Text(city.name),
                    );
                  }).toList(),
                  onChanged: _selectedDistrictId == null || _isLoadingCities
                      ? null
                      : (value) {
                          setState(() => _selectedCityId = value);
                        },
                  validator: (value) =>
                      value == null ? 'Please select a city / town' : null,
                ),

                if (_locationError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _locationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 24),

                PrimaryButton(
                  text: 'Save changes',
                  icon: Icons.save_outlined,
                  isLoading: provider.isSaving,
                  onPressed:
                      provider.isSaving ||
                          _isLoadingDistricts ||
                          _isLoadingCities
                      ? null
                      : _save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
