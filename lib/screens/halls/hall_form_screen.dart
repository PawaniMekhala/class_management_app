import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/hall_model.dart';
import '../../providers/hall_provider.dart';
import '../../widgets/buttons/primary_button.dart';

class HallFormScreen extends StatefulWidget {
  final int instituteId;

  const HallFormScreen({super.key, required this.instituteId});

  @override
  State<HallFormScreen> createState() => _HallFormScreenState();
}

class _HallFormScreenState extends State<HallFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();

  String _status = 'active';
  bool _isSaving = false;

  final List<String> _availableFacilities = [
    'Whiteboard',
    'Black board',
    'Projector',
    'Audio system',
    'Air conditioner',
    'Computers',
    'Internet',
    'Smart board',
    'Accessibility',
  ];

  final Set<String> _selectedFacilities = {};

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.authIcon),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.profileDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint, {
    bool numeric = false,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.primary,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13, color: AppColors.authHeading),
      decoration: _decoration(hint),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $hint';
        }

        if (numeric) {
          final number = int.tryParse(value.trim());
          if (number == null || number <= 0) {
            return 'Enter a valid seating capacity';
          }
        }

        return null;
      },
    );
  }

  Future<void> _addCustomFacility() async {
    final controller = TextEditingController();

    final facility = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add facility'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Facility name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (facility == null || facility.isEmpty || !mounted) return;

    setState(() {
      if (!_availableFacilities.any(
        (item) => item.toLowerCase() == facility.toLowerCase(),
      )) {
        _availableFacilities.add(facility);
      }
      _selectedFacilities.add(facility);
    });
  }

  Future<void> _saveHall() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final hall = HallModel(
      id: 0,
      instituteId: widget.instituteId,
      name: _nameController.text.trim(),
      number: _numberController.text.trim(),
      capacity: int.parse(_capacityController.text.trim()),
      building: _buildingController.text.trim(),
      floor: _floorController.text.trim(),
      status: _status,
      facilities: _selectedFacilities.toList(),
    );

    setState(() => _isSaving = true);

    try {
      await context.read<HallProvider>().addHall(hall);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hall saved successfully (demo).')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to save hall: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _capacityController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
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
        title: const Text(
          'New hall',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
          children: [
            _input(_nameController, 'Hall name'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _input(_numberController, 'Hall number')),
                const SizedBox(width: 10),
                Expanded(
                  child: _input(
                    _capacityController,
                    'Seating capacity',
                    numeric: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _input(_buildingController, 'Building')),
                const SizedBox(width: 10),
                Expanded(child: _input(_floorController, 'Floor')),
              ],
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: _decoration('Status'),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(
                  value: 'under_maintenance',
                  child: Text('Under maintenance'),
                ),
                DropdownMenuItem(value: 'closed', child: Text('Closed')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Facilities',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.authHeading,
              ),
            ),

            const SizedBox(height: 9),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final facility in _availableFacilities)
                  FilterChip(
                    label: Text(facility, style: const TextStyle(fontSize: 11)),
                    selected: _selectedFacilities.contains(facility),
                    selectedColor: AppColors.moduleIconBackground,
                    checkmarkColor: AppColors.primary,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFacilities.add(facility);
                        } else {
                          _selectedFacilities.remove(facility);
                        }
                      });
                    },
                  ),
                ActionChip(
                  avatar: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: const Text('Other', style: TextStyle(fontSize: 11)),
                  onPressed: _addCustomFacility,
                ),
              ],
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Save hall',
              isLoading: _isSaving,
              onPressed: _saveHall,
            ),
          ],
        ),
      ),
    );
  }
}
