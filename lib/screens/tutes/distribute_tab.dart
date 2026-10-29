// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../core/theme/app_colors.dart';
// import '../../core/utils/app_snackbar.dart';
// import '../../core/utils/formatters.dart';
// import '../../models/enrollment_model.dart';
// import '../../models/student_model.dart';
// import '../../models/tute_model.dart';
// import '../../providers/enrollment_provider.dart';
// import '../../providers/student_provider.dart';
// import '../../providers/tute_provider.dart';
// import '../../widgets/cards/student_list_tile.dart';
// import '../../widgets/cards/tute_issue_tile.dart';
// import '../../widgets/common/empty_state.dart';
// import '../../widgets/common/student_search_field.dart';
// import '../../widgets/dialogs/confirmation_dialog.dart';

// /// "Distribute" tab of Tutes & Materials.
// ///
// /// Flow:
// ///  1. Admin scans a QR / types a student number, code, phone or name.
// ///  2. The student's enrolled classes are listed with every tute of each class.
// ///  3. Issued tutes show who issued them and when.
// ///     Tutes not yet received show "available - tap to issue".
// ///  4. Tap an available tute -> confirm -> it becomes issued and the
// ///     Tutes tab counts update (same TuteProvider).
// ///
// /// Needs these providers above it: StudentProvider, EnrollmentProvider,
// /// TuteProvider (all added in the Tutes module route).
// class DistributeTab extends StatefulWidget {
//   final int instituteId;

//   const DistributeTab({super.key, required this.instituteId});

//   @override
//   State<DistributeTab> createState() => _DistributeTabState();
// }

// class _DistributeTabState extends State<DistributeTab> {
//   StudentModel? _selected;
//   List<StudentModel> _candidates = [];
//   String _query = '';

//   @override
//   void didUpdateWidget(covariant DistributeTab oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     // Institute switched: the old student no longer applies.
//     if (oldWidget.instituteId != widget.instituteId) {
//       _selected = null;
//       _candidates = [];
//       _query = '';
//     }
//   }

//   // One match -> select it (typical for a QR scan).
//   // Several matches -> let the admin pick.
//   // None -> clear.
//   void _onResults(List<StudentModel> results) {
//     setState(() {
//       _candidates = results.length > 1 ? results : [];
//       _selected = results.length == 1 ? results.first : null;
//     });
//   }

//   Future<void> _issue(
//     StudentModel student,
//     TuteModel tute,
//     EnrollmentModel enrollment,
//   ) async {
//     final confirmed = await ConfirmationDialog.show(
//       context,
//       title: 'Issue tute?',
//       message:
//           'Issue "${tute.name}" to ${student.name} '
//           '(${enrollment.classCode})?',
//       confirmText: 'Issue',
//     );

//     if (!confirmed || !mounted) return;

//     try {
//       // TO DO BACKEND: TuteProvider -> TuteService.markAsReceived()
//       // sends POST /api/institutes/{id}/tutes/{tuteId}/distributions
//       await context.read<TuteProvider>().issueToStudent(
//         instituteId: widget.instituteId,
//         tuteId: tute.id,
//         studentId: student.id,
//       );

//       if (!mounted) return;
//       AppSnackBar.show(context, '${tute.name} issued to ${student.name}.');
//     } catch (error) {
//       if (!mounted) return;
//       AppSnackBar.error(context, error, fallback: 'Unable to issue tute.');
//     }
//   }

//   void _reissue() {
//     // TO DO: open the Reissue flow (Reissue tab) for this tute + student.
//     // TO DO BACKEND: POST /api/institutes/{id}/tute-distributions/{id}/reissue
//     AppSnackBar.show(context, 'Reissue will be added with the Reissue tab.');
//   }

//   // ------------------------------------------------------------------
//   // UI pieces
//   // ------------------------------------------------------------------

//   Widget _studentCard(StudentModel student) {
//     final initial = student.name.trim().isEmpty
//         ? '?'
//         : student.name.trim()[0].toUpperCase();

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 17,
//             backgroundColor: AppColors.moduleIconBackground,
//             child: Text(
//               initial,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.authHeading,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   student.name,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.authHeading,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '${student.studentCode} · ${student.grade}',
//                   style: const TextStyle(
//                     fontSize: 10,
//                     color: AppColors.authIcon,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _classSection({
//     required StudentModel student,
//     required EnrollmentModel enrollment,
//     required TuteProvider tuteProvider,
//   }) {
//     final tutes =
//         tuteProvider.tutes.where((tute) {
//           if (tute.instituteId != widget.instituteId) return false;
//           if (tute.classId != enrollment.classId) return false;

