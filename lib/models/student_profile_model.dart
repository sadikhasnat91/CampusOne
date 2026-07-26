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

  StudentProfileModel({
    required this.name,
    required this.department,
    required this.semester,
    required this.section,
    required this.group,
    required this.university,
    required this.profilePictureUrl,
  });

  StudentProfileModel copyWith({
    String? name,
    String? department,
    String? semester,
    String? section,
    String? group,
    String? university,
    String? profilePictureUrl,
  }) {
    return StudentProfileModel(
      name: name ?? this.name,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      group: group ?? this.group,
      university: university ?? this.university,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  factory StudentProfileModel.defaultProfile() {
    return StudentProfileModel(
      name: 'Sadik Rahman',
      department: 'Computer Science & Engineering',
      semester: '6th Semester',
      section: 'A',
      group: 'Group 1',
      university: 'State University of Technology',
      profilePictureUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
    );
  }
}
