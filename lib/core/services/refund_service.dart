import '../../models/refund_model.dart';

class RefundService {
  // TO DO BACKEND:
  // GET /api/institutes/{instituteId}/refunds
  //
  // The backend must verify that the logged-in user
  // has permission to view refunds for this institute.

  Future<List<RefundModel>> getRefunds(int instituteId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final refunds = <RefundModel>[
      RefundModel(
        id: 1,
        instituteId: 1,
        studentId: 9,
        refundNumber: 'REF-000001',
        receiptNumber: 'PAY-000001',
        studentName: 'Sachini Fernando',
        studentCode: 'SIPGAM-ST0003',
        amount: 1000,
        reason: 'Overpayment',
        method: 'cash',
        status: 'completed',
        requestedAt: DateTime(2026, 10, 10, 10, 30),
        processedAt: DateTime(2026, 10, 10, 11, 0),
        processedBy: 'Institute Admin',
        notes: 'Demo refund for UI testing.',
      ),
      RefundModel(
        id: 2,
        instituteId: 1,
        studentId: 7,
        refundNumber: 'REF-000002',
        receiptNumber: 'PAY-000002',
        studentName: 'Nethmi Silva',
        studentCode: 'SIPGAM-ST0001',
        amount: 1500,
        reason: 'Class cancellation',
        method: 'bank_transfer',
        status: 'pending',
        requestedAt: DateTime(2026, 10, 15, 9, 15),
        referenceNumber: null,
        notes: 'Demo pending refund.',
      ),
      RefundModel(
        id: 3,
        instituteId: 1,
        studentId: 6,
        refundNumber: 'REF-000003',
        receiptNumber: 'PAY-000003',
        studentName: 'Kavindu Perera',
        studentCode: 'SIPGAM-ST0002',
        amount: 2000,
        reason: 'Duplicate payment',
        method: 'online',
        status: 'approved',
        requestedAt: DateTime(2026, 10, 18, 14, 20),
        notes: 'Demo approved refund.',
      ),
    ];

    return refunds
        .where((refund) => refund.instituteId == instituteId)
        .toList();
  }
}
