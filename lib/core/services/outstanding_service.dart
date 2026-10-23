import '../../models/outstanding_model.dart';
import 'payment_service.dart';
import 'student_service.dart';

class OutstandingService {
  final PaymentService _paymentService = PaymentService();
  final StudentService _studentService = StudentService();

  // TO DO BACKEND:
  // Replace with an endpoint returning outstanding charges
  // together with student and class information.
  Future<List<OutstandingModel>> getOutstanding(int instituteId) async {
    final charges = await _paymentService.getOutstandingCharges(instituteId);

    final students = await _studentService.getStudents(instituteId);

    final studentMap = {for (final student in students) student.id: student};

    final outstanding = <OutstandingModel>[];

    for (final charge in charges) {
      final student = studentMap[charge.studentId];

      if (student == null) continue;

      outstanding.add(OutstandingModel(charge: charge, student: student));
    }

    return outstanding;
  }
}
