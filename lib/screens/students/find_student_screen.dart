// import 'package:flutter/material.dart';

// import '../../core/theme/app_colors.dart';
// import '../../core/services/student_registration_service.dart';
// import '../../widgets/common/qr_scan_button.dart';
// import '../common/find_existing_person_screen.dart';
// import 'register_student_form_screen.dart';

// // import '../../widgets/buttons/primary_button.dart';

// class FindStudentScreen extends StatefulWidget {
//   final int instituteId;

//   const FindStudentScreen({
//     super.key,
//     required this.instituteId
//     });

//   @override
//   State<FindStudentScreen> createState() => _FindStudentScreenState();
// }

// class _FindStudentScreenState extends State<FindStudentScreen> {
//   final _searchController = TextEditingController();
//   final _service = StudentRegistrationService();

//   bool _isSearching = false;
//   bool _hasSearched = false;
//   List<Map<String, dynamic>> _results = [];

//   Future<void> _search(String query) async {
//     final text = query.trim();

//     if (text.isEmpty) {
//       setState(() {
//         _hasSearched = false;
//         _results = [];
//       });
//       return;
//     }

//     setState(() => _isSearching = true);

//     try {
//       final results = await _service.searchExistingStudents(text);

//       if (!mounted) return;

//       setState(() {
//         _results = results;
//         _hasSearched = true;
//       });
//     } catch (_) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Unable to search students.')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isSearching = false);
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.profileBackground,
//       appBar: AppBar(
//         title: const Text(
//           'Register student',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: AppColors.profileBackground,
//         foregroundColor: AppColors.authHeading,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(16, 22, 16, 30),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'First check whether they are already on IMS '
//               '(e.g. at another institute).',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: AppColors.authHeading,
//                 height: 1.5,
//               ),
//             ),

//             const SizedBox(height: 12),

//             TextField(
//               controller: _searchController,
//               onSubmitted: _search,
//               textInputAction: TextInputAction.search,
//               cursorColor: AppColors.primary,
//               style: const TextStyle(
//                 color: AppColors.authHeading,
//                 fontSize: 12,
//               ),
//               decoration: InputDecoration(
//                 hintText: 'Student no., QR code, NIC or mobile',
//                 hintStyle: const TextStyle(
//                   fontSize: 11,
//                   color: AppColors.authIcon,
//                 ),
//                 prefixIcon: const Icon(
//                   Icons.search,
//                   color: AppColors.authIcon,
//                   size: 19,
//                 ),
//                 suffixIcon: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     QrScanButton(
//                       scannerTitle: 'Find existing student',
//                       onScanned: (code) {
//                         _searchController.text = code;
//                         _search(code);
//                       },
//                     ),
//                     IconButton(
//                       tooltip: 'Search',
//                       onPressed: () => _search(_searchController.text),
//                       icon: const Icon(
//                         Icons.arrow_forward,
//                         size: 19,
//                         color: AppColors.authIcon,
//                       ),
//                     ),
//                   ],
//                 ),
//                 filled: true,
//                 fillColor: AppColors.surface,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 13,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(11),
//                   borderSide: const BorderSide(color: AppColors.profileDivider),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(11),
//                   borderSide: const BorderSide(color: AppColors.profileDivider),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 25),

//             SizedBox(
//               height: 44,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => RegisterStudentFormScreen(
//                         instituteId: widget.instituteId,
//                       ),
//                     ),
//                   );
//                 },
//                 icon: const Icon(Icons.person_add_alt_1, size: 17),
//                 label: const Text(
//                   'Register new',
//                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: AppColors.surface,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(11),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 18),

//             if (_isSearching) const Center(child: CircularProgressIndicator()),

//             if (!_isSearching && _hasSearched && _results.isEmpty)
//               const Text(
//                 'Global student lookup is not connected yet. '
//                 'No result can be confirmed in demo mode.',
//                 style: TextStyle(fontSize: 11, color: AppColors.authIcon),
//               ),

//             if (!_isSearching)
//               ..._results.map(
//                 (student) => ListTile(
//                   title: Text(student['name']?.toString() ?? 'Student'),
//                   subtitle: Text(student['student_code']?.toString() ?? ''),
//                   onTap: () {
//                     // TODO: Open existing-student confirmation.
//                     // Admin can then register/link the student
//                     // to the currently selected institute.
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
        // TODO: Open Existing Student confirmation screen.
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
