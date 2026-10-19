import 'package:flutter/material.dart';

import '../../core/services/teacher_registration_service.dart';
import '../common/find_existing_person_screen.dart';

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

      onRegisterNew: (context) {
        // TODO: Navigate to RegisterTeacherFormScreen
        // after we build it from your next screenshot.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Register Teacher form will be added next.'),
          ),
        );
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
