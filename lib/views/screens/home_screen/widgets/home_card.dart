import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';
import 'package:crimpy/views/widgets/section_widgets.dart';

class HomeCard extends StatelessWidget {
  final Widget child;
  final Widget? topLeft;
  final String title;
  final VoidCallback? onTap;

  /// Whether the card stands raised. Left out, it is raised when it has an
  /// [onTap], as CrimpyCard decides.
  final bool? raised;

  const HomeCard({
    required this.child,
    required this.title,
    this.onTap,
    this.topLeft,
    this.raised,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CrimpyCard.simple(
      onTap: onTap,
      raised: raised,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionHeading(title),
              topLeft ?? const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: CrimpyTheme.headingGap),
          child,
        ],
      ),
    );
  }
}
