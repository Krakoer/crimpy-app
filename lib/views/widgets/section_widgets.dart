import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// Heading of a section, in capitals in the caps label style. Every section
/// heading in the app is one of these, so none drifts back to Title Case. See
/// Krakoer/crimpy#169.
class SectionHeading extends StatelessWidget {
  final String label;
  final int? maxLines;

  const SectionHeading(this.label, {this.maxLines, super.key});

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
    style: CrimpyTheme.capsLabel.copyWith(color: CrimpyTheme.textSecondary),
  );
}

/// [SectionHeading] followed by a rule filling the rest of the line.
class SectionLabel extends StatelessWidget {
  /// Space between the label and the rule.
  static const double _labelGap = 8;

  /// How much rule is kept whatever the label says, so a heading still reads
  /// as a heading rather than as a line of text.
  static const double _minRuleWidth = 24;

  final String label;

  const SectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    // A label is not always a short constant: a program week is labelled with
    // what the coach typed. A Row hands a non-flexible child unbounded width,
    // so a long label would take the rule's room and then run off the side of
    // the phone, and making the label Flexible instead is worse: a Row splits
    // its free space between its flex children, so a Flexible label beside the
    // Expanded rule pins the rule at half the line whatever the label says and
    // clips a label that had room. So the rule stays the only flex child and
    // the label is bounded to what is left of the line beyond a stub of rule.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CrimpyTheme.spaceXs),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelRoom = constraints.maxWidth - _labelGap - _minRuleWidth;
          return Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: labelRoom > 0 ? labelRoom : 0,
                ),
                child: SectionHeading(label, maxLines: 1),
              ),
              const SizedBox(width: _labelGap),
              Expanded(child: Container(height: 2, color: CrimpyTheme.outline)),
            ],
          );
        },
      ),
    );
  }
}

/// Free text written by a coach, such as the goal or the instructions of a
/// training, shown as a card under its section label.
class SectionTextBlock extends StatelessWidget {
  final String text;

  const SectionTextBlock(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return CrimpyCard.simple(
      child: Text(
        text,
        style: CrimpyTheme.bodySmall.copyWith(color: CrimpyTheme.textPrimary),
      ),
    );
  }
}
