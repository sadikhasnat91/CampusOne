import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../constants/app_dimensions.dart';
import '../../controllers/expense_controller.dart';
import '../../models/expense_item_model.dart';
import '../../widgets/custom_card.dart';
import 'widgets/add_expense_dialog.dart';

class ExpenseTrackerView extends StatefulWidget {
  const ExpenseTrackerView({super.key});

  @override
  State<ExpenseTrackerView> createState() => _ExpenseTrackerViewState();
}

class _ExpenseTrackerViewState extends State<ExpenseTrackerView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context, ExpenseController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AddExpenseDialog(controller: ctrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'History'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, context.read<ExpenseController>()),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ExpenseController>(
        builder: (context, ctrl, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildDashboard(theme, ctrl),
              _buildHistory(theme, ctrl),
              _buildAnalytics(theme, ctrl),
            ],
          );
        },
      ),
    );
  }

  // ─── DASHBOARD TAB ───────────────────────────────────────────────────────
  Widget _buildDashboard(ThemeData theme, ExpenseController ctrl) {
    final expensesByCategory = ctrl.expensesByCategory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              children: [
                const Text('Current Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  '\$${ctrl.totalBalance.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // Overview Cards
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_downward_rounded, color: Colors.green),
                      const SizedBox(height: 4),
                      const Text('Income', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('\$${ctrl.totalIncome.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_upward_rounded, color: Colors.red),
                      const SizedBox(height: 4),
                      const Text('Expenses', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('\$${ctrl.totalExpense.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: CustomCard(
                  child: Column(
                    children: [
                      const Icon(Icons.savings_outlined, color: Colors.blue),
                      const SizedBox(height: 4),
                      const Text('Savings', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('\$${ctrl.totalSavings.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          // Pie Chart
          Text('Expense Breakdown (This Month)', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppDimensions.md),
          if (expensesByCategory.isEmpty)
            const CustomCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.lg),
                  child: Text('No expenses recorded this month.'),
                ),
              ),
            )
          else
            CustomCard(
              child: SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: _buildPieSections(theme, expensesByCategory),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(ThemeData theme, Map<String, double> data) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.tertiary,
      Colors.orange,
      Colors.redAccent,
      Colors.green,
      Colors.purple,
    ];
    int i = 0;
    return data.entries.map((e) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '${e.key}\n\$${e.value.toStringAsFixed(0)}',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  // ─── HISTORY TAB ─────────────────────────────────────────────────────────
  Widget _buildHistory(ThemeData theme, ExpenseController ctrl) {
    final txs = ctrl.filteredTransactions;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'All', label: Text('All')),
              ButtonSegment(value: 'Income', label: Text('Income')),
              ButtonSegment(value: 'Expense', label: Text('Expense')),
              ButtonSegment(value: 'Savings', label: Text('Savings')),
            ],
            selected: {ctrl.selectedFilter},
            onSelectionChanged: (set) => ctrl.setFilter(set.first),
          ),
        ),
        Expanded(
          child: txs.isEmpty
              ? const Center(child: Text('No transactions found.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    return _transactionTile(theme, tx, ctrl);
                  },
                ),
        ),
      ],
    );
  }

  Widget _transactionTile(ThemeData theme, ExpenseItemModel tx, ExpenseController ctrl) {
    final isIncome = tx.type == 'income';
    final isSavings = tx.type == 'savings';
    
    Color iconColor = isIncome ? Colors.green : (isSavings ? Colors.blue : Colors.red);
    IconData icon = isIncome ? Icons.arrow_downward_rounded : (isSavings ? Icons.savings_outlined : Icons.arrow_upward_rounded);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${tx.category} • ${tx.date.day}/${tx.date.month}/${tx.date.year}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isIncome ? Colors.green : (isSavings ? Colors.blue : Colors.red),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => ctrl.deleteTransaction(tx.id),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ANALYTICS TAB ───────────────────────────────────────────────────────
  Widget _buildAnalytics(ThemeData theme, ExpenseController ctrl) {
    final trends = ctrl.monthlyTrends;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Income vs Expense', style: theme.textTheme.titleMedium),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export'),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          CustomCard(
            child: SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(trends),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < trends.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                trends[value.toInt()]['month'],
                                style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: trends.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value['income'],
                          color: Colors.green,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: e.value['expense'],
                          color: Colors.red,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppDimensions.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem('Income', Colors.green),
              const SizedBox(width: 24),
              _legendItem('Expense', Colors.red),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
  
  double _getMaxY(List<Map<String, dynamic>> trends) {
    double max = 0;
    for (var t in trends) {
      if (t['income'] > max) max = t['income'];
      if (t['expense'] > max) max = t['expense'];
    }
    return (max * 1.2).ceilToDouble(); // Add 20% padding to top
  }
}
