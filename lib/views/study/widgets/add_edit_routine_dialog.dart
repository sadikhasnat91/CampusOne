import 'package:flutter/material.dart';
import '../../../constants/app_dimensions.dart';
import '../../../models/routine_item_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class AddEditRoutineDialog extends StatefulWidget {
  final RoutineItemModel? item;
  final String activeSemester;
  final String activeSection;
  final String activeGroup;
  final Function(RoutineItemModel) onSave;

  const AddEditRoutineDialog({
    super.key,
    this.item,
    required this.activeSemester,
    required this.activeSection,
    required this.activeGroup,
    required this.onSave,
  });

  @override
  State<AddEditRoutineDialog> createState() => _AddEditRoutineDialogState();
}

class _AddEditRoutineDialogState extends State<AddEditRoutineDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late TextEditingController _codeController;
  late TextEditingController _teacherController;
  late TextEditingController _roomController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  String _selectedDay = 'Monday';
  int _selectedColor = 0xFF0061A4;

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<int> _colors = [0xFF0061A4, 0xFF5856D6, 0xFF2E7D32, 0xFFED6C02, 0xFFBA1A1A, 0xFF6B5778];

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.item?.subjectName ?? '');
    _codeController = TextEditingController(text: widget.item?.courseCode ?? '');
    _teacherController = TextEditingController(text: widget.item?.teacherName ?? '');
    _roomController = TextEditingController(text: widget.item?.roomNo ?? '');
    _startTimeController = TextEditingController(text: widget.item?.startTime ?? '09:00 AM');
    _endTimeController = TextEditingController(text: widget.item?.endTime ?? '10:30 AM');
    _selectedDay = widget.item?.dayOfWeek ?? 'Monday';
    _selectedColor = widget.item?.colorHex ?? 0xFF0061A4;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _codeController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newItem = RoutineItemModel(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        subjectName: _subjectController.text.trim(),
        courseCode: _codeController.text.trim(),
        teacherName: _teacherController.text.trim(),
        roomNo: _roomController.text.trim(),
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        dayOfWeek: _selectedDay,
        semester: widget.activeSemester,
        section: widget.activeSection,
        group: widget.activeGroup,
        colorHex: _selectedColor,
        isFavorite: widget.item?.isFavorite ?? false,
      );
      widget.onSave(newItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item == null ? 'Add Class Routine' : 'Edit Class Routine',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppDimensions.md),
                CustomTextField(
                  label: 'Subject Name',
                  controller: _subjectController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Course Code',
                        controller: _codeController,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: CustomTextField(
                        label: 'Room No',
                        controller: _roomController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                CustomTextField(
                  label: 'Teacher Name',
                  controller: _teacherController,
                ),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Start Time',
                        controller: _startTimeController,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: CustomTextField(
                        label: 'End Time',
                        controller: _endTimeController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDay,
                  decoration: const InputDecoration(labelText: 'Day of Week'),
                  items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDay = val);
                  },
                ),
                const SizedBox(height: AppDimensions.md),
                Text('Color Tag', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppDimensions.xs),
                Row(
                  children: _colors.map((c) {
                    final isSelected = c == _selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppDimensions.lg),
                CustomButton(
                  label: widget.item == null ? 'Create Routine Slot' : 'Update Routine Slot',
                  onPressed: _submit,
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
