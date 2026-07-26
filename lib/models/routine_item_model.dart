import 'package:hive/hive.dart';

part 'routine_item_model.g.dart';

@HiveType(typeId: 3)
class RoutineItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectName;

  @HiveField(2)
  final String courseCode;

  @HiveField(3)
  final String teacherName;

  @HiveField(4)
  final String roomNo;

  @HiveField(5)
  final String startTime; // e.g. "09:00 AM"

  @HiveField(6)
  final String endTime; // e.g. "10:30 AM"

  @HiveField(7)
  final String dayOfWeek; // "Monday", "Tuesday", etc.

  @HiveField(8)
  final String semester; // "6th Semester", "1st Semester"

  @HiveField(9)
  final String section; // "A", "B", "C"

  @HiveField(10)
  final String group; // "Group 1", "Group 2"

  @HiveField(11)
  final int colorHex;

  @HiveField(12)
  final bool isFavorite;

  RoutineItemModel({
    required this.id,
    required this.subjectName,
    required this.courseCode,
    required this.teacherName,
    required this.roomNo,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.semester,
    required this.section,
    required this.group,
    required this.colorHex,
    this.isFavorite = false,
  });

  RoutineItemModel copyWith({
    String? id,
    String? subjectName,
    String? courseCode,
    String? teacherName,
    String? roomNo,
    String? startTime,
    String? endTime,
    String? dayOfWeek,
    String? semester,
    String? section,
    String? group,
    int? colorHex,
    bool? isFavorite,
  }) {
    return RoutineItemModel(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      courseCode: courseCode ?? this.courseCode,
      teacherName: teacherName ?? this.teacherName,
      roomNo: roomNo ?? this.roomNo,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      group: group ?? this.group,
      colorHex: colorHex ?? this.colorHex,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static List<RoutineItemModel> getMasterSampleRoutines() {
    return [
      RoutineItemModel(
        id: '1',
        subjectName: 'Database Systems',
        courseCode: 'CSE-301',
        teacherName: 'Dr. Alan Turing',
        roomNo: 'Lab 402',
        startTime: '09:00 AM',
        endTime: '10:30 AM',
        dayOfWeek: 'Monday',
        semester: '6th Semester',
        section: 'A',
        group: 'Group 1',
        colorHex: 0xFF0061A4,
        isFavorite: true,
      ),
      RoutineItemModel(
        id: '2',
        subjectName: 'Algorithms Design',
        courseCode: 'CSE-303',
        teacherName: 'Prof. Donald Knuth',
        roomNo: 'Room 305',
        startTime: '11:00 AM',
        endTime: '12:30 PM',
        dayOfWeek: 'Monday',
        semester: '6th Semester',
        section: 'A',
        group: 'Group 1',
        colorHex: 0xFF5856D6,
      ),
      RoutineItemModel(
        id: '3',
        subjectName: 'Software Engineering',
        courseCode: 'CSE-305',
        teacherName: 'Dr. Margaret Hamilton',
        roomNo: 'Room 201',
        startTime: '02:00 PM',
        endTime: '03:30 PM',
        dayOfWeek: 'Tuesday',
        semester: '6th Semester',
        section: 'A',
        group: 'Group 1',
        colorHex: 0xFF2E7D32,
        isFavorite: true,
      ),
      RoutineItemModel(
        id: '4',
        subjectName: 'Computer Networks',
        courseCode: 'CSE-307',
        teacherName: 'Prof. Vint Cerf',
        roomNo: 'Lab 104',
        startTime: '10:00 AM',
        endTime: '11:30 AM',
        dayOfWeek: 'Wednesday',
        semester: '6th Semester',
        section: 'A',
        group: 'Group 1',
        colorHex: 0xFFED6C02,
      ),
      RoutineItemModel(
        id: '5',
        subjectName: 'Physics I',
        courseCode: 'PHY-101',
        teacherName: 'Dr. Richard Feynman',
        roomNo: 'Hall A',
        startTime: '09:00 AM',
        endTime: '10:30 AM',
        dayOfWeek: 'Monday',
        semester: '1st Semester',
        section: 'B',
        group: 'Group 2',
        colorHex: 0xFF6B5778,
      ),
    ];
  }
}
