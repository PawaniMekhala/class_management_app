import '../../models/institute_branch_model.dart';

class InstituteBranchService {
  static final List<InstituteBranchModel> _branches = [
    const InstituteBranchModel(
      id: 1,
      name: 'Sipsala Institute - Gampaha',
      code: 'SIPGAM',
      city: 'Gampaha',
      district: 'Gampaha',
    ),
    const InstituteBranchModel(
      id: 2,
      name: 'Sipsala Institute - Kandy',
      code: 'SIPKDY',
      city: 'Kandy',
      district: 'Kandy',
    ),
  ];

  // TO DO: API - Get institutes linked to authenticated user.
  Future<List<InstituteBranchModel>> getBranches() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return List.unmodifiable(_branches);
  }

  // Temporary ID generation for dummy data.
  // TO DO: Backend will generate institute IDs.
  int getNextBranchId() {
    if (_branches.isEmpty) return 1;

    final maxId = _branches
        .map((branch) => branch.id)
        .reduce((a, b) => a > b ? a : b);

    return maxId + 1;
  }

  // TO DO: Replace with authenticated Add Branch API.
  Future<void> addBranch(InstituteBranchModel branch) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_branches.any((item) => item.id == branch.id)) {
      throw Exception('Institute already exists.');
    }

    _branches.add(branch);
  }
}
