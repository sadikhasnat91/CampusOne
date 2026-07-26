import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_dimensions.dart';
import '../../controllers/academic_controller.dart';
import '../../helpers/snackbar_helper.dart';
import '../../widgets/custom_card.dart';
import '../academic/widgets/cgpa_calculator_dialog.dart';

class PlannerView extends StatelessWidget {
  const PlannerView({super.key});

  IconData _getMaterialIcon(String type) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<AcademicController>(context);
    final subjects = controller.subjects;
    final materials = controller.materials;
    final events = controller.events;

    final overallCgpa = controller.calculateOverallCgpa();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic & Course Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            tooltip: 'CGPA Calculator',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => CgpaCalculatorDialog(controller: controller),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CGPA Overview Banner
            CustomCard(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current CGPA Status', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '$overallCgpa / 4.00',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => CgpaCalculatorDialog(controller: controller),
                      );
                    },
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: const Text('Simulate Expected'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Exam & Assignment Countdown Reminders
            Text('Upcoming Exam & Assignment Reminders', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.sm),

            events.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      itemBuilder: (context, idx) {
                        final evt = events[idx];
                        final isExam = evt.eventType == 'exam';
                        return Container(
                          width: 260,
                          margin: const EdgeInsets.only(right: AppDimensions.md),
                          child: CustomCard(
                            color: isExam ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4) : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isExam ? theme.colorScheme.tertiary : theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        evt.eventType.toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      '${evt.daysRemaining} Days Left',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isExam ? theme.colorScheme.tertiary : theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(evt.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(evt.subjectName, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: AppDimensions.lg),

            // Semester Subjects & Attendance Calculator Hub
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Semester Subjects & Attendance', style: theme.textTheme.titleMedium),
                DropdownButton<String>(
                  value: controller.selectedSemester,
                  underline: const SizedBox.shrink(),
                  items: ['1st Semester', '2nd Semester', '3rd Semester', '4th Semester', '5th Semester', '6th Semester', '7th Semester', '8th Semester']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) controller.setSelectedSemester(val);
                  },
                )
              ],
            ),
            const SizedBox(height: AppDimensions.sm),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjects.length,
              itemBuilder: (context, idx) {
                final sub = subjects[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: sub.attendancePercentage >= 75 ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${sub.attendancePercentage}% Attendance',
                                style: TextStyle(
                                  color: sub.attendancePercentage >= 75 ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('${sub.code} • ${sub.credits} Credits', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: AppDimensions.sm),
                        Row(
                          children: [
                            Text('Attended ${sub.attendedClasses} / ${sub.totalClasses} classes', style: const TextStyle(fontSize: 12)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                              onPressed: () {
                                controller.updateAttendance(sub.id, sub.attendedClasses + 1, sub.totalClasses + 1);
                                SnackbarHelper.showSuccess(context, 'Attendance recorded!');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppDimensions.lg),

            // Course Materials (PDF, Images, Notes, Links)
            Text('Course Materials & Resources', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.sm),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: materials.length,
              itemBuilder: (context, idx) {
                final mat = materials[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                  child: CustomCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(_getMaterialIcon(mat.type), color: theme.colorScheme.primary),
                      ),
                      title: Text(mat.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Type: ${mat.type.toUpperCase()} • Direct Attachment'),
                      trailing: IconButton(
                        icon: const Icon(Icons.download_rounded),
                        onPressed: () {
                          SnackbarHelper.showInfo(context, 'Opening ${mat.title}');
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
