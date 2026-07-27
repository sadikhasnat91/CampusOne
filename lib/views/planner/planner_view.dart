import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/home_controller.dart';
import '../../constants/app_colors.dart';
import '../../controllers/academic_controller.dart';
import '../../helpers/snackbar_helper.dart';
import '../../models/academic_event_model.dart';
import '../../models/course_material_model.dart';
import '../../models/subject_model.dart';
import '../../widgets/animation_widgets.dart';
import '../../widgets/empty_state_widget.dart';
import '../academic/widgets/cgpa_calculator_dialog.dart';

class PlannerView extends StatelessWidget {
  const PlannerView({super.key});

  IconData _materialIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'link':
        return Icons.link_rounded;
      default:
        return Icons.note_rounded;
    }
  }

  Color _materialColor(String type) {
    switch (type) {
      case 'pdf':
        return const Color(0xFFEF5350);
      case 'image':
        return const Color(0xFF66BB6A);
      case 'link':
        return const Color(0xFF4FC3F7);
      default:
        return const Color(0xFF9575CD);
    }
  }

  // ─── ADD / EDIT SUBJECT DIALOG ─────────────────────────────────────────────
  void _showAddEditSubjectDialog(
    BuildContext ctx,
    AcademicController ctrl, [
    SubjectModel? existing,
  ]) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final profile = Provider.of<HomeController>(ctx, listen: false).profile;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final creditsCtrl = TextEditingController(
      text: existing?.credits.toString() ?? '3.0',
    );
    final gradeCtrl = TextEditingController(
      text: existing?.gradePoint.toString() ?? '4.0',
    );
    String semester =
        existing?.semester ??
        (profile.academicLevelOptions.contains(ctrl.selectedSemester)
            ? ctrl.selectedSemester
            : profile.academicLevelOptions.first);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => StatefulBuilder(
        builder: (bCtx2, setS) {
          final bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
          final border = isDark
              ? const Color(0xFF1E2D42)
              : AppColors.lightSurfaceVariant;
          final accent = isDark
              ? AppColors.darkPrimary
              : AppColors.lightPrimary;
          final textPrimary = isDark
              ? AppColors.darkOnSurface
              : AppColors.lightOnSurface;

          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(bCtx2).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(top: BorderSide(color: border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  existing == null ? 'Add New Subject' : 'Edit Subject',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: textPrimary),
                  decoration: _inputDeco(
                    'Subject Name (e.g. Operating Systems)',
                    isDark,
                    border,
                    accent,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: codeCtrl,
                        style: TextStyle(color: textPrimary),
                        decoration: _inputDeco(
                          'Code (e.g. SUB-101)',
                          isDark,
                          border,
                          accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: creditsCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textPrimary),
                        decoration: _inputDeco(
                          'Credits (e.g. 3.0)',
                          isDark,
                          border,
                          accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: gradeCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textPrimary),
                        decoration: _inputDeco(
                          'Grade Point (0-4.0)',
                          isDark,
                          border,
                          accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: semester,
                        decoration: _inputDeco(
                          profile.academicLevelLabel,
                          isDark,
                          border,
                          accent,
                        ),
                        dropdownColor: isDark
                            ? AppColors.darkSurface2
                            : AppColors.lightSurface,
                        style: TextStyle(fontSize: 12, color: textPrimary),
                        items: profile.academicLevelOptions
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setS(() => semester = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (nameCtrl.text.trim().isNotEmpty) {
                        final sub = SubjectModel(
                          id:
                              existing?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameCtrl.text.trim(),
                          code: codeCtrl.text.trim().isEmpty
                              ? 'SUB-000'
                              : codeCtrl.text.trim(),
                          credits: double.tryParse(creditsCtrl.text) ?? 3.0,
                          semester: semester,
                          attendedClasses: existing?.attendedClasses ?? 0,
                          totalClasses: existing?.totalClasses ?? 0,
                          gradePoint: double.tryParse(gradeCtrl.text) ?? 4.0,
                        );
                        if (existing == null) {
                          ctrl.addSubject(sub);
                        } else {
                          ctrl.updateSubject(sub);
                        }
                        Navigator.pop(bCtx2);
                        SnackbarHelper.showSuccess(
                          ctx,
                          existing == null
                              ? 'Subject Added!'
                              : 'Subject Updated!',
                        );
                      }
                    },
                    child: Text(
                      existing == null ? 'Save Subject' : 'Update Subject',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── ADD / EDIT EVENT DIALOG ───────────────────────────────────────────────
  void _showAddEditEventDialog(
    BuildContext ctx,
    AcademicController ctrl, [
    AcademicEventModel? existing,
  ]) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final subjectCtrl = TextEditingController(
      text: existing?.subjectName ?? '',
    );
    String eventType = existing?.eventType ?? 'assignment';
    DateTime selectedDate =
        existing?.dueDate ?? DateTime.now().add(const Duration(days: 3));

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => StatefulBuilder(
        builder: (bCtx2, setS) {
          final bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
          final border = isDark
              ? const Color(0xFF1E2D42)
              : AppColors.lightSurfaceVariant;
          final accent = isDark
              ? AppColors.darkPrimary
              : AppColors.lightPrimary;
          final textPrimary = isDark
              ? AppColors.darkOnSurface
              : AppColors.lightOnSurface;

          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(bCtx2).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(top: BorderSide(color: border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  existing == null ? 'Add Event / Deadline' : 'Edit Event',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: textPrimary),
                  decoration: _inputDeco(
                    'Title (e.g. Midterm Exam / Project Submission)',
                    isDark,
                    border,
                    accent,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subjectCtrl,
                  style: TextStyle(color: textPrimary),
                  decoration: _inputDeco(
                    'Subject Name (e.g. Algorithms Design)',
                    isDark,
                    border,
                    accent,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: eventType,
                        decoration: _inputDeco(
                          'Event Type',
                          isDark,
                          border,
                          accent,
                        ),
                        dropdownColor: isDark
                            ? AppColors.darkSurface2
                            : AppColors.lightSurface,
                        style: TextStyle(fontSize: 12, color: textPrimary),
                        items: const [
                          DropdownMenuItem(
                            value: 'assignment',
                            child: Text('Assignment'),
                          ),
                          DropdownMenuItem(value: 'exam', child: Text('Exam')),
                          DropdownMenuItem(value: 'quiz', child: Text('Quiz')),
                          DropdownMenuItem(
                            value: 'presentation',
                            child: Text('Presentation'),
                          ),
                        ],
                        onChanged: (v) => setS(() => eventType = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: bCtx2,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) setS(() => selectedDate = picked);
                        },
                        child: InputDecorator(
                          decoration: _inputDeco(
                            'Due Date',
                            isDark,
                            border,
                            accent,
                          ),
                          child: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: TextStyle(fontSize: 12, color: textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.trim().isNotEmpty) {
                        final evt = AcademicEventModel(
                          id:
                              existing?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text.trim(),
                          subjectName: subjectCtrl.text.trim().isEmpty
                              ? 'General'
                              : subjectCtrl.text.trim(),
                          eventType: eventType,
                          dueDate: selectedDate,
                        );
                        if (existing == null) {
                          ctrl.addAcademicEvent(evt);
                        } else {
                          ctrl.updateAcademicEvent(evt);
                        }
                        Navigator.pop(bCtx2);
                        SnackbarHelper.showSuccess(
                          ctx,
                          existing == null ? 'Event Added!' : 'Event Updated!',
                        );
                      }
                    },
                    child: Text(
                      existing == null ? 'Save Event' : 'Update Event',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── ADD / EDIT MATERIAL DIALOG ────────────────────────────────────────────
  void _showAddEditMaterialDialog(
    BuildContext ctx,
    AcademicController ctrl, [
    CourseMaterialModel? existing,
  ]) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final urlCtrl = TextEditingController(text: existing?.contentUrl ?? '');
    String type = existing?.type ?? 'pdf';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => StatefulBuilder(
        builder: (bCtx2, setS) {
          final bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
          final border = isDark
              ? const Color(0xFF1E2D42)
              : AppColors.lightSurfaceVariant;
          final accent = isDark
              ? AppColors.darkPrimary
              : AppColors.lightPrimary;
          final textPrimary = isDark
              ? AppColors.darkOnSurface
              : AppColors.lightOnSurface;

          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(bCtx2).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(top: BorderSide(color: border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  existing == null ? 'Add Course Resource' : 'Edit Resource',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: textPrimary),
                  decoration: _inputDeco(
                    'Title (e.g. DBMS Lecture 01 Slides)',
                    isDark,
                    border,
                    accent,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: urlCtrl,
                  style: TextStyle(color: textPrimary),
                  decoration: _inputDeco(
                    'Resource Link / URL',
                    isDark,
                    border,
                    accent,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: _inputDeco(
                    'Material Type',
                    isDark,
                    border,
                    accent,
                  ),
                  dropdownColor: isDark
                      ? AppColors.darkSurface2
                      : AppColors.lightSurface,
                  style: TextStyle(fontSize: 12, color: textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'pdf', child: Text('PDF Document')),
                    DropdownMenuItem(
                      value: 'image',
                      child: Text('Image / Diagram'),
                    ),
                    DropdownMenuItem(
                      value: 'link',
                      child: Text('Web Link / Docs'),
                    ),
                    DropdownMenuItem(value: 'note', child: Text('Text Note')),
                  ],
                  onChanged: (v) => setS(() => type = v!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.trim().isNotEmpty) {
                        final mat = CourseMaterialModel(
                          id:
                              existing?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          subjectId: 'general',
                          title: titleCtrl.text.trim(),
                          type: type,
                          contentUrl: urlCtrl.text.trim().isEmpty
                              ? 'https://campusone.edu'
                              : urlCtrl.text.trim(),
                          dateAdded: existing?.dateAdded ?? DateTime.now(),
                        );
                        if (existing == null) {
                          ctrl.addMaterial(mat);
                        } else {
                          ctrl.updateMaterial(mat);
                        }
                        Navigator.pop(bCtx2);
                        SnackbarHelper.showSuccess(
                          ctx,
                          existing == null
                              ? 'Resource Added!'
                              : 'Resource Updated!',
                        );
                      }
                    },
                    child: Text(
                      existing == null ? 'Save Resource' : 'Update Resource',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDeco(
    String label,
    bool isDark,
    Color border,
    Color accent,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isDark
            ? AppColors.darkOnSurfaceVariant
            : AppColors.lightOnSurfaceVariant,
      ),
      filled: true,
      fillColor: isDark
          ? AppColors.darkSurface2
          : AppColors.lightSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBackground;
    final accent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textPrimary = isDark
        ? AppColors.darkOnSurface
        : AppColors.lightOnSurface;
    final textSecondary = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final cardColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final border = isDark
        ? const Color(0xFF1E2D42)
        : AppColors.lightSurfaceVariant;

    final controller = Provider.of<AcademicController>(context);
    final profile = Provider.of<HomeController>(context).profile;
    final subjects = controller.subjects;
    final materials = controller.materials;
    final events = controller.events;
    final cgpa = controller.calculateOverallCgpa();

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSubjectDialog(context, controller),
        backgroundColor: accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Subject',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: bg,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.tealGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Academic Hub',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Material(
                  color: isDark
                      ? AppColors.darkSurface1.withOpacity(0.6)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) =>
                          CgpaCalculatorDialog(controller: controller),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.calculate_outlined,
                        size: 20,
                        color: accent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
        body: CustomScrollView(
          slivers: [
            // ── CGPA Banner ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: AnimatedListItem(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _CgpaBanner(
                    cgpa: cgpa,
                    isDark: isDark,
                    onCalculate: () => showDialog(
                      context: context,
                      builder: (_) =>
                          CgpaCalculatorDialog(controller: controller),
                    ),
                  ),
                ),
              ),
            ),

            // ── Upcoming Events ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: AnimatedListItem(
                delay: const Duration(milliseconds: 60),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                  child: Row(
                    children: [
                      _SectionLabel(
                        label: 'Upcoming Events & Deadlines',
                        isDark: isDark,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            _showAddEditEventDialog(context, controller),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, size: 14, color: accent),
                              const SizedBox(width: 4),
                              Text(
                                'Add Event',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (events.isNotEmpty)
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  delay: const Duration(milliseconds: 80),
                  child: SizedBox(
                    height: 125,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: events.length,
                      itemBuilder: (_, i) {
                        final evt = events[i];
                        final isExam = evt.eventType == 'exam';
                        final eventColor = isExam
                            ? const Color(0xFFEF5350)
                            : const Color(0xFF9575CD);

                        return AnimatedListItem(
                          delay: Duration(milliseconds: 40 * i),
                          child: Container(
                            width: 230,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: border),
                              boxShadow: [
                                BoxShadow(
                                  color: eventColor.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: eventColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        evt.eventType.toUpperCase(),
                                        style: TextStyle(
                                          color: eventColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: eventColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${evt.daysRemaining}d left',
                                        style: TextStyle(
                                          color: eventColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.more_vert_rounded,
                                        size: 16,
                                        color: textSecondary,
                                      ),
                                      onSelected: (v) {
                                        if (v == 'edit')
                                          _showAddEditEventDialog(
                                            context,
                                            controller,
                                            evt,
                                          );
                                        if (v == 'delete')
                                          controller.deleteAcademicEvent(
                                            evt.id,
                                          );
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  evt.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  evt.subjectName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // ── Semester Filter + Subjects ────────────────────────────────
            SliverToBoxAdapter(
              child: AnimatedListItem(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                  child: Row(
                    children: [
                      _SectionLabel(
                        label: 'Subjects & Attendance',
                        isDark: isDark,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            _showAddEditSubjectDialog(context, controller),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, size: 14, color: accent),
                              const SizedBox(width: 4),
                              Text(
                                '+ Subject',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface1
                              : AppColors.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                profile.academicLevelOptions.contains(
                                  controller.selectedSemester,
                                )
                                ? controller.selectedSemester
                                : profile.academicLevelOptions.first,
                            isDense: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: accent,
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                            dropdownColor: isDark
                                ? AppColors.darkSurface2
                                : AppColors.lightSurface,
                            items: profile.academicLevelOptions
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      profile.institutionType == 'university'
                                          ? s.replaceFirst(' Semester', ' Sem')
                                          : s,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.setSelectedSemester(val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (subjects.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyStateWidget(
                    title: 'No Subjects for ${controller.selectedSemester}',
                    description:
                        'Tap below to add your first subject for this semester!',
                    icon: Icons.menu_book_rounded,
                    actionLabel: 'Add Subject',
                    onAction: () =>
                        _showAddEditSubjectDialog(context, controller),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((_, i) {
                    final sub = subjects[i];
                    final pct = sub.attendancePercentage;
                    final isOk = pct >= 75;
                    final attColor = isOk ? AppColors.success : AppColors.error;

                    return AnimatedListItem(
                      delay: Duration(milliseconds: 60 + i * 50),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.2 : 0.05,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sub.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${sub.code} • ${sub.credits} Credits • GP: ${sub.gradePoint}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: attColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$pct%',
                                    style: TextStyle(
                                      color: attColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: textSecondary,
                                  ),
                                  onSelected: (v) {
                                    if (v == 'edit')
                                      _showAddEditSubjectDialog(
                                        context,
                                        controller,
                                        sub,
                                      );
                                    if (v == 'delete')
                                      controller.deleteSubject(sub.id);
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: pct / 100),
                                duration: Duration(milliseconds: 600 + i * 80),
                                curve: Curves.easeOut,
                                builder: (_, val, __) =>
                                    LinearProgressIndicator(
                                      value: val,
                                      minHeight: 5,
                                      backgroundColor: attColor.withOpacity(
                                        0.12,
                                      ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        attColor,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Attended ${sub.attendedClasses}/${sub.totalClasses}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                // Minus attendance
                                GestureDetector(
                                  onTap: () {
                                    if (sub.attendedClasses > 0) {
                                      controller.updateAttendance(
                                        sub.id,
                                        sub.attendedClasses - 1,
                                        sub.totalClasses > 0
                                            ? sub.totalClasses - 1
                                            : 0,
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '- Absent',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Plus attendance
                                GestureDetector(
                                  onTap: () {
                                    controller.updateAttendance(
                                      sub.id,
                                      sub.attendedClasses + 1,
                                      sub.totalClasses + 1,
                                    );
                                    SnackbarHelper.showSuccess(
                                      context,
                                      'Attendance recorded!',
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: 14,
                                          color: accent,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+ Present',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: accent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: subjects.length),
                ),
              ),

            // ── Course Materials ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: AnimatedListItem(
                delay: const Duration(milliseconds: 140),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                  child: Row(
                    children: [
                      _SectionLabel(
                        label: 'Course Materials & Resources',
                        isDark: isDark,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            _showAddEditMaterialDialog(context, controller),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, size: 14, color: accent),
                              const SizedBox(width: 4),
                              Text(
                                'Add Resource',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (materials.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyStateWidget(
                    title: 'No Resources Added',
                    description:
                        'Tap below to add PDFs, links, or visual notes!',
                    icon: Icons.folder_open_rounded,
                    actionLabel: 'Add Resource',
                    onAction: () =>
                        _showAddEditMaterialDialog(context, controller),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((_, i) {
                    final mat = materials[i];
                    final color = _materialColor(mat.type);

                    return AnimatedListItem(
                      delay: Duration(milliseconds: 160 + i * 40),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => SnackbarHelper.showInfo(
                              context,
                              'Opening ${mat.title}',
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _materialIcon(mat.type),
                                      color: color,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mat.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: textPrimary,
                                          ),
                                        ),
                                        Text(
                                          mat.type.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: color,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                      size: 18,
                                      color: textSecondary,
                                    ),
                                    onSelected: (v) {
                                      if (v == 'edit')
                                        _showAddEditMaterialDialog(
                                          context,
                                          controller,
                                          mat,
                                        );
                                      if (v == 'delete')
                                        controller.deleteMaterial(mat.id);
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: materials.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Section widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _CgpaBanner extends StatelessWidget {
  final double cgpa;
  final bool isDark;
  final VoidCallback onCalculate;

  const _CgpaBanner({
    required this.cgpa,
    required this.isDark,
    required this.onCalculate,
  });

  Color get _grade {
    if (cgpa >= 3.5) return AppColors.success;
    if (cgpa >= 2.5) return const Color(0xFFFFB74D);
    return AppColors.error;
  }

  String get _gradeLabel {
    if (cgpa >= 3.75) return 'Excellent';
    if (cgpa >= 3.25) return 'Very Good';
    if (cgpa >= 2.75) return 'Good';
    if (cgpa >= 2.00) return 'Average';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.heroGradientDark
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066CC).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // CGPA circle
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: cgpa / 4.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (_, val, __) => SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: val,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(_grade),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cgpa.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '/ 4.00',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall CGPA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _gradeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onCalculate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Simulate Expected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
