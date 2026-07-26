import 'package:hive/hive.dart';

part 'faculty_member_model.g.dart';

@HiveType(typeId: 13)
class FacultyMemberModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String designation;

  @HiveField(3)
  final String department;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final String phone;

  @HiveField(6)
  final String roomNo;

  @HiveField(7)
  final String officeHours;

  @HiveField(8)
  final bool isFavorite;

  FacultyMemberModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.email,
    required this.phone,
    required this.roomNo,
    required this.officeHours,
    this.isFavorite = false,
  });

  FacultyMemberModel copyWith({bool? isFavorite}) {
    return FacultyMemberModel(
      id: id, name: name, designation: designation, department: department,
      email: email, phone: phone, roomNo: roomNo, officeHours: officeHours,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static List<FacultyMemberModel> getDefaultFaculty() {
    return [
      FacultyMemberModel(id: 'fac_1', name: 'Dr. Alan Turing', designation: 'Professor & HOD',
        department: 'CSE', email: 'turing@campus.edu', phone: '+880-1234-0001',
        roomNo: 'Room 301', officeHours: 'Sun & Tue: 10 AM – 12 PM', isFavorite: true),
      FacultyMemberModel(id: 'fac_2', name: 'Prof. Donald Knuth', designation: 'Associate Professor',
        department: 'CSE', email: 'knuth@campus.edu', phone: '+880-1234-0002',
        roomNo: 'Room 305', officeHours: 'Mon & Wed: 2 PM – 4 PM'),
      FacultyMemberModel(id: 'fac_3', name: 'Dr. Margaret Hamilton', designation: 'Senior Lecturer',
        department: 'CSE', email: 'hamilton@campus.edu', phone: '+880-1234-0003',
        roomNo: 'Room 308', officeHours: 'Tue & Thu: 9 AM – 11 AM'),
      FacultyMemberModel(id: 'fac_4', name: 'Dr. Grace Hopper', designation: 'Associate Professor',
        department: 'EEE', email: 'hopper@campus.edu', phone: '+880-1234-0004',
        roomNo: 'Room 201', officeHours: 'Mon & Wed: 10 AM – 12 PM'),
      FacultyMemberModel(id: 'fac_5', name: 'Prof. Richard Feynman', designation: 'Professor',
        department: 'Physics', email: 'feynman@campus.edu', phone: '+880-1234-0005',
        roomNo: 'Room 112', officeHours: 'Sun & Thu: 11 AM – 1 PM'),
    ];
  }
}
