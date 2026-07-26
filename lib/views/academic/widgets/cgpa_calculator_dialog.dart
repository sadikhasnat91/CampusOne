import 'package:flutter/material.dart';
import '../../../constants/app_dimensions.dart';
import '../../../controllers/academic_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_card.dart';

class CgpaCalculatorDialog extends StatefulWidget {
  final AcademicController controller;

  const CgpaCalculatorDialog({super.key, required this.controller});

  @override
  State<CgpaCalculatorDialog> createState() => _CgpaCalculatorDialogState();
}

class _CgpaCalculatorDialogState extends State<CgpaCalculatorDialog> {
  double _targetGrade = 3.75;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overall = widget.controller.calculateOverallCgpa();
    final expected = widget.controller.calculateExpectedCgpa(_targetGrade);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CGPA & Credit Calculator', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppDimensions.md),
            CustomCard(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overall CGPA', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('$overall / 4.00', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Projected CGPA', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('$expected', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.tertiary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text('Projected Target GPA for Upcoming Courses: ${_targetGrade.toStringAsFixed(2)}'),
            Slider(
              value: _targetGrade,
              min: 2.0,
              max: 4.0,
              divisions: 20,
              label: _targetGrade.toStringAsFixed(2),
              onChanged: (val) => setState(() => _targetGrade = val),
            ),
            const SizedBox(height: AppDimensions.md),
            CustomButton(
              label: 'Close Calculator',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
