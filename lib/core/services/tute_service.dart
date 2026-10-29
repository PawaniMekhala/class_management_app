import '../../models/tute_model.dart';
import '../../models/tute_distribution_model.dart';

class TuteService {
  // Shared dummy tute data.
  static final List<TuteModel> _tutes = [
    TuteModel(
      id: 101,
      instituteId: 1,
      classId: 1,
      name: 'Combined Maths — Unit 01',
      unitName: 'Unit 01',
      releaseDate: DateTime(2026, 10, 1),
      status: TuteStatus.active,
    ),
    TuteModel(
      id: 102,
      instituteId: 1,
      classId: 1,
      name: 'Combined Maths — Unit 02',
      unitName: 'Unit 02',
      releaseDate: DateTime(2026, 10, 8),
      status: TuteStatus.active,
    ),
    TuteModel(
      id: 103,
      instituteId: 1,
      classId: 1,
      name: 'Combined Maths — Unit 03',
      unitName: 'Unit 03',
      releaseDate: DateTime(2026, 10, 15),
      status: TuteStatus.active,
    ),
    TuteModel(
      id: 104,
      instituteId: 1,
      classId: 1,
      name: 'Combined Maths — Unit 04',
      unitName: 'Unit 04',
      releaseDate: DateTime(2026, 10, 22),
      status: TuteStatus.active,
    ),
    TuteModel(
      id: 105,
      instituteId: 1,
      classId: 2,
      name: 'Physics — Unit 01',
      unitName: 'Unit 01',
      releaseDate: DateTime(2026, 10, 5),
      status: TuteStatus.active,
    ),
    TuteModel(
      id: 106,
      instituteId: 1,
      classId: 3,
      name: 'Chemistry — Unit 03',
      unitName: 'Unit 03',
      releaseDate: DateTime(2026, 10, 10),
      status: TuteStatus.active,
    ),
    TuteModel(
      id: 107,
      instituteId: 1,
      classId: 3,
      name: 'Chemistry — Unit 01',
      unitName: 'Unit 01',
      releaseDate: DateTime(2026, 9, 10),
      status: TuteStatus.archived,
    ),
    TuteModel(
      id: 108,
      instituteId: 1,
      classId: 3,
      name: 'Chemistry — Unit 02',
      unitName: 'Unit 02',
      releaseDate: DateTime(2026, 9, 19),
      status: TuteStatus.archived,
    ),
    TuteModel(
      id: 109,
      instituteId: 1,
      classId: 4,
      name: 'Biology — Unit 01',
      unitName: 'Unit 01',
      releaseDate: DateTime(2026, 9, 15),
      status: TuteStatus.archived,
    ),
  ];

  // Shared dummy distribution records.
  static final List<TuteDistributionModel> _distributions = [
    // for (int tuteId = 101; tuteId <= 104; tuteId++)
    //   for (final studentId in [6, 7])
    //     TuteDistributionModel(
    //       id: (tuteId - 101) * 2 + (studentId - 6) + 1,
    //       instituteId: 1,
    //       tuteId: tuteId,
    //       studentId: studentId,
    //       receivedAt: DateTime(2026, 10, 25),
    //     ),
    TuteDistributionModel(
      id: 1,
      instituteId: 1,
      tuteId: 101,
      studentId: 6,
      receivedAt: DateTime(2026, 10, 1),
      // issuedBy: 'Dilani Wickramasinghe',
    ),
    TuteDistributionModel(
      id: 2,
      instituteId: 1,
      tuteId: 104,
      studentId: 6,
      receivedAt: DateTime(2026, 10, 8),
    ),
    TuteDistributionModel(
      id: 3,
      instituteId: 1,
      tuteId: 104,
      studentId: 15,
      receivedAt: DateTime(2026, 10, 8),
    ),
    TuteDistributionModel(
      id: 4,
      instituteId: 1,
      tuteId: 105,
      studentId: 6,
      receivedAt: DateTime(2026, 10, 8),
    ),
  ];

  Future<List<TuteModel>> getTutes(int instituteId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _tutes.where((tute) => tute.instituteId == instituteId).toList();
  }

  Future<List<TuteDistributionModel>> getDistributions(int instituteId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _distributions
        .where((record) => record.instituteId == instituteId)
        .toList();
  }

  Future<void> markAsReceived({
    required int instituteId,
    required int tuteId,
    required List<int> studentIds,
  }) async {
    final tute = _tutes.where(
      (item) => item.id == tuteId && item.instituteId == instituteId,
    );

    if (tute.isEmpty) {
      throw Exception('Tute not found.');
    }

    if (tute.first.status == TuteStatus.archived) {
      throw Exception('Archived tutes cannot be distributed.');
    }

    for (final studentId in studentIds) {
      final alreadyReceived = _distributions.any(
        (record) =>
            record.instituteId == instituteId &&
            record.tuteId == tuteId &&
            record.studentId == studentId,
      );

      if (alreadyReceived) {
        continue;
      }

      _distributions.add(
        TuteDistributionModel(
          id: _distributions.length + 1,
          instituteId: instituteId,
          tuteId: tuteId,
          studentId: studentId,
          receivedAt: DateTime.now(),
        ),
      );
    }
  }

  // Create a new tute using dummy data.
  Future<TuteModel> createTute({
    required int instituteId,
    required int classId,
    required String name,
    required String unitName,
    required DateTime releaseDate,
    required TuteStatus status,
    required TuteType type,
    String? description,

    String? attachmentName,
    String? attachmentPath,
    int? attachmentSize,
  }) async {
    // TO DO: BACKEND INTEGRATION
    // Replace this dummy implementation with the Create Tute API.
    // The backend should return the newly created tute.

    await Future.delayed(const Duration(milliseconds: 300));

    // Generate a unique ID for the new tute.
    final newId = _tutes.isEmpty
        ? 1
        : _tutes.map((tute) => tute.id).reduce((a, b) => a > b ? a : b) + 1;

    final newTute = TuteModel(
      id: newId,
      instituteId: instituteId,
      classId: classId,
      name: name,
      unitName: unitName,
      releaseDate: releaseDate,
      status: status,
      type: type,
      description: description,

      attachmentName: attachmentName,
      attachmentPath: attachmentPath,
      attachmentSize: attachmentSize,
    );

    _tutes.add(newTute);

    return newTute;
  }
}
