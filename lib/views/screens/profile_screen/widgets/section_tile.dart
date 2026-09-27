import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// Heading of a section, in capitals like every section heading in the app.
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: CrimpyTheme.capsLabel.copyWith(color: CrimpyTheme.textSecondary),
      ),
    );
  }
}
