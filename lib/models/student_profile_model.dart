import 'package:hive/hive.dart';

part 'student_profile_model.g.dart';

@HiveType(typeId: 1)
class StudentProfileModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String department;

  @HiveField(2)
  final String semester;

  @HiveField(3)
  final String section;

  @HiveField(4)
  final String group;

  @HiveField(5)
  final String university;

  @HiveField(6)
  final String profilePictureUrl;

  @HiveField(7, defaultValue: 'university')
  final String institutionType;

  @HiveField(8, defaultValue: '')
  final String institutionLogoUrl;

  StudentProfileModel({
    required this.name,
    required this.department,
    required this.semester,
    required this.section,
    required this.group,
    required this.university,
    required this.profilePictureUrl,
    this.institutionType = 'university',
    this.institutionLogoUrl = '',
  });

  StudentProfileModel copyWith({
    String? name,
    String? department,
    String? semester,
    String? section,
    String? group,
    String? university,
    String? profilePictureUrl,
    String? institutionType,
    String? institutionLogoUrl,
  }) {
    return StudentProfileModel(
      name: name ?? this.name,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      group: group ?? this.group,
      university: university ?? this.university,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      institutionType: institutionType ?? this.institutionType,
      institutionLogoUrl: institutionLogoUrl ?? this.institutionLogoUrl,
    );
  }

  String get gradeLabel {
    switch (institutionType) {
      case 'school':
      case 'college':
        return 'GPA';
      case 'university':
      default:
        return 'CGPA';
    }
  }

  String get institutionLabel {
    switch (institutionType) {
      case 'school':
        return 'School';
      case 'college':
        return 'College';
      case 'university':
      default:
        return 'University';
    }
  }

  String get institutionNameLabel {
    switch (institutionType) {
      case 'school':
        return 'School Name';
      case 'college':
        return 'College Name';
      case 'university':
      default:
        return 'University Name';
    }
  }

  String get academicLevelLabel {
    switch (institutionType) {
      case 'school':
        return 'Class / Grade';
      case 'college':
        return 'Year / Class';
      case 'university':
      default:
        return 'Semester';
    }
  }

  String get majorLabel {
    switch (institutionType) {
      case 'school':
        return 'Class Group';
      case 'college':
        return 'Group / Stream';
      case 'university':
      default:
        return 'Department / Major';
    }
  }

  List<String> get academicLevelOptions {
    switch (institutionType) {
      case 'school':
        return List.generate(12, (i) => 'Class ${i + 1}');
      case 'college':
        return ['1st Year', '2nd Year'];
      case 'university':
      default:
        return List.generate(8, (i) => '${i + 1}${_ordinal(i + 1)} Semester');
    }
  }

  static String _ordinal(int n) {
    if (n >= 11 && n <= 13) return 'th';
    switch (n % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  factory StudentProfileModel.defaultProfile() {
    return StudentProfileModel(
      name: '',
      department: '',
      semester: '1st Semester',
      section: '',
      group: '',
      university: '',
      profilePictureUrl: '',
      institutionType: 'university',
      institutionLogoUrl: '',
    );
  }
}
