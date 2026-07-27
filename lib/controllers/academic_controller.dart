import 'package:flutter/foundation.dart';
import '../constants/hive_box_keys.dart';
import '../database/hive_service.dart';
import '../models/academic_event_model.dart';
import '../models/course_material_model.dart';
import '../models/subject_model.dart';

class AcademicController extends ChangeNotifier {
  List<SubjectModel> _subjects = [];
  List<CourseMaterialModel> _materials = [];
  List<AcademicEventModel> _events = [];

  String _selectedSemester = '6th Semester';

  AcademicController() {
    _loadAcademicData();
  }

  List<SubjectModel> get subjects =>
      _subjects.where((s) => s.semester == _selectedSemester).toList();
  List<CourseMaterialModel> get materials => _materials;
  List<AcademicEventModel> get events => _events;
  String get selectedSemester => _selectedSemester;

  void _loadAcademicData() {
    final subBox = HiveService.instance.subjectsBox;
    final matBox = HiveService.instance.courseMaterialsBox;
    final evtBox = HiveService.instance.academicEventsBox;

    final profileBox = HiveService.instance.userProfileBox;
    final profile = profileBox.get(HiveBoxKeys.studentProfileKey);
    if (profile != null) {
      _selectedSemester = profile.semester;
    }

    _subjects = subBox.values.toList();
    _materials = matBox.values.toList();
    _events = evtBox.values.toList();

    notifyListeners();
  }

  void setSelectedSemester(String semester) {
    _selectedSemester = semester;
    notifyListeners();
  }

  void syncWithProfile() {
    final profileBox = HiveService.instance.userProfileBox;
    final profile = profileBox.get(HiveBoxKeys.studentProfileKey);
    if (profile != null) {
      _selectedSemester = profile.semester;
      _loadAcademicData();
    }
  }

  Future<void> changeInstitutionType(String instType) async {
    final subBox = HiveService.instance.subjectsBox;
    await subBox.clear();
    _loadAcademicData();
  }

  /// Overall CGPA/GPA across ALL semesters (cumulative)
  double calculateOverallCgpa() {
    if (_subjects.isEmpty) return 0.0;
    double totalPoints = 0;
    double totalCredits = 0;
    bool hasCredits = false;

    for (var sub in _subjects) {
      if (sub.credits > 0) {
        hasCredits = true;
        totalPoints += (sub.gradePoint * sub.credits);
        totalCredits += sub.credits;
      } else {
        totalPoints += sub.gradePoint;
      }
    }

    if (hasCredits) {
      if (totalCredits == 0) return 0.0;
      return double.parse((totalPoints / totalCredits).toStringAsFixed(2));
    } else {
      if (_subjects.isEmpty) return 0.0;
      return double.parse((totalPoints / _subjects.length).toStringAsFixed(2));
    }
  }

  /// GPA for the currently selected semester only
  double calculateCurrentSemesterGpa() {
    final current = subjects; // filtered by _selectedSemester
    if (current.isEmpty) return 0.0;
    double totalPoints = 0;
    double totalCredits = 0;
    bool hasCredits = false;

    for (var sub in current) {
      if (sub.credits > 0) {
        hasCredits = true;
        totalPoints += (sub.gradePoint * sub.credits);
        totalCredits += sub.credits;
      } else {
        totalPoints += sub.gradePoint;
      }
    }

    if (hasCredits) {
      if (totalCredits == 0) return 0.0;
      return double.parse((totalPoints / totalCredits).toStringAsFixed(2));
    } else {
      return double.parse((totalPoints / current.length).toStringAsFixed(2));
    }
  }

  double calculateExpectedCgpa(double targetPointsForNewSubjects) {
    double totalPoints = 0;
    double totalCredits = 0;
    for (var sub in _subjects) {
      totalPoints += (sub.gradePoint * sub.credits);
      totalCredits += sub.credits;
    }
    // Add 12 credits of projected semester
    totalPoints += (targetPointsForNewSubjects * 12.0);
    totalCredits += 12.0;
    return double.parse((totalPoints / totalCredits).toStringAsFixed(2));
  }

  Future<void> updateAttendance(
    String subjectId,
    int attended,
    int total,
  ) async {
    final idx = _subjects.indexWhere((s) => s.id == subjectId);
    if (idx != -1) {
      final updated = _subjects[idx].copyWith(
        attendedClasses: attended,
        totalClasses: total,
      );
      await HiveService.instance.subjectsBox.put(updated.id, updated);
      _loadAcademicData();
    }
  }

  Future<void> addSubject(SubjectModel subject) async {
    await HiveService.instance.subjectsBox.put(subject.id, subject);
    _loadAcademicData();
  }

  Future<void> updateSubject(SubjectModel subject) async {
    await HiveService.instance.subjectsBox.put(subject.id, subject);
    _loadAcademicData();
  }

  Future<void> deleteSubject(String id) async {
    await HiveService.instance.subjectsBox.delete(id);
    _loadAcademicData();
  }

  Future<void> addMaterial(CourseMaterialModel material) async {
    await HiveService.instance.courseMaterialsBox.put(material.id, material);
    _loadAcademicData();
  }

  Future<void> updateMaterial(CourseMaterialModel material) async {
    await HiveService.instance.courseMaterialsBox.put(material.id, material);
    _loadAcademicData();
  }

  Future<void> deleteMaterial(String id) async {
    await HiveService.instance.courseMaterialsBox.delete(id);
    _loadAcademicData();
  }

  Future<void> addAcademicEvent(AcademicEventModel event) async {
    await HiveService.instance.academicEventsBox.put(event.id, event);
    _loadAcademicData();
  }

  Future<void> updateAcademicEvent(AcademicEventModel event) async {
    await HiveService.instance.academicEventsBox.put(event.id, event);
    _loadAcademicData();
  }

  Future<void> deleteAcademicEvent(String id) async {
    await HiveService.instance.academicEventsBox.delete(id);
    _loadAcademicData();
  }

  Future<void> toggleEventCompletion(AcademicEventModel event) async {
    final updated = event.copyWith(isCompleted: !event.isCompleted);
    await HiveService.instance.academicEventsBox.put(updated.id, updated);
    _loadAcademicData();
  }
}