//           // Archived tutes cannot be issued, so only show them
//           // when the student already received them.
//           final issued = tuteProvider.hasReceived(
//             tuteId: tute.id,
//             studentId: student.id,
//           );
//           return issued || tute.status == TuteStatus.active;
//         }).toList()..sort((a, b) => a.releaseDate.compareTo(b.releaseDate));

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 18, bottom: 4),
//           child: Text(
//             '${enrollment.className} (${enrollment.classCode})',
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: AppColors.primary,
//             ),
//           ),
//         ),
//         if (tutes.isEmpty)
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 8),
//             child: Text(
//               'No tutes for this class yet.',
//               style: TextStyle(fontSize: 11, color: AppColors.authIcon),
//             ),
//           ),
//         for (final tute in tutes) _tuteTile(student, tute, enrollment, tuteProvider),
//       ],
//     );
//   }

//   Widget _tuteTile(
//     StudentModel student,
//     TuteModel tute,
//     EnrollmentModel enrollment,
//     TuteProvider tuteProvider,
//   ) {
//     final record = tuteProvider.distributionFor(
//       tuteId: tute.id,
//       studentId: student.id,
//     );

//     final subtitle = record == null
//         ? 'available – tap to issue'
//         : 'Issued ${AppFormatters.longDate(record.receivedAt)} '
//               'by ${record.issuedBy}'
//               '${record.reissueCount > 0 ? ' · reissued ${record.reissueCount}×' : ''}';

//     return TuteIssueTile(
//       title: tute.name,
//       subtitle: subtitle,
//       isIssued: record != null,
//       isBusy: tuteProvider.isIssuing(tuteId: tute.id, studentId: student.id),
//       onIssue: () => _issue(student, tute, enrollment),
//       onReissue: _reissue,
//     );
//   }

//   Widget _body(
//     StudentProvider studentProvider,
//     TuteProvider tuteProvider,
//     EnrollmentProvider enrollmentProvider,
//   ) {
//     final student = _selected;

//     if (student != null) {
//       // Classes the student is currently enrolled in.
//       final enrollments =
//           enrollmentProvider.enrollments
//               .where(
//                 (e) =>
//                     e.instituteId == widget.instituteId &&
//                     e.studentId == student.id &&
//                     e.status == 'enrolled',
//               )
//               .toList()
//             ..sort((a, b) => a.classId.compareTo(b.classId));

//       return ListView(
//         padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
//         children: [
//           _studentCard(student),
//           if (enrollments.isEmpty)
//             const Padding(
//               padding: EdgeInsets.only(top: 40),
//               child: EmptyState(
//                 icon: Icons.groups_outlined,
//                 title: 'Not enrolled in any class',
//                 subtitle: 'Enroll the student in a class to issue tutes.',
//               ),
//             ),
//           for (final enrollment in enrollments)
//             _classSection(
//               student: student,
//               enrollment: enrollment,
//               tuteProvider: tuteProvider,
//             ),
//         ],
//       );
//     }

//     if (_candidates.isNotEmpty) {
//       return ListView.separated(
//         padding: const EdgeInsets.only(bottom: 30),
//         itemCount: _candidates.length,
//         separatorBuilder: (_, _) =>
//             const Divider(height: 1, color: AppColors.profileDivider),
//         itemBuilder: (_, index) {
//           final candidate = _candidates[index];
//           return StudentListTile(
//             student: candidate,
//             onTap: () => setState(() {
//               _selected = candidate;
//               _candidates = [];
//             }),
//           );
//         },
//       );
//     }

//     if (_query.isNotEmpty) {
//       return const EmptyState(
//         icon: Icons.search_off,
//         title: 'No student found',
//         subtitle: 'Check the student number or scan the QR again.',
//       );
//     }

//     return const EmptyState(
//       icon: Icons.qr_code_scanner,
//       title: 'Find the student',
//       subtitle: 'Scan the QR or enter the student no. / code to see their tutes.',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer3<StudentProvider, TuteProvider, EnrollmentProvider>(
//       builder: (context, studentProvider, tuteProvider, enrollmentProvider, _) {
//         if (studentProvider.isLoading ||
//             tuteProvider.isLoading ||
//             enrollmentProvider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final error =
//             studentProvider.errorMessage ??
//             tuteProvider.errorMessage ??
//             enrollmentProvider.errorMessage;

//         if (error != null) {
//           return EmptyState(icon: Icons.error_outline, title: error);
//         }

//         return Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
//               child: StudentSearchField(
//                 students: studentProvider.students,
//                 onResultsChanged: _onResults,
//                 onQueryChanged: (query) => setState(() => _query = query),
//               ),
//             ),
//             Expanded(child: _body(studentProvider, tuteProvider, enrollmentProvider)),
//           ],
//         );
//       },
//     );
//   }
// }
