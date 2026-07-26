import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isSecondary;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isSecondary ? theme.colorScheme.primary : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppDimensions.sm),
              ],
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          );

    final style = ElevatedButton.styleFrom(
      backgroundColor: isSecondary
          ? theme.colorScheme.secondaryContainer
          : theme.colorScheme.primary,
      foregroundColor: isSecondary
          ? theme.colorScheme.onSecondaryContainer
          : theme.colorScheme.onPrimary,
      elevation: 0,
      minimumSize: Size(isFullWidth ? double.infinity : 0, AppDimensions.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: buttonChild,
    );
  }
}
