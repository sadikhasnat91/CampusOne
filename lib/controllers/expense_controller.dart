import 'package:flutter/foundation.dart';
import '../database/hive_service.dart';
import '../models/expense_item_model.dart';

class ExpenseController extends ChangeNotifier {
  List<ExpenseItemModel> _transactions = [];

  String _selectedFilter = 'All'; // All, Income, Expense, Savings
  DateTime _selectedMonth = DateTime.now();

  ExpenseController() {
    _loadData();
  }

  List<ExpenseItemModel> get transactions => _transactions;
  String get selectedFilter => _selectedFilter;
  DateTime get selectedMonth => _selectedMonth;

  double get totalBalance => totalIncome - totalExpense - totalSavings;
  
  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0, (sum, item) => sum + item.amount);

  double get totalSavings => _transactions
      .where((t) => t.type == 'savings')
      .fold(0, (sum, item) => sum + item.amount);

  List<ExpenseItemModel> get filteredTransactions {
    List<ExpenseItemModel> filtered = _transactions;

    if (_selectedFilter != 'All') {
      filtered = filtered.where((t) => t.type.toLowerCase() == _selectedFilter.toLowerCase()).toList();
    }

    // Sort by date descending
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  // Analytics - current month expenses grouped by category
  Map<String, double> get expensesByCategory {
    final Map<String, double> grouped = {};
    final thisMonthExpenses = _transactions.where((t) => 
      t.type == 'expense' && 
      t.date.month == _selectedMonth.month && 
      t.date.year == _selectedMonth.year
    );

    for (var exp in thisMonthExpenses) {
      grouped[exp.category] = (grouped[exp.category] ?? 0) + exp.amount;
    }
    return grouped;
  }

  // Analytics - Last 6 months income vs expense
  List<Map<String, dynamic>> get monthlyTrends {
    final List<Map<String, dynamic>> trends = [];
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      
      final monthIncome = _transactions
          .where((t) => t.type == 'income' && t.date.month == month.month && t.date.year == month.year)
          .fold(0.0, (sum, item) => sum + item.amount);
          
      final monthExpense = _transactions
          .where((t) => t.type == 'expense' && t.date.month == month.month && t.date.year == month.year)
          .fold(0.0, (sum, item) => sum + item.amount);

      trends.add({
        'month': _monthAbbreviation(month.month),
        'income': monthIncome,
        'expense': monthExpense,
      });
    }
    return trends;
  }

  String _monthAbbreviation(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }

  void _loadData() {
    final box = HiveService.instance.expensesBox;
    if (box.isEmpty) {
      final defaults = ExpenseItemModel.getDefaultItems();
      for (var item in defaults) {
        box.put(item.id, item);
      }
      _transactions = defaults;
    } else {
      _transactions = box.values.toList();
    }
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setMonth(DateTime date) {
    _selectedMonth = date;
    notifyListeners();
  }

  Future<void> addTransaction(ExpenseItemModel transaction) async {
    await HiveService.instance.expensesBox.put(transaction.id, transaction);
    _loadData();
  }

  Future<void> deleteTransaction(String id) async {
    await HiveService.instance.expensesBox.delete(id);
    _loadData();
  }
}
