import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../constants/app_dimensions.dart';
import '../../controllers/cover_page_controller.dart';
import '../../models/cover_page_model.dart';
import '../../helpers/snackbar_helper.dart';

class CoverPageEditorView extends StatefulWidget {
  final CoverPageModel initialTemplate;

  const CoverPageEditorView({super.key, required this.initialTemplate});

  @override
  State<CoverPageEditorView> createState() => _CoverPageEditorViewState();
}

class _CoverPageEditorViewState extends State<CoverPageEditorView> {
  final _formKey = GlobalKey<FormState>();
  late CoverPageModel _template;

  @override
  void initState() {
    super.initState();
    _template = widget.initialTemplate;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<CoverPageController>().saveTemplate(_template);
      SnackbarHelper.showSuccess(context, 'Cover Page Saved');
      Navigator.pop(context);
    }
  }

  void _previewPdf() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final ctrl = context.read<CoverPageController>();
      final pdfBytes = await ctrl.generatePdf(_template);
      
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          insetPadding: const EdgeInsets.all(AppDimensions.md),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                AppBar(
                  title: const Text('PDF Preview'),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        Printing.sharePdf(bytes: pdfBytes, filename: '${_template.title}.pdf');
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: PdfPreview(
                    build: (format) => pdfBytes,
                    allowPrinting: true,
                    allowSharing: true,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Cover Page', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            tooltip: 'Preview PDF',
            onPressed: _previewPdf,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.md),
          children: [
            _buildSectionTitle('Template Details'),
            _buildTextField(
              label: 'Template Title (e.g. OS Assignment 1)',
              initialValue: _template.title,
              onSaved: (val) => _template = _template.copyWith(title: val),
            ),
            
            _buildSectionTitle('Institution Information'),
            _buildTextField(
              label: 'Institution Name (University / College / School)',
              initialValue: _template.universityName,
              onSaved: (val) => _template = _template.copyWith(universityName: val),
            ),
            _buildTextField(
              label: 'Department',
              initialValue: _template.department,
              onSaved: (val) => _template = _template.copyWith(department: val),
            ),
            
            _buildSectionTitle('Course Information'),
            _buildTextField(
              label: 'Course Name',
              initialValue: _template.courseName,
              onSaved: (val) => _template = _template.copyWith(courseName: val),
            ),
            _buildTextField(
              label: 'Course Code',
              initialValue: _template.courseCode,
              onSaved: (val) => _template = _template.copyWith(courseCode: val),
            ),
            _buildTextField(
              label: 'Teacher / Instructor Name',
              initialValue: _template.teacherName,
              onSaved: (val) => _template = _template.copyWith(teacherName: val),
            ),

            _buildSectionTitle('Student Information'),
            _buildTextField(
              label: 'Student Name',
              initialValue: _template.studentName,
              onSaved: (val) => _template = _template.copyWith(studentName: val),
            ),
            _buildTextField(
              label: 'Student ID',
              initialValue: _template.studentId,
              onSaved: (val) => _template = _template.copyWith(studentId: val),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Semester',
                    initialValue: _template.semester,
                    onSaved: (val) => _template = _template.copyWith(semester: val),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: _buildTextField(
                    label: 'Section',
                    initialValue: _template.section,
                    onSaved: (val) => _template = _template.copyWith(section: val),
                  ),
                ),
              ],
            ),
            
            _buildSectionTitle('Submission Date'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Date: ${_template.submissionDate.day}/${_template.submissionDate.month}/${_template.submissionDate.year}'),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _template.submissionDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _template = _template.copyWith(submissionDate: date);
                  });
                }
              },
            ),
            
            const SizedBox(height: AppDimensions.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.lg, bottom: AppDimensions.sm),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required void Function(String?) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        onSaved: onSaved,
      ),
    );
  }
}
