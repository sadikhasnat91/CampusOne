import 'package:flutter/material.dart';
import '../../../constants/app_dimensions.dart';
import '../../../models/student_profile_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class EditProfileDialog extends StatefulWidget {
  final StudentProfileModel profile;
  final Function(
    String name,
    String department,
    String semester,
    String section,
    String group,
    String university,
  ) onSave;

  const EditProfileDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _deptController;
  late TextEditingController _semesterController;
  late TextEditingController _sectionController;
  late TextEditingController _groupController;
  late TextEditingController _uniController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _deptController = TextEditingController(text: widget.profile.department);
    _semesterController = TextEditingController(text: widget.profile.semester);
    _sectionController = TextEditingController(text: widget.profile.section);
    _groupController = TextEditingController(text: widget.profile.group);
    _uniController = TextEditingController(text: widget.profile.university);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deptController.dispose();
    _semesterController.dispose();
    _sectionController.dispose();
    _groupController.dispose();
    _uniController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nameController.text.trim(),
        _deptController.text.trim(),
        _semesterController.text.trim(),
        _sectionController.text.trim(),
        _groupController.text.trim(),
        _uniController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edit Student Profile', style: theme.textTheme.headlineSmall),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                CustomTextField(
                  label: 'Student Name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: AppDimensions.md),
                CustomTextField(
                  label: 'Department',
                  controller: _deptController,
                  prefixIcon: Icons.school_outlined,
                ),
                const SizedBox(height: AppDimensions.md),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Semester',
                        controller: _semesterController,
                        prefixIcon: Icons.numbers,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: CustomTextField(
                        label: 'Section',
                        controller: _sectionController,
                        prefixIcon: Icons.class_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Group',
                        controller: _groupController,
                        prefixIcon: Icons.groups_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                CustomTextField(
                  label: 'University',
                  controller: _uniController,
                  prefixIcon: Icons.account_balance_outlined,
                ),
                const SizedBox(height: AppDimensions.lg),
                CustomButton(
                  label: 'Save Profile Changes',
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
