import 'package:hive/hive.dart';

part 'goal_item_model.g.dart';

@HiveType(typeId: 9)
class GoalItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double targetHours;

  @HiveField(3)
  final double completedHours;

  @HiveField(4)
  final DateTime deadline;

  @HiveField(5)
  final String category;

  GoalItemModel({
    required this.id,
    required this.title,
    required this.targetHours,
    required this.completedHours,
    required this.deadline,
    required this.category,
  });

  double get progressPercentage {
    if (targetHours == 0) return 0.0;
    final progress = (completedHours / targetHours) * 100;
    return progress > 100 ? 100 : progress;
  }

  GoalItemModel copyWith({
    String? id,
    String? title,
    double? targetHours,
    double? completedHours,
    DateTime? deadline,
    String? category,
  }) {
    return GoalItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetHours: targetHours ?? this.targetHours,
      completedHours: completedHours ?? this.completedHours,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
    );
  }

  static List<GoalItemModel> getDefaultGoals() {
    final now = DateTime.now();
    return [
      GoalItemModel(
        id: 'goal_1',
        title: 'Master Data Structures',
        targetHours: 40.0,
        completedHours: 18.5,
        deadline: now.add(const Duration(days: 21)),
        category: 'Academic',
      ),
      GoalItemModel(
        id: 'goal_2',
        title: 'Complete Algorithms Course',
        targetHours: 60.0,
        completedHours: 32.0,
        deadline: now.add(const Duration(days: 45)),
        category: 'Study',
      ),
      GoalItemModel(
        id: 'goal_3',
        title: 'Improve Physical Fitness',
        targetHours: 30.0,
        completedHours: 12.0,
        deadline: now.add(const Duration(days: 30)),
        category: 'Health',
      ),
    ];
  }
}
