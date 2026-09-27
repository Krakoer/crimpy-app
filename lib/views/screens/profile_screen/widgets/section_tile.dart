import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:flutter/material.dart';

/// Section title widget
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: CrimpyTheme.title.copyWith(
          color: CrimpyTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
