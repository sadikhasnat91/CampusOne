import 'package:flutter/foundation.dart';
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

    if (subBox.isEmpty) {
      final defaults = SubjectModel.getDefaultSubjects();
      for (var s in defaults) {
        subBox.put(s.id, s);
      }
      _subjects = defaults;
    } else {
      _subjects = subBox.values.toList();
    }

    if (matBox.isEmpty) {
      final defaults = CourseMaterialModel.getDefaultMaterials();
      for (var m in defaults) {
        matBox.put(m.id, m);
      }
      _materials = defaults;
    } else {
      _materials = matBox.values.toList();
    }

    if (evtBox.isEmpty) {
      final defaults = AcademicEventModel.getDefaultEvents();
      for (var e in defaults) {
        evtBox.put(e.id, e);
      }
      _events = defaults;
    } else {
      _events = evtBox.values.toList();
    }

    notifyListeners();
  }

  void setSelectedSemester(String semester) {
    _selectedSemester = semester;
    notifyListeners();
  }

  double calculateOverallCgpa() {
    if (_subjects.isEmpty) return 0.0;
    double totalPoints = 0;
    double totalCredits = 0;
    for (var sub in _subjects) {
      totalPoints += (sub.gradePoint * sub.credits);
      totalCredits += sub.credits;
    }
    if (totalCredits == 0) return 0.0;
    return double.parse((totalPoints / totalCredits).toStringAsFixed(2));
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

  Future<void> updateAttendance(String subjectId, int attended, int total) async {
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

  Future<void> addMaterial(CourseMaterialModel material) async {
    await HiveService.instance.courseMaterialsBox.put(material.id, material);
    _loadAcademicData();
  }

  Future<void> addAcademicEvent(AcademicEventModel event) async {
    await HiveService.instance.academicEventsBox.put(event.id, event);
    _loadAcademicData();
  }

  Future<void> toggleEventCompletion(AcademicEventModel event) async {
    final updated = event.copyWith(isCompleted: !event.isCompleted);
    await HiveService.instance.academicEventsBox.put(updated.id, updated);
    _loadAcademicData();
  }
}
