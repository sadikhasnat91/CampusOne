import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      title: Text(title, style: theme.textTheme.headlineSmall),
      content: Text(content, style: theme.textTheme.bodyMedium),
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelLabel!),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
