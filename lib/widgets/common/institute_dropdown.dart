import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/institute_model.dart';

class InstituteDropdown extends StatelessWidget {
  final InstituteModel selectedInstitute;
  final List<InstituteModel> institutes;
  final ValueChanged<InstituteModel> onChanged;

  const InstituteDropdown({
    super.key,
    required this.selectedInstitute,
    required this.institutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.authFieldBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedInstitute.id,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.authIcon),
          items: institutes.map((institute) {
            return DropdownMenuItem<int>(
              value: institute.id,
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_outlined,
                    color: AppColors.authIcon,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      institute.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.authHeading,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (id) {
            if (id == null) return;

            final institute = institutes.firstWhere((item) => item.id == id);

            onChanged(institute);
          },
        ),
      ),
    );
  }
}
