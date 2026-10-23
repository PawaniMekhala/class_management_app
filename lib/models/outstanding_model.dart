import 'payment_model.dart';
import 'student_model.dart';

class OutstandingModel {
  final PaymentCharge charge;
  final StudentModel student;

  const OutstandingModel({required this.charge, required this.student});

  int get daysOverdue {
    final today = DateTime.now();

    final currentDate = DateTime(today.year, today.month, today.day);

    final dueDate = DateTime(
      charge.dueDate.year,
      charge.dueDate.month,
      charge.dueDate.day,
    );

    final difference = currentDate.difference(dueDate).inDays;

    return difference > 0 ? difference : 0;
  }

  bool get isOverdue => daysOverdue > 0;

  double get balance => charge.balance;
}
