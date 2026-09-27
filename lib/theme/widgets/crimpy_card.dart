import 'package:flutter/material.dart';
import '../crimpy_theme.dart';

/// A card on one of the theme's two surfaces, [CrimpyTheme.raised] or
/// [CrimpyTheme.flat]. A card tapped as a whole is raised; any other is flat
/// unless it says [raised], which is for the one element that matters most on
/// its screen or a card whose content is what gets tapped. See
/// Krakoer/crimpy#173.
class CrimpyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? accentColor;
  final bool showAccentBorder;
  final VoidCallback? onTap;

  /// Whether the card stands on the raised surface. Left out, a card with an
  /// [onTap] is raised and any other is flat.
  final bool? raised;

  const CrimpyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.accentColor,
    this.showAccentBorder = false,
    this.onTap,
    this.raised,
  });

  /// Card with a bar down its left edge, for a state the whole card carries: a
  /// week override, a planned day, a week still to declare. Not for a category,
  /// which shows as an icon only. See Krakoer/crimpy#170.
  const CrimpyCard.category({
    super.key,
    required this.child,
    required this.accentColor,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.raised,
  }) : showAccentBorder = true;

  /// Simple card without accent
  const CrimpyCard.simple({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.raised,
  }) : showAccentBorder = false,
       accentColor = null;

  bool get isRaised => raised ?? onTap != null;

  @override
  Widget build(BuildContext context) {
    final surface = isRaised ? CrimpyTheme.raised : CrimpyTheme.flat;
    final side = (surface.border! as Border).top;
    final accent = accentColor;

    Widget card = Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8.0),
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: surface.copyWith(
        color: backgroundColor,
        border: showAccentBorder && accent != null
            ? Border(
                left: BorderSide(color: accent, width: 4),
                top: side,
                right: side,
                bottom: side,
              )
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: CrimpyTheme.corners,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Pre-configured card styles for common use cases
class CrimpyCards {
  /// Assessment card. The category shows in the card's icon, not as a bar.
  /// See Krakoer/crimpy#170.
  static Widget assessment({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    bool? raised,
  }) {
    return CrimpyCard.simple(
      padding: padding,
      margin: margin,
      onTap: onTap,
      raised: raised,
      child: child,
    );
  }

  /// Training card. The category shows in the card's icon, not as a bar.
  /// See Krakoer/crimpy#170.
  static Widget training({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    bool? raised,
  }) {
    return CrimpyCard.simple(
      padding: padding,
      margin: margin,
      onTap: onTap,
      raised: raised,
      child: child,
    );
  }

  /// A read-only metric, on the secondary ground and flat: stat tiles sit in
  /// groups, and a group of raised tiles has nothing standing out.
  static Widget stats({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return CrimpyCard.simple(
      padding: padding ?? const EdgeInsets.all(20.0),
      margin: margin,
      backgroundColor: CrimpyTheme.bgSecondary,
      child: child,
    );
  }
}
