import 'package:flutter/material.dart';

import '../../core/services/student_registration_service.dart';
import '../common/find_existing_person_screen.dart';
import 'register_student_form_screen.dart';

class FindStudentScreen extends StatelessWidget {
  final int instituteId;

  const FindStudentScreen({super.key, required this.instituteId});

  @override
  Widget build(BuildContext context) {
    final service = StudentRegistrationService();

    return FindExistingPersonScreen(
      title: 'Register student',
      searchHint: 'Student no., QR code, NIC or mobile',
      enableQrScanner: true,

      onSearch: service.searchExistingStudents,

      onRegisterNew: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterStudentFormScreen(instituteId: instituteId),
          ),
        );
      },

      onPersonSelected: (context, student) {
        // TO DO: Open Existing Student confirmation screen.
        // Do not create a duplicate student account.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Existing student registration will be added later.'),
          ),
        );
      },
    );
  }
}
