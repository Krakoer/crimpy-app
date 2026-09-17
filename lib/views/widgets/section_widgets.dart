import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// Heading of a section, followed by a rule filling the rest of the line.
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelRoom = constraints.maxWidth - _labelGap - _minRuleWidth;
          return Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: labelRoom > 0 ? labelRoom : 0,
                ),
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: CrimpyTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: _labelGap),
              Expanded(
                child: Container(height: 2, color: CrimpyTheme.borderDefault),
              ),
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
        style: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          height: 1.5,
          color: CrimpyTheme.textPrimary,
        ),
      ),
    );
  }
}
