import 'package:hive/hive.dart';

part 'habit_item_model.g.dart';

@HiveType(typeId: 8)
class HabitItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int streakCount;

  @HiveField(3)
  final List<String> completedDates; // ISO-8601 date strings "yyyy-MM-dd"

  @HiveField(4)
  final int targetDaysPerWeek;

  HabitItemModel({
    required this.id,
    required this.title,
    required this.streakCount,
    required this.completedDates,
    required this.targetDaysPerWeek,
  });

  bool get isCompletedToday {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    return completedDates.contains(todayKey);
  }

  HabitItemModel copyWith({
    String? id,
    String? title,
    int? streakCount,
    List<String>? completedDates,
    int? targetDaysPerWeek,
  }) {
    return HabitItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      streakCount: streakCount ?? this.streakCount,
      completedDates: completedDates ?? this.completedDates,
      targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
    );
  }

  static List<HabitItemModel> getDefaultHabits() {
    return [
      HabitItemModel(
        id: 'habit_1',
        title: '📚 Study for 2 Hours',
        streakCount: 7,
        completedDates: [],
        targetDaysPerWeek: 5,
      ),
      HabitItemModel(
        id: 'habit_2',
        title: '🏃 Morning Exercise',
        streakCount: 4,
        completedDates: [],
        targetDaysPerWeek: 6,
      ),
      HabitItemModel(
        id: 'habit_3',
        title: '📖 Read 20 Minutes',
        streakCount: 12,
        completedDates: [],
        targetDaysPerWeek: 7,
      ),
      HabitItemModel(
        id: 'habit_4',
        title: '🧘 Meditation Session',
        streakCount: 3,
        completedDates: [],
        targetDaysPerWeek: 5,
      ),
    ];
  }
}
