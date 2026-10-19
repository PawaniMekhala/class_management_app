import 'package:flutter/material.dart';

import '../../core/services/teacher_registration_service.dart';
import '../common/find_existing_person_screen.dart';
import 'register_teacher_form_screen.dart';

class FindTeacherScreen extends StatelessWidget {
  final int instituteId;

  const FindTeacherScreen({super.key, required this.instituteId});

  @override
  Widget build(BuildContext context) {
    final service = TeacherRegistrationService();

    return FindExistingPersonScreen(
      title: 'Register teacher',
      searchHint: 'NIC, mobile, teacher number or name',

      // No QR scanner for teachers.
      enableQrScanner: false,

      onSearch: service.searchExistingTeachers,

      onRegisterNew: (context) async {
        final registered = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterTeacherFormScreen(instituteId: instituteId),
          ),
        );

        if (!context.mounted) return;

        if (registered == true) {
          // Return to Teachers list after the demo submission.
          Navigator.pop(context, true);
        }
      },

      onPersonSelected: (context, teacher) {
        // to do - Open existing-teacher confirmation screen
        // to register the teacher at this institute.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Existing teacher registration will be added later.'),
          ),
        );
      },
    );
  }
}
