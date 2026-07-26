import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_dimensions.dart';
import '../../controllers/routine_controller.dart';
import '../../helpers/snackbar_helper.dart';
import '../../models/routine_item_model.dart';
import '../../services/routine_pdf_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/routine_item_card.dart';
import 'widgets/add_edit_routine_dialog.dart';

class StudyView extends StatelessWidget {
  const StudyView({super.key});

  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  void _showAddEditDialog(BuildContext context, RoutineController controller, {RoutineItemModel? item}) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditRoutineDialog(
        item: item,
        activeSemester: controller.selectedSemester,
        activeSection: controller.selectedSection,
        activeGroup: controller.selectedGroup,
        onSave: (newItem) {
          controller.addOrUpdateRoutine(newItem);
          SnackbarHelper.showSuccess(
            context,
            item == null ? 'Routine Slot Created!' : 'Routine Slot Updated!',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<RoutineController>(context);
    final filtered = controller.filteredRoutines;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Routine Generator', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              controller.showFavoritesOnly ? Icons.star_rounded : Icons.star_border_rounded,
              color: controller.showFavoritesOnly ? Colors.amber : null,
            ),
            tooltip: 'Favorites Only',
            onPressed: () => controller.toggleFavoritesOnly(),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Export Printable PDF',
            onPressed: () {
              if (filtered.isEmpty) {
                SnackbarHelper.showError(context, 'No routine slots to export!');
                return;
              }
              RoutinePdfService.exportAndPrintPdf(
                routines: filtered,
                semester: controller.selectedSemester,
                section: controller.selectedSection,
                group: controller.selectedGroup,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Auto Master Routine Filtering Header Widget
          Container(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: controller.selectedSemester,
                        decoration: const InputDecoration(labelText: 'Semester', isDense: true),
                        items: ['1st Semester', '2nd Semester', '3rd Semester', '4th Semester', '5th Semester', '6th Semester', '7th Semester', '8th Semester']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.updateStudentProfileFilter(val, controller.selectedSection, controller.selectedGroup);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: controller.selectedSection,
                        decoration: const InputDecoration(labelText: 'Section', isDense: true),
                        items: ['A', 'B', 'C']
                            .map((sec) => DropdownMenuItem(value: sec, child: Text('Sec $sec', style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.updateStudentProfileFilter(controller.selectedSemester, val, controller.selectedGroup);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: controller.selectedGroup,
                        decoration: const InputDecoration(labelText: 'Group', isDense: true),
                        items: ['Group 1', 'Group 2']
                            .map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.updateStudentProfileFilter(controller.selectedSemester, controller.selectedSection, val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                // Search bar
                CustomTextField(
                  label: 'Search Subject, Teacher, or Room...',
                  prefixIcon: Icons.search,
                  hint: 'Type algorithm, lab 402, Knuth...',
                  validator: null,
                ),
              ],
            ),
          ),

          // Mode & Day Selector Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SegmentedButton<RoutineViewMode>(
                  segments: const [
                    ButtonSegment(value: RoutineViewMode.daily, label: Text('Daily')),
                    ButtonSegment(value: RoutineViewMode.weekly, label: Text('Weekly')),
                    ButtonSegment(value: RoutineViewMode.calendar, label: Text('Grid')),
                  ],
                  selected: {controller.viewMode},
                  onSelectionChanged: (set) => controller.setViewMode(set.first),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.cloud_download_rounded, size: 18),
                  tooltip: 'Import Master Routine',
                  onPressed: () {
                    controller.importMasterRoutineSamples();
                    SnackbarHelper.showSuccess(context, 'Master University Routine Imported!');
                  },
                )
              ],
            ),
          ),

          if (controller.viewMode == RoutineViewMode.daily)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                itemCount: _days.length,
                itemBuilder: (context, idx) {
                  final day = _days[idx];
                  final isSelected = day == controller.selectedDay;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (_) => controller.setSelectedDay(day),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: AppDimensions.sm),

          // Main Timetable Content Body
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateWidget(
                    title: 'No Classes Found',
                    description: 'No scheduled classes match your selected filter (${controller.selectedSemester}, Sec ${controller.selectedSection}, ${controller.selectedGroup}).',
                    icon: Icons.calendar_today_outlined,
                    actionLabel: 'Add Class Routine',
                    onAction: () => _showAddEditDialog(context, controller),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.md),
                        child: RoutineItemCard(
                          routine: item,
                          onFavoriteToggle: () => controller.toggleFavorite(item),
                          onEdit: () => _showAddEditDialog(context, controller, item: item),
                          onDelete: () => controller.deleteRoutine(item.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
    );
  }
}
