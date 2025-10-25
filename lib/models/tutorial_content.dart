import 'package:flutter/material.dart';

/// Represents a section in the tutorial dialog.
class TutorialSection {
  final IconData icon;
  final String title;
  final String content;
  final Color? iconColor;

  const TutorialSection({
    required this.icon,
    required this.title,
    required this.content,
    this.iconColor,
  });
}

/// Complete tutorial content for an assessment.
class TutorialContent {
  final String assessmentName;
  final String subtitle;
  final List<TutorialSection> sections;

  const TutorialContent({
    required this.assessmentName,
    required this.subtitle,
    required this.sections,
  });
}
