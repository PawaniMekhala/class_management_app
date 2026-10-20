import '../../models/academic_subject_model.dart';

class AcademicSubjectService {
  static final List<AcademicSubjectModel> _demoSubjects = [
    const AcademicSubjectModel(
      id: 1,
      instituteId: 1,
      name: 'English Language',
      educationLevel: 'Secondary (Grade 6–11)',
      nationalSubject: 'English Language',
      code: 'OL-ENG',
      description: '',
      classCount: 1,
    ),
    const AcademicSubjectModel(
      id: 2,
      instituteId: 1,
      name: 'ICT',
      educationLevel: 'Secondary (Grade 6–11)',
      nationalSubject: 'Information & Communication Technology',
      code: 'OL-ICT',
      description: '',
      classCount: 1,
    ),
    const AcademicSubjectModel(
      id: 3,
      instituteId: 1,
      name: 'Mathematics',
      educationLevel: 'Secondary (Grade 6–11)',
      nationalSubject: 'Mathematics',
      code: 'OL-MATH',
      description: '',
      classCount: 1,
    ),
    const AcademicSubjectModel(
      id: 4,
      instituteId: 1,
      name: 'Science',
      educationLevel: 'Secondary (Grade 6–11)',
      nationalSubject: 'Science',
      code: 'OL-SCI',
      description: '',
      classCount: 1,
    ),
    const AcademicSubjectModel(
      id: 5,
      instituteId: 1,
      name: 'Accounting',
      educationLevel: 'Advanced Level',
      nationalSubject: 'Accounting',
      code: 'AL-ACC',
      description: '',
      classCount: 1,
    ),
    const AcademicSubjectModel(
      id: 6,
      instituteId: 1,
      name: 'Biology',
      educationLevel: 'Advanced Level',
      nationalSubject: 'Biology',
      code: 'AL-BIO',
      description: '',
      classCount: 1,
    ),
    const AcademicSubjectModel(
      id: 7,
      instituteId: 1,
      name: 'Chemistry',
      educationLevel: 'Advanced Level',
      nationalSubject: 'Chemistry',
      code: 'AL-CHEM',
      description: '',
      classCount: 1,
    ),
    const AcademicSubjectModel(
      id: 8,
      instituteId: 1,
      name: 'Combined Mathematics',
      educationLevel: 'Advanced Level',
      nationalSubject: 'Combined Mathematics (Physical Science)',
      code: 'AL-CMATH',
      description: '',
      classCount: 2,
    ),
    const AcademicSubjectModel(
      id: 9,
      instituteId: 1,
      name: 'Economics',
      educationLevel: 'Advanced Level',
      nationalSubject: 'Economics',
      code: 'AL-ECON',
      description: '',
      classCount: 1,
    ),
    const AcademicSubjectModel(
      id: 10,
      instituteId: 1,
      name: 'Physics',
      educationLevel: 'Advanced Level',
      nationalSubject: 'Physics',
      code: 'AL-PHY',
      description: '',
      classCount: 1,
    ),
    const AcademicSubjectModel(
      id: 11,
      instituteId: 1,
      name: 'Computer Networks',
      educationLevel: 'Higher Education',
      nationalSubject: '',
      code: 'CN-001',
      description: '',
      classCount: 0,
      isModule: true,
    ),
  ];

  Future<List<AcademicSubjectModel>> getSubjects(int instituteId) async {
    // TO DO: GET /api/institutes/{instituteId}/subjects
    await Future.delayed(const Duration(milliseconds: 250));

    return _demoSubjects
        .where((subject) => subject.instituteId == instituteId)
        .toList();
  }

  Future<AcademicSubjectModel> saveSubject(AcademicSubjectModel subject) async {
    // TO DO: POST for new subjects, PATCH for existing subjects.
    await Future.delayed(const Duration(milliseconds: 350));

    if (subject.id == 0) {
      final nextId = _demoSubjects.isEmpty
          ? 1
          : _demoSubjects.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;

      final created = AcademicSubjectModel(
        id: nextId,
        instituteId: subject.instituteId,
        name: subject.name,
        educationLevel: subject.educationLevel,
        nationalSubject: subject.nationalSubject,
        code: subject.code,
        description: subject.description,
        classCount: 0,
        isModule: subject.isModule,
      );

      _demoSubjects.add(created);
      return created;
    }

    final index = _demoSubjects.indexWhere(
      (s) => s.id == subject.id && s.instituteId == subject.instituteId,
    );

    if (index == -1) {
      throw Exception('Subject not found');
    }

    _demoSubjects[index] = subject;
    return subject;
  }

  Future<void> deleteSubject(int instituteId, int subjectId) async {
    // TO DO: DELETE /api/institutes/{instituteId}/subjects/{subjectId}
    await Future.delayed(const Duration(milliseconds: 250));

    final index = _demoSubjects.indexWhere(
      (s) => s.id == subjectId && s.instituteId == instituteId,
    );

    if (index == -1) throw Exception('Subject not found');
    if (_demoSubjects[index].classCount > 0) {
      throw Exception('Cannot delete a subject used by classes');
    }

    _demoSubjects.removeAt(index);
  }
}
