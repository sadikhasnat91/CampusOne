import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../utils/responsive.dart';

/// Premium glass-morphism card that adapts its padding based on screen size.
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final double? elevation;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
    this.borderRadius,
    this.shadows,
    this.gradient,
    this.elevation,
  });

  EdgeInsets _responsivePadding(BuildContext context) {
    if (Responsive.isDesktop(context)) return const EdgeInsets.all(AppDimensions.lg);
    if (Responsive.isTablet(context)) return const EdgeInsets.all(AppDimensions.md);
    return const EdgeInsets.all(14);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(AppDimensions.radiusLg);

    final effectiveShadows = shadows ??
        [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          if (isDark)
            BoxShadow(
              color: AppColors.darkPrimary.withOpacity(0.05),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
        ];

    final borderColor = isDark
        ? const Color(0xFF1E3050)
        : AppColors.lightSurfaceVariant;

    Widget content = Container(
      padding: padding ?? _responsivePadding(context),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? (color ??
                (isDark ? AppColors.darkSurface1 : AppColors.lightSurface))
            : null,
        borderRadius: radius,
        border: border ?? Border.all(color: borderColor, width: 1),
        boxShadow: effectiveShadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
              .withOpacity(0.08),
          highlightColor: Colors.transparent,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Gradient accent card for premium sections.
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppDimensions.radiusLg);
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withOpacity(0.1),
            child: content,
          ),
        ),
      );
    }

    return content;
  }
}
