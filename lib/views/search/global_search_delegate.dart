import 'package:flutter/material.dart';
import '../../database/hive_service.dart';
import '../../widgets/custom_card.dart';
import '../../constants/app_dimensions.dart';

class GlobalSearchDelegate extends SearchDelegate<String?> {
  @override
  String get searchFieldLabel => 'Search notes, subjects, faculty...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)),
            const SizedBox(height: AppDimensions.md),
            Text(
              'Search CampusOne Everywhere',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: AppDimensions.xs),
            const Text(
              'Type to search notes, classes, subjects & expenses',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final q = query.toLowerCase().trim();

    // Query Hive boxes
    final notes = HiveService.instance.notesBox.values.where(
      (n) => n.title.toLowerCase().contains(q) || n.contentJson.toLowerCase().contains(q),
    ).toList();

    final subjects = HiveService.instance.subjectsBox.values.where(
      (s) => s.name.toLowerCase().contains(q) || s.code.toLowerCase().contains(q),
    ).toList();

    final faculty = HiveService.instance.facultyBox.values.where(
      (f) => f.name.toLowerCase().contains(q) || f.department.toLowerCase().contains(q) || f.designation.toLowerCase().contains(q),
    ).toList();

    final expenses = HiveService.instance.expensesBox.values.where(
      (e) => e.title.toLowerCase().contains(q) || e.category.toLowerCase().contains(q),
    ).toList();

    final routines = HiveService.instance.routineItemsBox.values.where(
      (r) => r.subjectName.toLowerCase().contains(q) || r.roomNo.toLowerCase().contains(q),
    ).toList();

    final totalResults = notes.length + subjects.length + faculty.length + expenses.length + routines.length;

    if (totalResults == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Text('No results found for "$query"', style: const TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.md),
      children: [
        if (notes.isNotEmpty) ...[
          _buildCategoryHeader(context, 'Notes (${notes.length})', Icons.note_outlined),
          ...notes.map((n) => _buildResultItem(
                context: context,
                title: n.title.isEmpty ? 'Untitled Note' : n.title,
                subtitle: n.tags.isNotEmpty ? n.tags.join(', ') : 'Study Note',
                icon: Icons.article_outlined,
              )),
          const SizedBox(height: AppDimensions.md),
        ],

        if (subjects.isNotEmpty) ...[
          _buildCategoryHeader(context, 'Subjects (${subjects.length})', Icons.menu_book_outlined),
          ...subjects.map((s) => _buildResultItem(
                context: context,
                title: '${s.code} - ${s.name}',
                subtitle: 'Credits: ${s.credits} • ${s.semester}',
                icon: Icons.book_outlined,
              )),
          const SizedBox(height: AppDimensions.md),
        ],

        if (routines.isNotEmpty) ...[
          _buildCategoryHeader(context, 'Routine (${routines.length})', Icons.schedule_outlined),
          ...routines.map((r) => _buildResultItem(
                context: context,
                title: r.subjectName,
                subtitle: '${r.dayOfWeek} • ${r.startTime} - ${r.endTime} (${r.roomNo})',
                icon: Icons.class_outlined,
              )),
          const SizedBox(height: AppDimensions.md),
        ],

        if (faculty.isNotEmpty) ...[
          _buildCategoryHeader(context, 'Faculty (${faculty.length})', Icons.people_outline),
          ...faculty.map((f) => _buildResultItem(
                context: context,
                title: f.name,
                subtitle: '${f.designation} • ${f.department}',
                icon: Icons.person_outline,
              )),
          const SizedBox(height: AppDimensions.md),
        ],

        if (expenses.isNotEmpty) ...[
          _buildCategoryHeader(context, 'Expenses (${expenses.length})', Icons.account_balance_wallet_outlined),
          ...expenses.map((e) => _buildResultItem(
                context: context,
                title: e.title,
                subtitle: '\$${e.amount.toStringAsFixed(2)} • ${e.category}',
                icon: Icons.monetization_on_outlined,
              )),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppDimensions.xs),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.xs),
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => close(context, title),
        ),
      ),
    );
  }
}
