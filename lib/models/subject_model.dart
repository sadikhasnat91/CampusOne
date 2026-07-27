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
    this.gradePoint = 0.0,
  });

  double get attendancePercentage {
    if (totalClasses == 0) return 100.0;
    return double.parse(
      ((attendedClasses / totalClasses) * 100).toStringAsFixed(1),
    );
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

  static List<SubjectModel> getDefaultSubjects([
    String institutionType = 'university',
  ]) {
    if (institutionType == 'school') {
      return [
        for (int c = 1; c <= 12; c++) ...[
          SubjectModel(
            id: 'sch_${c}_1',
            name: 'English Literature',
            code: 'ENG-${100 + c}',
            credits: 0.0,
            semester: 'Class $c',
            attendedClasses: 12,
            totalClasses: 15,
            gradePoint: 0.0,
          ),
          SubjectModel(
            id: 'sch_${c}_2',
            name: 'Mathematics',
            code: 'MATH-${100 + c}',
            credits: 0.0,
            semester: 'Class $c',
            attendedClasses: 14,
            totalClasses: 15,
            gradePoint: 0.0,
          ),
          SubjectModel(
            id: 'sch_${c}_3',
            name: 'General Science',
            code: 'SCI-${100 + c}',
            credits: 0.0,
            semester: 'Class $c',
            attendedClasses: 11,
            totalClasses: 13,
            gradePoint: 0.0,
          ),
          SubjectModel(
            id: 'sch_${c}_4',
            name: 'History & Civics',
            code: 'HIST-${100 + c}',
            credits: 0.0,
            semester: 'Class $c',
            attendedClasses: 9,
            totalClasses: 10,
            gradePoint: 0.0,
          ),
        ],
      ];
    } else if (institutionType == 'college') {
      return [
        for (int y = 1; y <= 2; y++) ...[
          SubjectModel(
            id: 'col_${y}_1',
            name: 'English',
            code: 'ENG-${200 + y}',
            credits: 3.0,
            semester: '${y}${y == 1 ? 'st' : 'nd'} Year',
            attendedClasses: 15,
            totalClasses: 18,
            gradePoint: 0.0,
          ),
          SubjectModel(
            id: 'col_${y}_2',
            name: 'Information Technology',
            code: 'ICT-${200 + y}',
            credits: 3.0,
            semester: '${y}${y == 1 ? 'st' : 'nd'} Year',
            attendedClasses: 13,
            totalClasses: 15,
            gradePoint: 0.0,
          ),
          SubjectModel(
            id: 'col_${y}_3',
            name: 'Physics',
            code: 'PHY-${200 + y}',
            credits: 4.0,
            semester: '${y}${y == 1 ? 'st' : 'nd'} Year',
            attendedClasses: 16,
            totalClasses: 18,
            gradePoint: 0.0,
          ),
          SubjectModel(
            id: 'col_${y}_4',
            name: 'Chemistry',
            code: 'CHE-${200 + y}',
            credits: 4.0,
            semester: '${y}${y == 1 ? 'st' : 'nd'} Year',
            attendedClasses: 12,
            totalClasses: 16,
            gradePoint: 0.0,
          ),
        ],
      ];
    } else {
      return [
        // 1st Semester
        SubjectModel(
          id: 'sub_101',
          name: 'Structured Programming',
          code: 'CSE-101',
          credits: 3.0,
          semester: '1st Semester',
          attendedClasses: 14,
          totalClasses: 16,
          gradePoint: 0.0,
        ),
        SubjectModel(
          id: 'sub_102',
          name: 'Physics I',
          code: 'PHY-101',
          credits: 3.0,
          semester: '1st Semester',
          attendedClasses: 12,
          totalClasses: 15,
          gradePoint: 0.0,
        ),
        SubjectModel(
          id: 'sub_103',
          name: 'Differential Calculus',
          code: 'MATH-101',
          credits: 3.0,
          semester: '1st Semester',
          attendedClasses: 15,
          totalClasses: 15,
          gradePoint: 0.0,
        ),

        // 2nd Semester
        SubjectModel(
          id: 'sub_201',
          name: 'Object Oriented Programming',
          code: 'CSE-103',
          credits: 3.0,
          semester: '2nd Semester',
          attendedClasses: 16,
          totalClasses: 18,
          gradePoint: 0.0,
        ),
        SubjectModel(
          id: 'sub_202',
          name: 'Data Structures',
          code: 'CSE-105',
          credits: 4.0,
          semester: '2nd Semester',
          attendedClasses: 14,
          totalClasses: 16,
          gradePoint: 0.0,
        ),

        // 3rd Semester
        SubjectModel(
          id: 'sub_301',
          name: 'Digital Logic Design',
          code: 'CSE-201',
          credits: 3.0,
          semester: '3rd Semester',
          attendedClasses: 15,
          totalClasses: 17,
          gradePoint: 0.0,
        ),
        SubjectModel(
          id: 'sub_302',
          name: 'Discrete Mathematics',
          code: 'MATH-201',
          credits: 3.0,
          semester: '3rd Semester',
          attendedClasses: 13,
          totalClasses: 15,
          gradePoint: 0.0,
        ),

        // 4th Semester
        SubjectModel(
          id: 'sub_401',
          name: 'Computer Architecture',
          code: 'CSE-203',
          credits: 3.0,
          semester: '4th Semester',
          attendedClasses: 16,
          totalClasses: 18,
          gradePoint: 0.0,
        ),
        SubjectModel(
          id: 'sub_402',
          name: 'Numerical Methods',
          code: 'MATH-203',
          credits: 3.0,
          semester: '4th Semester',
          attendedClasses: 14,
          totalClasses: 16,
          gradePoint: 0.0,
        ),

        // 5th Semester
        SubjectModel(
          id: 'sub_501',
          name: 'Operating Systems',
          code: 'CSE-301',
          credits: 3.0,
          semester: '5th Semester',
          attendedClasses: 17,
          totalClasses: 19,
          gradePoint: 0.0,
        ),
        SubjectModel(
          id: 'sub_502',
          name: 'Theory of Computation',
          code: 'CSE-303',
          credits: 3.0,
          semester: '5th Semester',
          attendedClasses: 15,
          totalClasses: 17,
          gradePoint: 0.0,
        ),

        // 6th Semester
        SubjectModel(
          id: 'sub_601',
          name: 'Database Systems',
          code: 'CSE-305',
          credits: 3.0,
          semester: '6th Semester',
          attendedClasses: 18,
          totalClasses: 20,
          gradePoint: 0.0,
        ),
        SubjectModel(
          id: 'sub_602',
          name: 'Algorithms Design',
          code: 'CSE-307',
          credits: 4.0,
          semester: '6th Semester',
          attendedClasses: 15,
          totalClasses: 18,
          gradePoint: 0.0,
        ),
        SubjectModel(
          id: 'sub_603',
          name: 'Software Engineering',
          code: 'CSE-309',
          credits: 3.0,
          semester: '6th Semester',
          attendedClasses: 12,
          totalClasses: 14,
          gradePoint: 0.0,
        ),

        // 7th Semester
        SubjectModel(
          id: 'sub_701',
          name: 'Computer Networks',
          code: 'CSE-401',
          credits: 3.0,
          semester: '7th Semester',
          attendedClasses: 16,
          totalClasses: 18,
          gradePoint: 0.0,
        ),
        SubjectModel(
          id: 'sub_702',
          name: 'Artificial Intelligence',
          code: 'CSE-403',
          credits: 3.0,
          semester: '7th Semester',
          attendedClasses: 14,
          totalClasses: 16,
          gradePoint: 0.0,
        ),
        SubjectModel(
          id: 'sub_703',
          name: 'Compiler Design',
          code: 'CSE-405',
          credits: 3.0,
          semester: '7th Semester',
          attendedClasses: 13,
          totalClasses: 15,
          gradePoint: 0.0,
        ),

        // 8th Semester
        SubjectModel(
          id: 'sub_801',
          name: 'Machine Learning',
          code: 'CSE-407',
          credits: 3.0,
          semester: '8th Semester',
          attendedClasses: 17,
          totalClasses: 18,
          gradePoint: 0.0,
        ),
        SubjectModel(
          id: 'sub_802',
          name: 'Capstone Project & Thesis',
          code: 'CSE-499',
          credits: 6.0,
          semester: '8th Semester',
          attendedClasses: 20,
          totalClasses: 20,
          gradePoint: 0.0,
        ),
      ];
    }
  }
}
