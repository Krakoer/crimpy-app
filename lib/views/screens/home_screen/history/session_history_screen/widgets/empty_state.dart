import 'package:flutter/material.dart';
import 'package:crimpy/theme/crimpy_theme.dart';
import 'package:intl/intl.dart';

class EmptyState extends StatelessWidget {
  final DateTime? selectedDate;

  const EmptyState({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 64, color: CrimpyTheme.textSecondary),
          const SizedBox(height: CrimpyTheme.spaceLg),
          Text(
            selectedDate != null
                ? 'No sessions on ${DateFormat('MMMM d, y').format(selectedDate!)}'
                : 'No sessions found',
            style: CrimpyTheme.title.copyWith(color: CrimpyTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
