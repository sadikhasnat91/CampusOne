import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Responsive app logo widget that scales its size based on device width.
class AppLogo extends StatelessWidget {
  final bool showText;
  final TextStyle? textStyle;
  final double? size;

  const AppLogo({
    super.key,
    this.showText = false,
    this.textStyle,
    this.size,
  });

  double _logoSize(BuildContext context) {
    if (size != null) return size!;
    if (Responsive.isDesktop(context)) return 180.0;
    if (Responsive.isTablet(context)) return 120.0;
    return 80.0;
  }

  @override
  Widget build(BuildContext context) {
    final size = _logoSize(context);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.tertiary;

    final logoWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: size * 0.25,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.school_rounded,
          size: size * 0.52,
          color: Colors.white,
        ),
      ),
    );

    if (!showText) return logoWidget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoWidget,
        const SizedBox(height: 12),
        Text(
          'CampusOne',
          style: textStyle ??
              theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: theme.colorScheme.onSurface,
              ),
        ),
        Text(
          'Student Academic Suite',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
