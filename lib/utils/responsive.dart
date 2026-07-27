import 'package:flutter/material.dart';

/// Helper class to determine screen size categories.
class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 900;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 900;

  /// Returns a widget based on the current breakpoint.
  static Widget builder({
    required BuildContext context,
    required Widget Function(BuildContext) mobile,
    Widget Function(BuildContext)? tablet,
    Widget Function(BuildContext)? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop(context);
    if (isTablet(context) && tablet != null) return tablet(context);
    return mobile(context);
  }
}
