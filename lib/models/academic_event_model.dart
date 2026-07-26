import 'package:hive/hive.dart';

part 'academic_event_model.g.dart';

@HiveType(typeId: 6)
class AcademicEventModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subjectName;

  @HiveField(3)
  final String eventType; // 'assignment' or 'exam'

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final bool isCompleted;

  AcademicEventModel({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.eventType,
    required this.dueDate,
    this.isCompleted = false,
  });

  int get daysRemaining {
    final diff = dueDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  AcademicEventModel copyWith({
    String? id,
    String? title,
    String? subjectName,
    String? eventType,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return AcademicEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectName: subjectName ?? this.subjectName,
      eventType: eventType ?? this.eventType,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  static List<AcademicEventModel> getDefaultEvents() {
    return [
      AcademicEventModel(
        id: 'evt_1',
        title: 'DBMS SQL Project Submission',
        subjectName: 'Database Systems',
        eventType: 'assignment',
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
      AcademicEventModel(
        id: 'evt_2',
        title: 'Algorithms Mid-Term Examination',
        subjectName: 'Algorithms Design',
        eventType: 'exam',
        dueDate: DateTime.now().add(const Duration(days: 5)),
      ),
    ];
  }
}
