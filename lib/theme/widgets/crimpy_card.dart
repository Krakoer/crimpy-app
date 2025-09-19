import 'package:flutter/material.dart';
import '../crimpy_theme.dart';

/// Custom card widget with double border design inspired by Meeko.store
/// Creates depth through layered borders and subtle shadows
class CrimpyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? accentColor;
  final double borderWidth;
  final double shadowOffset;
  final bool showAccentBorder;
  final VoidCallback? onTap;

  const CrimpyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.accentColor,
    this.borderWidth = 2.0,
    this.shadowOffset = 3.0,
    this.showAccentBorder = false,
    this.onTap,
  });

  /// Category card with colored accent border
  const CrimpyCard.category({
    super.key,
    required this.child,
    required this.accentColor,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.shadowOffset = 3.0,
    this.onTap,
  }) : showAccentBorder = true;

  /// Simple card without accent
  const CrimpyCard.simple({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.shadowOffset = 3.0,
    this.onTap,
  }) : showAccentBorder = false,
       accentColor = null;

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? CrimpyTheme.bgPrimary;
    final effectiveBorderColor = borderColor ?? CrimpyTheme.borderDefault;
    final effectivePadding = padding ?? const EdgeInsets.all(16.0);
    final effectiveMargin = margin ?? const EdgeInsets.symmetric(vertical: 8.0);

    Widget cardContent = Container(
      width: double.infinity,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        border:
            showAccentBorder && accentColor != null
                ? Border(
                  left: BorderSide(color: accentColor!, width: 4),
                  top: BorderSide(
                    color: effectiveBorderColor,
                    width: borderWidth,
                  ),
                  right: BorderSide(
                    color: effectiveBorderColor,
                    width: borderWidth,
                  ),
                  bottom: BorderSide(
                    color: effectiveBorderColor,
                    width: borderWidth,
                  ),
                )
                : Border.all(color: effectiveBorderColor, width: borderWidth),
        borderRadius: BorderRadius.zero, // Sharp corners for Radicle aesthetic
      ),
      child: child,
    );

    // Add double border effect using a Container with shadow
    Widget doubleBoredCard = Container(
      margin: effectiveMargin,
      decoration: BoxDecoration(
        // Shadow creates the "double border" effect
        boxShadow: [
          BoxShadow(
            color: effectiveBorderColor,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0, // Sharp shadow for clean look
            spreadRadius: 0,
          ),
        ],
      ),
      child: cardContent,
    );

    // Wrap with InkWell if onTap is provided
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.zero,
          child: doubleBoredCard,
        ),
      );
    }

    return doubleBoredCard;
  }
}

/// Extension methods for easier card creation
extension CrimpyCardExtensions on Widget {
  /// Wrap widget in a simple CrimpyCard
  Widget wrapInCard({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 2.0,
    double shadowOffset = 3.0,
    VoidCallback? onTap,
  }) {
    return CrimpyCard.simple(
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      shadowOffset: shadowOffset,
      onTap: onTap,
      child: this,
    );
  }

  /// Wrap widget in a category CrimpyCard with accent color
  Widget wrapInCategoryCard({
    required Color accentColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 2.0,
    double shadowOffset = 3.0,
    VoidCallback? onTap,
  }) {
    return CrimpyCard.category(
      accentColor: accentColor,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      shadowOffset: shadowOffset,
      onTap: onTap,
      child: this,
    );
  }
}

/// Pre-configured card styles for common use cases
class CrimpyCards {
  /// Assessment card with orange accent
  static Widget assessment({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return CrimpyCard.category(
      accentColor: CrimpyTheme.assessmentColor,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// Training card with yellow accent
  static Widget training({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return CrimpyCard.category(
      accentColor: CrimpyTheme.trainingColor,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// Flexibility card with teal accent
  static Widget flexibility({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return CrimpyCard.category(
      accentColor: CrimpyTheme.stretchingColor,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// Endurance card with green accent
  static Widget endurance({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return CrimpyCard.category(
      accentColor: CrimpyTheme.accentGreen,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// Power card with golden yellow accent
  static Widget power({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return CrimpyCard.category(
      accentColor: CrimpyTheme.accentYellow,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// Technique card with purple accent
  static Widget technique({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return CrimpyCard.category(
      accentColor: CrimpyTheme.accentPurple,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// Stats card for displaying metrics
  static Widget stats({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return CrimpyCard.simple(
      padding: padding ?? const EdgeInsets.all(20.0),
      margin: margin,
      backgroundColor: CrimpyTheme.bgSecondary,
      onTap: onTap,
      child: child,
    );
  }

  /// Action card for buttons and interactive elements
  static Widget action({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return CrimpyCard.simple(
      padding: padding,
      margin: margin,
      borderColor: CrimpyTheme.primaryOrange,
      onTap: onTap,
      child: child,
    );
  }
}
