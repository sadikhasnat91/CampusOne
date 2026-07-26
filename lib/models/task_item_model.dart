import 'package:hive/hive.dart';

part 'task_item_model.g.dart';

@HiveType(typeId: 7)
class TaskItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String priority; // 'high', 'medium', 'low'

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final bool isCompleted;

  TaskItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });

  TaskItemModel copyWith({
    String? id,
    String? title,
    String? category,
    String? priority,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return TaskItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  static List<TaskItemModel> getDefaultTasks() {
    final now = DateTime.now();
    return [
      TaskItemModel(
        id: 'task_1',
        title: 'Complete DBMS Lab Report',
        category: 'Academic',
        priority: 'high',
        dueDate: now.add(const Duration(hours: 4)),
      ),
      TaskItemModel(
        id: 'task_2',
        title: 'Study Graph Algorithms Chapter 6',
        category: 'Study',
        priority: 'medium',
        dueDate: now.add(const Duration(hours: 8)),
      ),
      TaskItemModel(
        id: 'task_3',
        title: 'Read Software Engineering Slides',
        category: 'Study',
        priority: 'low',
        dueDate: now.add(const Duration(days: 1)),
      ),
      TaskItemModel(
        id: 'task_4',
        title: 'Submit Assignment via LMS Portal',
        category: 'Academic',
        priority: 'high',
        dueDate: now,
        isCompleted: true,
      ),
    ];
  }
}
