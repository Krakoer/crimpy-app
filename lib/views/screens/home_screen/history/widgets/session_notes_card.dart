import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';

class SessionNotesCard extends StatelessWidget {
  final String notes;

  const SessionNotesCard({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return CrimpyCard.simple(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(notes, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
