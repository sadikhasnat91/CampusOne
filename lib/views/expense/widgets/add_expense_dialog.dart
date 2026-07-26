import 'package:flutter/material.dart';
import '../../../constants/app_dimensions.dart';
import '../../../controllers/expense_controller.dart';
import '../../../models/expense_item_model.dart';
import '../../../helpers/snackbar_helper.dart';

class AddExpenseDialog extends StatefulWidget {
  final ExpenseController controller;
  
  const AddExpenseDialog({super.key, required this.controller});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  
  String _type = 'expense';
  String _category = 'Food';

  final Map<String, List<String>> _categories = {
    'income': ['Allowance', 'Salary', 'Freelance', 'Gift', 'Other'],
    'expense': ['Food', 'Education', 'Transport', 'Entertainment', 'Shopping', 'Health', 'Bills', 'Other'],
    'savings': ['Emergency Fund', 'Investment', 'Savings Account'],
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) {
      SnackbarHelper.showError(context, 'Title and Amount are required.');
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      SnackbarHelper.showError(context, 'Enter a valid amount.');
      return;
    }

    final item = ExpenseItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      amount: amount,
      type: _type,
      category: _category,
      date: DateTime.now(),
      note: _noteCtrl.text.trim(),
    );

    widget.controller.addTransaction(item);
    Navigator.pop(context);
    SnackbarHelper.showSuccess(context, 'Transaction added successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
      title: const Text('New Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Transaction Type Toggle
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'income', label: Text('Income')),
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'savings', label: Text('Savings')),
              ],
              selected: {_type},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _type = newSelection.first;
                  _category = _categories[_type]!.first;
                });
              },
            ),
            const SizedBox(height: AppDimensions.lg),
            
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g., Cafeteria Lunch'),
            ),
            const SizedBox(height: AppDimensions.md),
            
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount (\$)', hintText: '0.00'),
            ),
            const SizedBox(height: AppDimensions.md),
            
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories[_type]!.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _category = val);
              },
            ),
            const SizedBox(height: AppDimensions.md),
            
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Note (Optional)'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
