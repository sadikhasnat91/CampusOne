import 'package:hive/hive.dart';

part 'expense_item_model.g.dart';

@HiveType(typeId: 15)
class ExpenseItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String type; // 'income', 'expense', 'savings'

  @HiveField(4)
  final String category;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String note;

  ExpenseItemModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note = '',
  });

  ExpenseItemModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return ExpenseItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  static List<ExpenseItemModel> getDefaultItems() {
    final now = DateTime.now();
    return [
      ExpenseItemModel(
        id: 'exp_1',
        title: 'Monthly Allowance',
        amount: 5000.0,
        type: 'income',
        category: 'Allowance',
        date: now.subtract(const Duration(days: 15)),
      ),
      ExpenseItemModel(
        id: 'exp_2',
        title: 'Cafeteria Lunch',
        amount: 250.0,
        type: 'expense',
        category: 'Food',
        date: now.subtract(const Duration(days: 2)),
      ),
      ExpenseItemModel(
        id: 'exp_3',
        title: 'Textbooks',
        amount: 1200.0,
        type: 'expense',
        category: 'Education',
        date: now.subtract(const Duration(days: 5)),
      ),
      ExpenseItemModel(
        id: 'exp_4',
        title: 'Emergency Fund',
        amount: 1000.0,
        type: 'savings',
        category: 'Savings',
        date: now.subtract(const Duration(days: 10)),
      ),
      ExpenseItemModel(
        id: 'exp_5',
        title: 'Bus Ticket',
        amount: 50.0,
        type: 'expense',
        category: 'Transport',
        date: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
