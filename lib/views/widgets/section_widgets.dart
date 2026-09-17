import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// Heading of a section, followed by a rule filling the rest of the line.
class SectionLabel extends StatelessWidget {
  final String label;

  const SectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Flexible because a label is not always a short constant: a program
          // week is labelled with what the coach typed, and a Row hands a
          // non-flexible child unbounded width, so a long one would take the
          // rule's room and then run off the side of the phone.
          Flexible(
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
          const SizedBox(width: 8),
          Expanded(
            child: Container(height: 2, color: CrimpyTheme.borderDefault),
          ),
        ],
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
