import '../../models/hall_model.dart';

class HallService {
  static final List<HallModel> _halls = [
    const HallModel(
      id: 1,
      instituteId: 1,
      name: 'Computer Lab',
      number: 'LAB1',
      capacity: 40,
      building: 'Main Building',
      floor: 'Second floor',
      status: 'active',
      facilities: [
        'Whiteboard',
        'Projector',
        'Air conditioner',
        'Computers',
        'Internet',
      ],
      weeklyClassCount: 2,
    ),
    const HallModel(
      id: 2,
      instituteId: 1,
      name: 'Hall A',
      number: 'H02',
      capacity: 60,
      building: 'Main Building',
      floor: 'First floor',
      status: 'active',
      facilities: ['Whiteboard', 'Projector', 'Air conditioner'],
      weeklyClassCount: 4,
    ),
    const HallModel(
      id: 3,
      instituteId: 1,
      name: 'Hall B',
      number: 'H03',
      capacity: 60,
      building: 'Main Building',
      floor: 'First floor',
      status: 'active',
      facilities: ['Whiteboard', 'Projector (faulty)'],
      weeklyClassCount: 4,
    ),
    const HallModel(
      id: 4,
      instituteId: 1,
      name: 'Main Hall',
      number: 'H01',
      capacity: 200,
      building: 'Main Building',
      floor: 'Ground floor',
      status: 'active',
      facilities: [
        'Whiteboard',
        'Projector',
        'Audio system',
        'Air conditioner',
      ],
      weeklyClassCount: 3,
    ),
    const HallModel(
      id: 5,
      instituteId: 1,
      name: 'Seminar Room',
      number: 'H04',
      capacity: 30,
      building: 'Main Building',
      floor: 'Second floor',
      status: 'under_maintenance',
      facilities: ['Whiteboard'],
    ),
  ];

  Future<List<HallModel>> getHalls(int instituteId) async {
    // TO DO BACKEND:
    // GET /api/institutes/{instituteId}/halls

    await Future.delayed(const Duration(milliseconds: 250));

    return _halls.where((hall) => hall.instituteId == instituteId).toList();
  }

  Future<HallModel> createHall(HallModel hall) async {
    // TO DO BACKEND:
    // POST /api/institutes/{hall.instituteId}/halls

    await Future.delayed(const Duration(milliseconds: 250));

    final nextId = _halls.isEmpty
        ? 1
        : _halls.map((hall) => hall.id).reduce((a, b) => a > b ? a : b) + 1;

    final duplicate = _halls.any(
      (existing) =>
          existing.instituteId == hall.instituteId &&
          existing.number.toLowerCase() == hall.number.toLowerCase(),
    );

    if (duplicate) {
      throw Exception('This hall number already exists in the institute.');
    }

    final created = hall.copyWith(id: nextId);
    _halls.add(created);
    return created;
  }

  Future<HallModel> updateHallStatus({
    required int instituteId,
    required int hallId,
    required String status,
  }) async {
    // TO DO BACKEND:
    // PATCH /api/institutes/{instituteId}/halls/{hallId}/status
    // Body: {"status": "under_maintenance"}

    const allowed = {'active', 'under_maintenance', 'closed'};

    if (!allowed.contains(status)) {
      throw Exception('Invalid hall status');
    }

    await Future.delayed(const Duration(milliseconds: 250));

    final index = _halls.indexWhere(
      (hall) => hall.id == hallId && hall.instituteId == instituteId,
    );

    if (index == -1) {
      throw Exception('Hall not found');
    }

    final updated = _halls[index].copyWith(status: status);
    _halls[index] = updated;
    return updated;
  }
}
