import 'package:hive/hive.dart';

part 'subject_model.g.dart';

@HiveType(typeId: 4)
class SubjectModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String code;

  @HiveField(3)
  final double credits;

  @HiveField(4)
  final String semester;

  @HiveField(5)
  final int attendedClasses;

  @HiveField(6)
  final int totalClasses;

  @HiveField(7)
  final double gradePoint; // Grade points (0.0 to 4.0)

  SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.credits,
    required this.semester,
    this.attendedClasses = 0,
    this.totalClasses = 0,
    this.gradePoint = 4.0,
  });

  double get attendancePercentage {
    if (totalClasses == 0) return 100.0;
    return double.parse(((attendedClasses / totalClasses) * 100).toStringAsFixed(1));
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    String? code,
    double? credits,
    String? semester,
    int? attendedClasses,
    int? totalClasses,
    double? gradePoint,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
      attendedClasses: attendedClasses ?? this.attendedClasses,
      totalClasses: totalClasses ?? this.totalClasses,
      gradePoint: gradePoint ?? this.gradePoint,
    );
  }

  static List<SubjectModel> getDefaultSubjects() {
    return [
      SubjectModel(
        id: 'sub_1',
        name: 'Database Systems',
        code: 'CSE-301',
        credits: 3.0,
        semester: '6th Semester',
        attendedClasses: 18,
        totalClasses: 20,
        gradePoint: 3.75,
      ),
      SubjectModel(
        id: 'sub_2',
        name: 'Algorithms Design',
        code: 'CSE-303',
        credits: 4.0,
        semester: '6th Semester',
        attendedClasses: 15,
        totalClasses: 18,
        gradePoint: 4.0,
      ),
      SubjectModel(
        id: 'sub_3',
        name: 'Software Engineering',
        code: 'CSE-305',
        credits: 3.0,
        semester: '6th Semester',
        attendedClasses: 12,
        totalClasses: 14,
        gradePoint: 3.5,
      ),
    ];
  }
}
