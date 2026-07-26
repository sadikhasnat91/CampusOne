import 'package:hive/hive.dart';

part 'cover_page_model.g.dart';

@HiveType(typeId: 16)
class CoverPageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title; // E.g., 'Database Midterm', 'Physics Lab Report'

  @HiveField(2)
  final String studentName;

  @HiveField(3)
  final String studentId;

  @HiveField(4)
  final String department;

  @HiveField(5)
  final String semester;

  @HiveField(6)
  final String section;

  @HiveField(7)
  final String courseName;

  @HiveField(8)
  final String courseCode;

  @HiveField(9)
  final String teacherName;

  @HiveField(10)
  final DateTime submissionDate;

  @HiveField(11)
  final String universityName;

  CoverPageModel({
    required this.id,
    required this.title,
    required this.studentName,
    required this.studentId,
    required this.department,
    required this.semester,
    required this.section,
    required this.courseName,
    required this.courseCode,
    required this.teacherName,
    required this.submissionDate,
    required this.universityName,
  });

  CoverPageModel copyWith({
    String? id,
    String? title,
    String? studentName,
    String? studentId,
    String? department,
    String? semester,
    String? section,
    String? courseName,
    String? courseCode,
    String? teacherName,
    DateTime? submissionDate,
    String? universityName,
  }) {
    return CoverPageModel(
      id: id ?? this.id,
      title: title ?? this.title,
      studentName: studentName ?? this.studentName,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      teacherName: teacherName ?? this.teacherName,
      submissionDate: submissionDate ?? this.submissionDate,
      universityName: universityName ?? this.universityName,
    );
  }
}
